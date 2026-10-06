import 'package:equatable/equatable.dart';

import '../../domain/entities/achievement.dart';
import '../../domain/entities/user_progress.dart';

class GamificationState extends Equatable {
  final UserProgress progress;
  final List<Achievement> achievements;
  final Achievement? recentlyUnlocked;
  final String? error;

  const GamificationState({
    required this.progress,
    this.achievements = const [],
    this.recentlyUnlocked,
    this.error,
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
    String? error,
    bool clearError = false,
  }) {
    return GamificationState(
      progress: progress ?? this.progress,
      achievements: achievements ?? this.achievements,
      recentlyUnlocked:
          clearUnlocked ? null : (recentlyUnlocked ?? this.recentlyUnlocked),
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [progress, achievements, recentlyUnlocked, error];
}
