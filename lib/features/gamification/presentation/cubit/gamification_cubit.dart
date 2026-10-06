import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/user_local_storage.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/user_progress.dart';
import 'gamification_state.dart';

class GamificationCubit extends Cubit<GamificationState> {
  final UserLocalStorage storage;
  final DateTime Function() now;
  Future<void> _pendingWrite = Future.value();
  int _breathingSessions = 0;
  Map<String, String> _lastActivityDays = {};

  GamificationCubit(this.storage, {DateTime Function()? now})
      : now = now ?? DateTime.now,
        super(GamificationState.initial('guest'));

  void init(String userId) {
    _breathingSessions = 0;
    _lastActivityDays = {};
    emit(GamificationState.initial(userId));
    final raw = storage.preferences.get(storage.keyFor('progress'));
    if (raw == null) return;
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      final xp = data['totalXP'] as int;
      final unlocked = Map<String, String>.from(data['unlocked'] as Map);
      final achievements = Achievement.defaults.map((achievement) {
        final date = unlocked[achievement.id];
        return date == null
            ? achievement
            : achievement.copyWith(
                isUnlocked: true,
                unlockedAt: DateTime.parse(date),
              );
      }).toList();
      final streaks = Map<String, int>.from(data['streaks'] as Map? ?? {});
      final sessions = data['breathingSessions'] as int? ?? 0;
      final days =
          Map<String, String>.from(data['lastActivityDays'] as Map? ?? {});
      if (xp < 0 || sessions < 0 || streaks.values.any((value) => value < 0)) {
        throw const FormatException('Invalid progress');
      }
      for (final day in days.values) {
        DateTime.parse(day);
      }
      final progress = UserProgress(
        userId: userId,
        unlockedAchievementIds:
            achievements.where((a) => a.isUnlocked).map((a) => a.id).toList(),
        streaksByModule: streaks,
      ).addXP(xp);
      _breathingSessions = sessions;
      _lastActivityDays = days;
      emit(GamificationState(progress: progress, achievements: achievements));
    } catch (_) {
      emit(state.copyWith(error: 'No se pudo leer el progreso guardado.'));
    }
  }

  void reset() {
    _breathingSessions = 0;
    _lastActivityDays = {};
    emit(GamificationState.initial('guest'));
  }

  Future<void> addXP(int xp) {
    final newProgress = state.progress.addXP(xp);
    emit(state.copyWith(progress: newProgress));
    _checkLevel();
    return _persist();
  }

  Future<void> tryUnlockAchievement(String achievementId) {
    _unlock(achievementId);
    _checkLevel();
    return _persist();
  }

  Future<void> recordPainEntry() {
    _recordDay('general');
    _unlock('first_pain_record');
    _checkLevel();
    return _persist();
  }

  Future<void> recordAvatarEdit() {
    _recordDay('general');
    _unlock('first_avatar_edit');
    _checkLevel();
    return _persist();
  }

  Future<void> completeBreathingSession() {
    _breathingSessions++;
    emit(state.copyWith(progress: state.progress.addXP(50)));
    _recordDay('general');
    _unlock('first_breath_session');
    if (_breathingSessions >= 7) _unlock('breath_streak_7');
    _checkLevel();
    return _persist();
  }

  Future<void> recordExerciseCompletion() {
    _recordDay('general');
    _recordDay('pain');
    if ((state.progress.streaksByModule['pain'] ?? 0) >= 3) {
      _unlock('pain_streak_3');
    }
    _checkLevel();
    return _persist();
  }

  Future<void> recordVisit() {
    _recordDay('general');
    _checkLevel();
    return _persist();
  }

  void _recordDay(String module) {
    final local = now().toLocal();
    // Compare calendar dates, including across daylight-saving changes.
    final today = DateTime.utc(local.year, local.month, local.day);
    final previous = DateTime.tryParse(_lastActivityDays[module] ?? '');
    if (previous != null && !today.isAfter(previous)) return;
    final streaks = Map<String, int>.of(state.progress.streaksByModule);
    streaks[module] = previous != null && today.difference(previous).inDays == 1
        ? (streaks[module] ?? 0) + 1
        : 1;
    _lastActivityDays[module] = today.toIso8601String();
    final progress = state.progress;
    emit(state.copyWith(
        progress: UserProgress(
      userId: progress.userId,
      totalXP: progress.totalXP,
      currentLevel: progress.currentLevel,
      unlockedAchievementIds: progress.unlockedAchievementIds,
      streaksByModule: streaks,
    )));
    if ((streaks['general'] ?? 0) >= 7) _unlock('week_streak');
  }

  void _checkLevel() {
    if (state.progress.currentLevel >= 5) _unlock('level_5');
  }

  void _unlock(String achievementId) {
    if (state.progress.unlockedAchievementIds.contains(achievementId)) return;

    final achievement = state.achievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => const Achievement(
        id: '',
        title: '',
        description: '',
        category: AchievementCategory.general,
        xpReward: 0,
        emoji: '',
      ),
    );
    if (achievement.id.isEmpty) return;

    final unlockedAchievement = achievement.copyWith(
      isUnlocked: true,
      unlockedAt: now(),
    );

    final updatedAchievements = state.achievements
        .map((a) => a.id == achievementId ? unlockedAchievement : a)
        .toList();

    final newProgress = state.progress
        .unlockAchievement(achievementId)
        .addXP(achievement.xpReward);

    emit(state.copyWith(
      progress: newProgress,
      achievements: updatedAchievements,
      recentlyUnlocked: unlockedAchievement,
    ));
  }

  void clearRecentUnlock() => emit(state.copyWith(clearUnlocked: true));

  Future<void> _persist() {
    if (storage.userId != state.progress.userId) return Future.value();
    final key = storage.keyFor('progress');
    final userId = state.progress.userId;
    final data = jsonEncode({
      'totalXP': state.progress.totalXP,
      'unlocked': {
        for (final a in state.achievements.where((a) => a.isUnlocked))
          a.id: a.unlockedAt!.toIso8601String()
      },
      'breathingSessions': _breathingSessions,
      'streaks': state.progress.streaksByModule,
      'lastActivityDays': _lastActivityDays,
    });
    _pendingWrite = _pendingWrite.then((_) async {
      try {
        await storage.writeString(key, data);
        if (!isClosed && state.progress.userId == userId) {
          emit(state.copyWith(clearError: true));
        }
      } catch (_) {
        if (!isClosed && state.progress.userId == userId) {
          emit(state.copyWith(error: 'No se pudo guardar el progreso.'));
        }
      }
    });
    return _pendingWrite;
  }

  @override
  Future<void> close() async {
    await _pendingWrite;
    return super.close();
  }
}
