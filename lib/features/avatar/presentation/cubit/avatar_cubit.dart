import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../shared/models/user_profile_model.dart';
import '../../../avatar/domain/usecases/load_avatar_config.dart';
import '../../../avatar/domain/usecases/save_avatar_config.dart';
import 'avatar_state.dart';

class AvatarCubit extends Cubit<AvatarState> {
  final LoadAvatarConfig loadAvatarConfig;
  final SaveAvatarConfig saveAvatarConfig;
  int _revision = 0;

  AvatarCubit({
    required this.loadAvatarConfig,
    required this.saveAvatarConfig,
  }) : super(const AvatarState());

  Future<void> loadConfig() async {
    if (state.isSaving) return;
    final revision = ++_revision;
    emit(state.copyWith(isLoading: true, clearError: true, saveSuccess: false));
    final result = await loadAvatarConfig(const NoParams());
    if (isClosed || revision != _revision) return;
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (config) => emit(state.copyWith(isLoading: false, config: config)),
    );
  }

  void updateConfig(AvatarConfig config) {
    _revision++;
    emit(state.copyWith(
        config: config,
        isLoading: false,
        saveSuccess: false,
        clearError: true));
  }

  void updateEmotion(AvatarEmotion emotion) {
    updateConfig(state.config.copyWith(currentEmotion: emotion));
  }

  void updateSkinTone(SkinTone skinTone) {
    updateConfig(state.config.copyWith(skinTone: skinTone));
  }

  void updateHairStyle(HairStyle style) {
    updateConfig(state.config.copyWith(hair: style));
  }

  void updateHairColor(String hairColor) {
    updateConfig(state.config.copyWith(hairColor: hairColor));
  }

  void updateTopColor(String color) {
    updateConfig(state.config.copyWith(topColor: color));
  }

  void updatePantsColor(String color) {
    updateConfig(state.config.copyWith(pantsColor: color));
  }

  Future<void> save() async {
    if (state.isSaving || state.isLoading) return;
    final config = state.config;
    emit(state.copyWith(isSaving: true, clearError: true, saveSuccess: false));
    final result = await saveAvatarConfig(config);
    if (isClosed) return;
    result.fold(
      (failure) =>
          emit(state.copyWith(isSaving: false, error: failure.message)),
      (_) => emit(
          state.copyWith(isSaving: false, saveSuccess: state.config == config)),
    );
  }
}
