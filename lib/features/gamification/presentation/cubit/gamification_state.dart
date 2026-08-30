import 'package:equatable/equatable.dart';

import '../../domain/entities/achievement.dart';
import '../../domain/entities/user_progress.dart';

class GamificationState extends Equatable {
  final UserProgress progress;
  final List<Achievement> achievements;
  final Achievement? recentlyUnlocked;

  const GamificationState({
    required this.progress,
    this.achievements = const [],
    this.recentlyUnlocked,
  });

  factory GamificationState.initial(String userId) => GamificationState(
        progress: UserProgress(userId: userId),
        achievements: Achievement.defaults,
      );

  GamificationState copyWith({
    UserProgress? progress,
    List<Achievement>? achievements,
    Achievement? recentlyUnlocked,
    bool clearUnlocked = false,
  }) {
    return GamificationState(
      progress: progress ?? this.progress,
      achievements: achievements ?? this.achievements,
      recentlyUnlocked:
          clearUnlocked ? null : (recentlyUnlocked ?? this.recentlyUnlocked),
    );
  }

  @override
  List<Object?> get props => [progress, achievements, recentlyUnlocked];
}
