import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/achievement.dart';
import 'gamification_state.dart';

class GamificationCubit extends Cubit<GamificationState> {
  GamificationCubit() : super(GamificationState.initial('guest'));

  void init(String userId) {
    emit(GamificationState.initial(userId));
  }

  void addXP(int xp) {
    final newProgress = state.progress.addXP(xp);
    emit(state.copyWith(progress: newProgress));
  }

  void tryUnlockAchievement(String achievementId) {
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
      unlockedAt: DateTime.now(),
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
}
