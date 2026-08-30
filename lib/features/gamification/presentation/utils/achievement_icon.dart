import 'package:flutter/material.dart';

import '../../domain/entities/achievement.dart';

IconData iconForAchievement(Achievement achievement) {
  switch (achievement.id) {
    case 'first_pain_record':
      return Icons.location_on_rounded;
    case 'pain_streak_3':
      return Icons.fitness_center_rounded;
    case 'first_breath_session':
      return Icons.air_rounded;
    case 'breath_streak_7':
      return Icons.self_improvement_rounded;
    case 'first_avatar_edit':
      return Icons.auto_awesome_rounded;
    case 'level_5':
      return Icons.stars_rounded;
    case 'week_streak':
      return Icons.local_fire_department_rounded;
    default:
      return Icons.emoji_events_rounded;
  }
}
