import 'package:equatable/equatable.dart';

class UserProgress extends Equatable {
  final String userId;
  final int totalXP;
  final int currentLevel;
  final List<String> unlockedAchievementIds;
  final Map<String, int> streaksByModule;
  final int weeklyRanking;

  const UserProgress({
    required this.userId,
    this.totalXP = 0,
    this.currentLevel = 1,
    this.unlockedAchievementIds = const [],
    this.streaksByModule = const {},
    this.weeklyRanking = 0,
  });

  int get xpForNextLevel => currentLevel * 500;
  int get xpInCurrentLevel => totalXP - _xpForLevel(currentLevel - 1);
  double get levelProgress => xpInCurrentLevel / xpForNextLevel;

  int _xpForLevel(int level) {
    if (level <= 0) return 0;
    return level * (level + 1) * 250;
  }

  UserProgress addXP(int xp) {
    if (xp < 0) throw ArgumentError.value(xp, 'xp', 'Must not be negative');
    final newTotalXP = totalXP + xp;
    final newLevel = _calculateLevel(newTotalXP);
    return UserProgress(
      userId: userId,
      totalXP: newTotalXP,
      currentLevel: newLevel,
      unlockedAchievementIds: unlockedAchievementIds,
      streaksByModule: streaksByModule,
      weeklyRanking: weeklyRanking,
    );
  }

  int _calculateLevel(int xp) {
    int level = 1;
    while (_xpForLevel(level) <= xp) {
      level++;
    }
    return level;
  }

  UserProgress unlockAchievement(String achievementId) => UserProgress(
        userId: userId,
        totalXP: totalXP,
        currentLevel: currentLevel,
        unlockedAchievementIds: [...unlockedAchievementIds, achievementId],
        streaksByModule: streaksByModule,
        weeklyRanking: weeklyRanking,
      );

  @override
  List<Object?> get props => [
        userId,
        totalXP,
        currentLevel,
        unlockedAchievementIds,
        streaksByModule,
        weeklyRanking
      ];
}
