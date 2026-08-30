import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../features/gamification/domain/entities/achievement.dart';
import '../../features/gamification/presentation/utils/achievement_icon.dart';

class AchievementBadgeWidget extends StatelessWidget {
  final Achievement achievement;
  final bool compact;

  const AchievementBadgeWidget({
    super.key,
    required this.achievement,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;
    final color =
        isUnlocked ? AppColors.accent : Theme.of(context).dividerColor;

    if (compact) {
      return Tooltip(
        message: achievement.title,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
          child: Icon(iconForAchievement(achievement), size: 22, color: color),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconForAchievement(achievement), size: 34, color: color),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: isUnlocked ? null : Theme.of(context).disabledColor,
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            achievement.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (isUnlocked) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '+${achievement.xpReward} XP',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppColors.accent),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
