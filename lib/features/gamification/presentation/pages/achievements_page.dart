import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/achievement.dart';
import '../cubit/gamification_cubit.dart';
import '../cubit/gamification_state.dart';
import '../utils/achievement_icon.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GamificationCubit, GamificationState>(
      builder: (context, state) {
        final unlocked = state.achievements.where((a) => a.isUnlocked).toList();
        final locked = state.achievements.where((a) => !a.isUnlocked).toList();

        return Scaffold(
          appBar: AppBar(title: const Text('Mis Logros')),
          body: ListView(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            children: [
              if (state.error != null)
                Text(state.error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              // XP y nivel
              Container(
                padding: const EdgeInsets.all(AppDimensions.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondary, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nivel ${state.progress.currentLevel}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800)),
                            Text('${state.progress.totalXP} XP total',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.white70)),
                          ],
                        ),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                              color: Colors.white24, shape: BoxShape.circle),
                          child: const Icon(
                            Icons.stars_rounded,
                            size: 34,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.md),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: state.progress.levelProgress.clamp(0.0, 1.0),
                        backgroundColor: Colors.white24,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${state.progress.xpInCurrentLevel} / ${state.progress.xpForNextLevel} XP',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),

              if (unlocked.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.xl),
                Text('Desbloqueados (${unlocked.length})',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppDimensions.md),
                _AchievementGrid(achievements: unlocked),
              ],

              const SizedBox(height: AppDimensions.xl),
              Text('Por desbloquear (${locked.length})',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppDimensions.md),
              _AchievementGrid(achievements: locked),
            ],
          ),
        );
      },
    );
  }
}

class _AchievementGrid extends StatelessWidget {
  final List<Achievement> achievements;
  const _AchievementGrid({required this.achievements});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, i) {
        final a = achievements[i];
        final isUnlocked = a.isUnlocked;
        return Container(
          padding: const EdgeInsets.all(AppDimensions.md),
          decoration: BoxDecoration(
            color: isUnlocked
                ? AppColors.accent.withValues(alpha: 0.1)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(
              color: isUnlocked
                  ? AppColors.accent.withValues(alpha: 0.4)
                  : Theme.of(context).dividerColor,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isUnlocked ? iconForAchievement(a) : Icons.lock_rounded,
                size: 32,
                color: isUnlocked ? AppColors.accent : AppColors.textMutedDark,
              ),
              const SizedBox(height: 8),
              Text(
                a.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color:
                          isUnlocked ? null : Theme.of(context).disabledColor,
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (isUnlocked) ...[
                const SizedBox(height: 4),
                Text('+${a.xpReward} XP',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: AppColors.accent)),
              ],
            ],
          ),
        );
      },
    );
  }
}
