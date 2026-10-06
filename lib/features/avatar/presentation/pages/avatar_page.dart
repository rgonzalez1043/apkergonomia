import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../config/router/route_names.dart';
import '../../../../shared/models/user_profile_model.dart';
import '../../../avatar/presentation/cubit/avatar_cubit.dart';
import '../../../avatar/presentation/cubit/avatar_state.dart';
import '../../../avatar/presentation/widgets/avatar_preview_widget.dart';
import '../../../gamification/presentation/cubit/gamification_cubit.dart';

class AvatarPage extends StatelessWidget {
  const AvatarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.home),
        ),
        title: const Text('Avatar Work Coach'),
      ),
      body: BlocConsumer<AvatarCubit, AvatarState>(
        listenWhen: (previous, current) =>
            !previous.saveSuccess && current.saveSuccess,
        listener: (context, _) =>
            context.read<GamificationCubit>().recordAvatarEdit(),
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              await context.read<AvatarCubit>().loadConfig();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (state.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else ...[
                        AvatarPreviewWidget(config: state.config),
                        const SizedBox(height: AppDimensions.lg),
                        _buildSectionTitle(context, 'Emoción'),
                        Wrap(
                          spacing: AppDimensions.sm,
                          children: AvatarEmotion.values.map((emotion) {
                            final selected =
                                emotion == state.config.currentEmotion;
                            return ChoiceChip(
                              label: Text(_emotionLabel(emotion)),
                              selected: selected,
                              onSelected: (_) => context
                                  .read<AvatarCubit>()
                                  .updateEmotion(emotion),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppDimensions.lg),
                        _buildSectionTitle(context, 'Tono de piel'),
                        Wrap(
                          spacing: AppDimensions.sm,
                          children: SkinTone.values.map((tone) {
                            final selected = tone == state.config.skinTone;
                            return ChoiceChip(
                              label: Text(_skinToneLabel(tone)),
                              selected: selected,
                              onSelected: (_) => context
                                  .read<AvatarCubit>()
                                  .updateSkinTone(tone),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppDimensions.lg),
                        _buildSectionTitle(context, 'Color de pelo'),
                        Wrap(
                          spacing: AppDimensions.sm,
                          runSpacing: AppDimensions.sm,
                          children: _colorSwatches.map((color) {
                            final hex = _colorHex(color);
                            return GestureDetector(
                              onTap: () => context
                                  .read<AvatarCubit>()
                                  .updateHairColor(hex),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: state.config.hairColor == hex
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppDimensions.lg),
                        _buildSectionTitle(context, 'Color de top'),
                        Wrap(
                          spacing: AppDimensions.sm,
                          runSpacing: AppDimensions.sm,
                          children: _colorSwatches.map((color) {
                            final hex = _colorHex(color);
                            return GestureDetector(
                              onTap: () => context
                                  .read<AvatarCubit>()
                                  .updateTopColor(hex),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: state.config.topColor == hex
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppDimensions.lg),
                        _buildSectionTitle(context, 'Color de pantalón'),
                        Wrap(
                          spacing: AppDimensions.sm,
                          runSpacing: AppDimensions.sm,
                          children: _colorSwatches.map((color) {
                            final hex = _colorHex(color);
                            return GestureDetector(
                              onTap: () => context
                                  .read<AvatarCubit>()
                                  .updatePantsColor(hex),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: state.config.pantsColor == hex
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppDimensions.lg),
                        if (state.error != null)
                          Text(state.error!,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error)),
                        if (state.saveSuccess)
                          Text('Avatar guardado correctamente',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.primary)),
                        const SizedBox(height: AppDimensions.lg),
                        ElevatedButton.icon(
                          onPressed: state.isSaving
                              ? null
                              : () => context.read<AvatarCubit>().save(),
                          icon: state.isSaving
                              ? const CircularProgressIndicator(strokeWidth: 2)
                              : const Icon(Icons.save),
                          label: const Text('Guardar avatar'),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  String _colorHex(Color color) {
    // ignore: deprecated_member_use
    final rawValue = color.value;
    return rawValue
        .toRadixString(16)
        .padLeft(8, '0')
        .substring(2)
        .toUpperCase();
  }

  String _emotionLabel(AvatarEmotion emotion) {
    switch (emotion) {
      case AvatarEmotion.happy:
        return 'Feliz';
      case AvatarEmotion.neutral:
        return 'Neutral';
      case AvatarEmotion.focused:
        return 'Concentrado';
      case AvatarEmotion.proud:
        return 'Orgulloso';
      case AvatarEmotion.concerned:
        return 'Cuidadoso';
    }
  }

  String _skinToneLabel(SkinTone tone) {
    switch (tone) {
      case SkinTone.light:
        return 'Claro';
      case SkinTone.mediumLight:
        return 'Claro medio';
      case SkinTone.medium:
        return 'Medio';
      case SkinTone.mediumDark:
        return 'Oscuro medio';
      case SkinTone.dark:
        return 'Oscuro';
    }
  }

  List<Color> get _colorSwatches => const [
        Color(0xFF1F2937),
        Color(0xFF2563EB),
        Color(0xFF10B981),
        Color(0xFFF59E0B),
        Color(0xFFEF4444),
        Color(0xFF8B5CF6),
      ];
}
