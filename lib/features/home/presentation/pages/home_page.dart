import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/router/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../gamification/presentation/cubit/gamification_cubit.dart';
import '../../../gamification/presentation/cubit/gamification_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 760;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ErgoWorkCoach'),
        actions: [
          BlocBuilder<GamificationCubit, GamificationState>(
            builder: (context, state) => Padding(
              padding: const EdgeInsets.only(right: AppDimensions.md),
              child: Chip(
                avatar: const Icon(
                  Icons.stars_rounded,
                  size: 16,
                  color: AppColors.accent,
                ),
                label: Text(
                    'Nv.${state.progress.currentLevel} · ${state.progress.totalXP} XP',
                    style: Theme.of(context).textTheme.labelSmall),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: ListView(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            children: [
              // Saludo
              Row(
                children: [
                  Text('¡Hola!',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(width: AppDimensions.sm),
                  const Icon(Icons.waving_hand_rounded,
                      color: AppColors.accent),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Tu salud es lo más importante hoy.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppDimensions.xl),

              // Módulos principales
              Text('Módulos', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppDimensions.md),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isWide ? 3 : 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: isWide ? 1.5 : 1.3,
                children: [
                  _ModuleCard(
                    icon: Icons.monitor_heart_outlined,
                    title: 'Pain Manager',
                    subtitle: 'Registra y trata tu dolor',
                    color: AppColors.painModule,
                    onTap: () => context.go(RouteNames.pain),
                  ),
                  _ModuleCard(
                    icon: Icons.air_rounded,
                    title: 'Respiración',
                    subtitle: '8 técnicas guiadas',
                    color: AppColors.breathingModule,
                    onTap: () => context.go(RouteNames.breathing),
                  ),
                  _ModuleCard(
                    icon: Icons.accessibility_new_rounded,
                    title: 'Avatar',
                    subtitle: 'Personaliza tu coach',
                    color: AppColors.primary,
                    onTap: () => context.go(RouteNames.avatar),
                  ),
                  _ModuleCard(
                    icon: Icons.emoji_events_rounded,
                    title: 'Logros',
                    subtitle: 'Tu progreso y racha',
                    color: AppColors.gamificationModule,
                    onTap: () => context.go(RouteNames.achievements),
                  ),
                  _ModuleCard(
                    icon: Icons.work_outline_rounded,
                    title: 'Work Coach',
                    subtitle: 'Próximamente',
                    color: AppColors.workModule,
                    onTap: null,
                    isLocked: true,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.xl),

              // Consejo del día
              Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_rounded,
                      size: 28,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Consejo del día',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(color: AppColors.secondaryLight)),
                          const SizedBox(height: 2),
                          Text(
                            'Cada 45 minutos, realiza una pausa activa de 5 minutos para reducir la tensión muscular.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  final bool isLocked;

  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      child: Ink(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isLocked ? 0.05 : 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          border:
              Border.all(color: color.withValues(alpha: isLocked ? 0.15 : 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 28,
                  color: isLocked ? Theme.of(context).disabledColor : color,
                ),
                const Spacer(),
                if (isLocked)
                  const Icon(Icons.lock_rounded,
                      size: 14, color: AppColors.textMutedDark),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isLocked ? Theme.of(context).disabledColor : null,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isLocked ? Theme.of(context).disabledColor : color,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
