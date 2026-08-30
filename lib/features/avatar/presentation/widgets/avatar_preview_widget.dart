import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/avatar_3d_assets.dart';
import '../../../../shared/models/user_profile_model.dart';
import '../../../../shared/widgets/human_model_viewer.dart';

class AvatarPreviewWidget extends StatelessWidget {
  final AvatarConfig config;

  const AvatarPreviewWidget({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Coach 3D', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppDimensions.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final viewerHeight =
                  (constraints.maxWidth / 0.72).clamp(400.0, 560.0);
              return SizedBox(
                height: viewerHeight,
                child: HumanModelViewer(
                  src: Avatar3DAssets.defaultCoach,
                  alt: 'Avatar 3D del coach',
                  autoRotate: true,
                  cameraControls: true,
                  cameraOrbit: '0deg 78deg 112%',
                  fieldOfView: '28deg',
                  orientation: '0deg 0deg 90deg',
                  badgeLabel: _emotionLabel(config.currentEmotion),
                ),
              );
            },
          ),
          const SizedBox(height: AppDimensions.md),
          Wrap(
            spacing: AppDimensions.sm,
            runSpacing: AppDimensions.sm,
            children: [
              _InfoChip(
                  label: _skinToneLabel(config.skinTone),
                  color: AppColors.primary),
              _InfoChip(
                  label: _hairLabel(config.hair),
                  color: _fromHex(config.hairColor)),
              _InfoChip(label: 'Top', color: _fromHex(config.topColor)),
              _InfoChip(label: 'Pantalon', color: _fromHex(config.pantsColor)),
            ],
          ),
        ],
      ),
    );
  }

  Color _fromHex(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  String _emotionLabel(AvatarEmotion emotion) {
    switch (emotion) {
      case AvatarEmotion.happy:
        return 'Feliz';
      case AvatarEmotion.neutral:
        return 'Neutral';
      case AvatarEmotion.focused:
        return 'Enfoque';
      case AvatarEmotion.proud:
        return 'Orgullo';
      case AvatarEmotion.concerned:
        return 'Cuidado';
    }
  }

  String _skinToneLabel(SkinTone tone) {
    switch (tone) {
      case SkinTone.light:
        return 'Piel clara';
      case SkinTone.mediumLight:
        return 'Piel media clara';
      case SkinTone.medium:
        return 'Piel media';
      case SkinTone.mediumDark:
        return 'Piel media oscura';
      case SkinTone.dark:
        return 'Piel oscura';
    }
  }

  String _hairLabel(HairStyle hair) {
    switch (hair) {
      case HairStyle.short:
        return 'Pelo corto';
      case HairStyle.medium:
        return 'Pelo medio';
      case HairStyle.long:
        return 'Pelo largo';
      case HairStyle.curly:
        return 'Pelo rizado';
      case HairStyle.bald:
        return 'Sin pelo';
    }
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
