import 'package:equatable/equatable.dart';

import '../../../../core/constants/body_region.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/pain_record.dart';

class PainState extends Equatable {
  final BodyRegion? selectedRegion;
  final int evaScore;
  final PainType? selectedType;
  final List<Exercise> exercises;
  final List<PainRecord> history;
  final bool isLoadingExercises;
  final bool isLoadingHistory;
  final bool isSaving;
  final String? error;
  final bool recordSaved;

  const PainState({
    this.selectedRegion,
    this.evaScore = 0,
    this.selectedType,
    this.exercises = const [],
    this.history = const [],
    this.isLoadingExercises = false,
    this.isLoadingHistory = false,
    this.isSaving = false,
    this.error,
    this.recordSaved = false,
  });

  /// Convenience getter for backward-compatible checks — true if anything is loading.
  bool get isLoading => isLoadingExercises || isLoadingHistory;

  PainState copyWith({
    BodyRegion? selectedRegion,
    int? evaScore,
    PainType? selectedType,
    List<Exercise>? exercises,
    List<PainRecord>? history,
    bool? isLoadingExercises,
    bool? isLoadingHistory,
    bool? isSaving,
    String? error,
    bool? recordSaved,
    bool clearError = false,
    bool clearRegion = false,
    bool clearType = false,
  }) {
    return PainState(
      selectedRegion:
          clearRegion ? null : (selectedRegion ?? this.selectedRegion),
      evaScore: evaScore ?? this.evaScore,
      selectedType: clearType ? null : (selectedType ?? this.selectedType),
      exercises: exercises ?? this.exercises,
      history: history ?? this.history,
      isLoadingExercises: isLoadingExercises ?? this.isLoadingExercises,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
      recordSaved: recordSaved ?? this.recordSaved,
    );
  }

  @override
  List<Object?> get props => [
        selectedRegion,
        evaScore,
        selectedType,
        exercises,
        history,
        isLoadingExercises,
        isLoadingHistory,
        isSaving,
        error,
        recordSaved,
      ];
}
