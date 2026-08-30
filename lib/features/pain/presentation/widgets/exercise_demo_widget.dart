import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/exercise.dart';
import 'exercise_media_catalog.dart';
import 'exercise_video_embed.dart';

typedef ExerciseVideoBuilder = Widget Function(
  BuildContext context,
  ExerciseVideo video,
);

/// Exercise guide with an embedded real-person movement demonstration.
class ExerciseDemoWidget extends StatelessWidget {
  final Exercise exercise;
  final int completedReps;
  final VoidCallback onAddRepetition;
  final VoidCallback onReset;
  final ExerciseVideoBuilder? videoBuilder;

  const ExerciseDemoWidget({
    super.key,
    required this.exercise,
    required this.completedReps,
    required this.onAddRepetition,
    required this.onReset,
    this.videoBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final video = ExerciseMediaCatalog.forExercise(exercise.id);
    final targetReps = exercise.reps < 1 ? 1 : exercise.reps;
    final safeCompleted = completedReps.clamp(0, targetReps);
    final progress = safeCompleted / targetReps;
    final isComplete = safeCompleted >= targetReps;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(exercise: exercise),
          const SizedBox(height: AppDimensions.md),
          if (videoBuilder != null)
            videoBuilder!(context, video)
          else
            _ExerciseVideoPlayer(video: video),
          const SizedBox(height: AppDimensions.sm),
          _VideoAttribution(video: video),
          const SizedBox(height: AppDimensions.md),
          Text(
            exercise.description,
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
          const SizedBox(height: AppDimensions.sm),
          _PostureFocus(text: exercise.postureFocus),
          const SizedBox(height: AppDimensions.md),
          _ExerciseStats(exercise: exercise),
          const SizedBox(height: AppDimensions.md),
          const _SafetyNotice(),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  isComplete ? 'Serie completada' : 'Progreso de la serie',
                  maxLines: 2,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: isComplete ? AppColors.success : null,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Text(
                '$safeCompleted / $targetReps',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color:
                          isComplete ? AppColors.success : AppColors.painModule,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            color: isComplete ? AppColors.success : AppColors.painModule,
            backgroundColor: AppColors.painModule.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: isComplete ? null : onAddRepetition,
                  icon: Icon(
                    isComplete
                        ? Icons.check_circle_rounded
                        : Icons.add_task_rounded,
                  ),
                  label: Text(
                    isComplete ? 'Completado' : 'Registrar repetición',
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              IconButton.outlined(
                onPressed: safeCompleted == 0 ? null : onReset,
                tooltip: 'Reiniciar serie',
                icon: const Icon(Icons.replay_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Exercise exercise;

  const _Header({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.painModule.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          child: const Icon(
            Icons.play_circle_outline_rounded,
            color: AppColors.painModule,
          ),
        ),
        const SizedBox(width: AppDimensions.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VIDEO DE MOVIMIENTO REAL',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.painModule,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                exercise.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExerciseVideoPlayer extends StatelessWidget {
  final ExerciseVideo video;

  const _ExerciseVideoPlayer({required this.video});

  @override
  Widget build(BuildContext context) {
    if (!video.isAvailable) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: _VideoUnavailable(),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        child: ColoredBox(
          color: const Color(0xFF101820),
          child: ExerciseVideoEmbed(
            key: ValueKey(video.youtubeVideoId),
            videoId: video.youtubeVideoId,
          ),
        ),
      ),
    );
  }
}

class _VideoUnavailable extends StatelessWidget {
  const _VideoUnavailable();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF101820),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.videocam_off_outlined, color: Colors.white70),
              SizedBox(height: 8),
              Text(
                'Video no disponible. Revisa tu conexión.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoAttribution extends StatelessWidget {
  final ExerciseVideo video;

  const _VideoAttribution({required this.video});

  Future<void> _open(BuildContext context, Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace del video.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!video.isAvailable) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                Icons.verified_outlined,
                size: 17,
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                'Fuente: ${video.sourceLabel}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Wrap(
          spacing: AppDimensions.sm,
          children: [
            TextButton.icon(
              onPressed: () => _open(context, video.sourceUri),
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: const Text('Fuente original'),
            ),
            TextButton.icon(
              onPressed: () => _open(context, video.youtubeUri),
              icon: const Icon(Icons.ondemand_video_rounded, size: 16),
              label: const Text('Abrir en YouTube'),
            ),
          ],
        ),
      ],
    );
  }
}

class _PostureFocus extends StatelessWidget {
  final String text;

  const _PostureFocus({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.center_focus_strong_rounded,
            size: 18,
            color: AppColors.accentDark,
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseStats extends StatelessWidget {
  final Exercise exercise;

  const _ExerciseStats({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.sm,
      runSpacing: AppDimensions.sm,
      children: [
        _Stat(
          icon: Icons.repeat_rounded,
          value: '${exercise.reps}',
          label: 'reps',
        ),
        _Stat(
          icon: Icons.today_rounded,
          value: '${exercise.setsPerDay}',
          label: 'series/día',
        ),
        if (exercise.holdSeconds > 0)
          _Stat(
            icon: Icons.timer_outlined,
            value: '${exercise.holdSeconds}',
            label: 'segundos',
          ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.painModule.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.painModule),
          const SizedBox(width: 5),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(width: 3),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _SafetyNotice extends StatelessWidget {
  const _SafetyNotice();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.health_and_safety_outlined,
          size: 18,
          color: AppColors.info,
        ),
        const SizedBox(width: AppDimensions.sm),
        Expanded(
          child: Text(
            'Haz el movimiento lentamente y sin rebotes. Detente si aumenta el dolor, aparece hormigueo, mareo o debilidad. Un video general no sustituye la indicación de un profesional.',
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.35),
          ),
        ),
      ],
    );
  }
}
