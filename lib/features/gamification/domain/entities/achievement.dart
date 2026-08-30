import 'package:equatable/equatable.dart';

enum AchievementCategory {
  postura,
  dolor,
  respiracion,
  actitud,
  trabajo,
  avatar,
  general
}

class Achievement extends Equatable {
  final String id;
  final String title;
  final String description;
  final AchievementCategory category;
  final int xpReward;
  final String emoji;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.xpReward,
    required this.emoji,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({bool? isUnlocked, DateTime? unlockedAt}) => Achievement(
        id: id,
        title: title,
        description: description,
        category: category,
        xpReward: xpReward,
        emoji: emoji,
        isUnlocked: isUnlocked ?? this.isUnlocked,
        unlockedAt: unlockedAt ?? this.unlockedAt,
      );

  static List<Achievement> get defaults => [
        const Achievement(
          id: 'first_pain_record',
          title: 'Primera Alerta',
          description: 'Registraste tu primer dolor',
          category: AchievementCategory.dolor,
          xpReward: 50,
          emoji: '📍',
        ),
        const Achievement(
          id: 'pain_streak_3',
          title: 'Constante',
          description: '3 días seguidos con ejercicios de dolor',
          category: AchievementCategory.dolor,
          xpReward: 100,
          emoji: '💪',
        ),
        const Achievement(
          id: 'first_breath_session',
          title: 'Primera Respiración',
          description: 'Completaste tu primera sesión de respiración',
          category: AchievementCategory.respiracion,
          xpReward: 50,
          emoji: '🌬️',
        ),
        const Achievement(
          id: 'breath_streak_7',
          title: 'Maestro del Aliento',
          description: '7 sesiones de respiración completadas',
          category: AchievementCategory.respiracion,
          xpReward: 200,
          emoji: '🧘',
        ),
        const Achievement(
          id: 'first_avatar_edit',
          title: 'Estilista Digital',
          description: 'Personalizaste tu avatar por primera vez',
          category: AchievementCategory.avatar,
          xpReward: 75,
          emoji: '✨',
        ),
        const Achievement(
          id: 'level_5',
          title: 'En Forma',
          description: 'Alcanzaste el nivel 5',
          category: AchievementCategory.general,
          xpReward: 300,
          emoji: '⭐',
        ),
        const Achievement(
          id: 'week_streak',
          title: 'Semana Activa',
          description: '7 días consecutivos usando ErgoWorkCoach',
          category: AchievementCategory.general,
          xpReward: 500,
          emoji: '🔥',
        ),
      ];

  @override
  List<Object?> get props => [id, isUnlocked, unlockedAt];
}
