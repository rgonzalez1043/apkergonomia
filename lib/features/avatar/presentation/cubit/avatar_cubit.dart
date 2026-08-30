import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../shared/models/user_profile_model.dart';
import '../../../avatar/domain/usecases/load_avatar_config.dart';
import '../../../avatar/domain/usecases/save_avatar_config.dart';
import 'avatar_state.dart';

class AvatarCubit extends Cubit<AvatarState> {
  final LoadAvatarConfig loadAvatarConfig;
  final SaveAvatarConfig saveAvatarConfig;

  AvatarCubit({
    required this.loadAvatarConfig,
    required this.saveAvatarConfig,
  }) : super(const AvatarState());

  Future<void> loadConfig() async {
    emit(state.copyWith(isLoading: true, clearError: true, saveSuccess: false));
    final result = await loadAvatarConfig(const NoParams());
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (config) => emit(state.copyWith(isLoading: false, config: config)),
    );
  }

  void updateConfig(AvatarConfig config) {
    emit(state.copyWith(config: config, saveSuccess: false, clearError: true));
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
    emit(state.copyWith(isSaving: true, clearError: true, saveSuccess: false));
    final result = await saveAvatarConfig(state.config);
    result.fold(
      (failure) =>
          emit(state.copyWith(isSaving: false, error: failure.message)),
      (_) => emit(state.copyWith(isSaving: false, saveSuccess: true)),
    );
  }
}
