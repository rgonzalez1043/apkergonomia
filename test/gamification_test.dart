import 'package:ergonoworkcoah/core/storage/user_local_storage.dart';
import 'package:ergonoworkcoah/features/gamification/presentation/cubit/gamification_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late UserLocalStorage storage;
  late GamificationCubit cubit;
  late DateTime today;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = UserLocalStorage(await SharedPreferences.getInstance());
    await storage.activate('alice');
    today = DateTime(2026, 10, 6, 12);
    cubit = GamificationCubit(storage, now: () => today)..init('alice');
  });
  tearDown(() => cubit.close());

  test('achievements grant XP once and survive rebuilding the cubit', () async {
    await cubit.recordPainEntry();
    await cubit.recordPainEntry();
    await cubit.recordAvatarEdit();
    expect(cubit.state.progress.totalXP, 125);
    final restored = GamificationCubit(storage)..init('alice');
    addTearDown(restored.close);
    expect(restored.state.progress, cubit.state.progress);
    await restored.recordPainEntry();
    expect(restored.state.progress.totalXP, 125);
  });

  test(
      'breathing sessions award points and unlock seventh session across restarts',
      () async {
    for (var i = 0; i < 6; i++) {
      await cubit.completeBreathingSession();
    }
    expect(cubit.state.progress.totalXP, 350);
    final restored = GamificationCubit(storage)..init('alice');
    addTearDown(restored.close);
    await restored.completeBreathingSession();
    expect(restored.state.progress.totalXP, 600);
    expect(restored.state.progress.currentLevel, 2);
    expect(restored.state.progress.unlockedAchievementIds,
        contains('breath_streak_7'));
  });

  test('daily streaks count dates once and reset after a missed day', () async {
    for (var i = 0; i < 3; i++) {
      await cubit.recordExerciseCompletion();
      await cubit.recordExerciseCompletion();
      today = DateTime(today.year, today.month, today.day + 1, 12);
    }
    expect(cubit.state.progress.streaksByModule['pain'], 3);
    expect(
        cubit.state.progress.unlockedAchievementIds, contains('pain_streak_3'));
    today = DateTime(today.year, today.month, today.day + 1, 12);
    await cubit.recordExerciseCompletion();
    expect(cubit.state.progress.streaksByModule['pain'], 1);
  });

  test('week activity and level achievements unlock once', () async {
    for (var i = 0; i < 7; i++) {
      await cubit.recordVisit();
      today = DateTime(today.year, today.month, today.day + 1, 12);
    }
    expect(
        cubit.state.progress.unlockedAchievementIds, contains('week_streak'));
    await cubit.addXP(4500);
    expect(cubit.state.progress.unlockedAchievementIds, contains('level_5'));
    expect(cubit.state.progress.totalXP, 5300);
    await cubit.addXP(0);
    expect(cubit.state.progress.totalXP, 5300);
  });

  test('pending writes keep their original owner when profiles change',
      () async {
    final write = cubit.recordPainEntry();
    await storage.activate('bob');
    cubit.init('bob');
    await write;
    expect(cubit.state.progress.totalXP, 0);
    await cubit.recordAvatarEdit();
    await storage.activate('alice');
    cubit.init('alice');
    expect(cubit.state.progress.totalXP, 50);
    expect(cubit.state.progress.unlockedAchievementIds, ['first_pain_record']);
  });
}
