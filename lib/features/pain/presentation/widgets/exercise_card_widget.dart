import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/exercise.dart';

class ExerciseCardWidget extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback? onStart;

  const ExerciseCardWidget({super.key, required this.exercise, this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.painModule.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Etapa ${exercise.evaStage}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.painModule,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const Spacer(),
              _InfoChip(
                  icon: Icons.repeat_rounded, label: '${exercise.reps} reps'),
              const SizedBox(width: 8),
              _InfoChip(
                  icon: Icons.schedule_rounded,
                  label: '${exercise.setsPerDay}x/día'),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(exercise.name, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(exercise.description,
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppDimensions.sm),
          Row(
            children: [
              const Icon(Icons.tips_and_updates_rounded,
                  size: 14, color: AppColors.accent),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  exercise.postureFocus,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.accent),
                ),
              ),
            ],
          ),
          if (exercise.holdSeconds > 0) ...[
            const SizedBox(height: AppDimensions.xs),
            Row(
              children: [
                const Icon(Icons.timer_rounded,
                    size: 14, color: AppColors.info),
                const SizedBox(width: 4),
                Text(
                  'Mantén ${exercise.holdSeconds} segundos',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.info),
                ),
              ],
            ),
          ],
          if (onStart != null) ...[
            const SizedBox(height: AppDimensions.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.visibility_rounded, size: 18),
                label: const Text('Ver guía'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.painModule,
                  minimumSize: const Size(0, 40),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Theme.of(context).disabledColor),
        const SizedBox(width: 2),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
