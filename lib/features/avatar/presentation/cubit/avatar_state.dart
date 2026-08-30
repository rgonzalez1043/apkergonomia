import 'package:equatable/equatable.dart';

import '../../../../shared/models/user_profile_model.dart';

class AvatarState extends Equatable {
  final AvatarConfig config;
  final bool isLoading;
  final bool isSaving;
  final bool saveSuccess;
  final String? error;

  const AvatarState({
    this.config = const AvatarConfig(),
    this.isLoading = false,
    this.isSaving = false,
    this.saveSuccess = false,
    this.error,
  });

  AvatarState copyWith({
    AvatarConfig? config,
    bool? isLoading,
    bool? isSaving,
    bool? saveSuccess,
    String? error,
    bool clearError = false,
  }) {
    return AvatarState(
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [config, isLoading, isSaving, saveSuccess, error];
}
