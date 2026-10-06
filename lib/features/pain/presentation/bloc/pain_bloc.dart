import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_exercises_by_body_region.dart';
import '../../domain/usecases/get_pain_history.dart';
import '../../domain/usecases/record_pain_entry.dart';
import 'pain_event.dart';
import 'pain_state.dart';

class PainBloc extends Bloc<PainEvent, PainState> {
  final GetExercisesByBodyRegion getExercisesByBodyRegion;
  final RecordPainEntry recordPainEntry;
  final GetPainHistory getPainHistory;
  int _exerciseRequestId = 0;
  int _historyRequestId = 0;

  PainBloc({
    required this.getExercisesByBodyRegion,
    required this.recordPainEntry,
    required this.getPainHistory,
  }) : super(const PainState()) {
    on<PainRegionSelected>(_onRegionSelected);
    on<PainEvaChanged>(_onEvaChanged);
    on<PainTypeSelected>(_onTypeSelected);
    on<PainRecordSaved>(_onRecordSaved);
    on<PainRecordSavedAndExercisesRequested>(
      _onRecordSavedAndExercisesRequested,
    );
    on<PainHistoryLoaded>(_onHistoryLoaded);
    on<PainSaveAcknowledged>(_onSaveAcknowledged);
    on<PainErrorAcknowledged>(_onErrorAcknowledged);
    on<PainExercisesRequested>(_onExercisesRequested);
  }

  void _onRegionSelected(PainRegionSelected event, Emitter<PainState> emit) {
    _exerciseRequestId++;
    // Reset selectedType when changing region — avoids stale type from previous selection.
    emit(state.copyWith(
      selectedRegion: event.region,
      evaScore: 0,
      exercises: const [],
      isLoadingExercises: false,
      recordSaved: false,
      clearError: true,
      clearType: true,
    ));
  }

  void _onEvaChanged(PainEvaChanged event, Emitter<PainState> emit) {
    if (event.evaScore == state.evaScore) return;
    _exerciseRequestId++;
    emit(state.copyWith(
        evaScore: event.evaScore.clamp(0, 10),
        exercises: const [],
        isLoadingExercises: false,
        clearError: true));
  }

  void _onTypeSelected(PainTypeSelected event, Emitter<PainState> emit) {
    emit(state.copyWith(selectedType: event.type));
  }

  Future<void> _onRecordSaved(
      PainRecordSaved event, Emitter<PainState> emit) async {
    if (state.isSaving) return;
    emit(state.copyWith(isSaving: true, recordSaved: false, clearError: true));
    final result = await recordPainEntry(event.record);
    if (emit.isDone) return;
    result.fold(
      (failure) =>
          emit(state.copyWith(isSaving: false, error: failure.message)),
      (_) => emit(state.copyWith(isSaving: false, recordSaved: true)),
    );
  }

  Future<void> _onRecordSavedAndExercisesRequested(
    PainRecordSavedAndExercisesRequested event,
    Emitter<PainState> emit,
  ) async {
    if (state.isSaving) return;
    final requestId = ++_exerciseRequestId;
    emit(state.copyWith(
      isSaving: true,
      isLoadingExercises: true,
      exercises: const [],
      recordSaved: false,
      clearError: true,
    ));

    final saveResult = await recordPainEntry(event.record);
    if (emit.isDone) return;
    if (saveResult.isLeft()) {
      saveResult.fold(
        (failure) => emit(state.copyWith(
          isSaving: false,
          isLoadingExercises: requestId == _exerciseRequestId
              ? false
              : state.isLoadingExercises,
          error: failure.message,
        )),
        (_) {},
      );
      return;
    }

    emit(state.copyWith(isSaving: false, recordSaved: true));
    if (requestId != _exerciseRequestId) return;

    final exerciseResult = await getExercisesByBodyRegion(
      ExerciseParams(
        region: event.record.region,
        evaScore: event.record.evaScore,
      ),
    );
    if (emit.isDone || requestId != _exerciseRequestId) return;
    exerciseResult.fold(
      (failure) => emit(state.copyWith(
        isSaving: false,
        isLoadingExercises: false,
        error: failure.message,
      )),
      (exercises) => emit(state.copyWith(
        isSaving: false,
        isLoadingExercises: false,
        exercises: exercises,
      )),
    );
  }

  Future<void> _onHistoryLoaded(
      PainHistoryLoaded event, Emitter<PainState> emit) async {
    final requestId = ++_historyRequestId;
    emit(state.copyWith(isLoadingHistory: true));
    final result = await getPainHistory();
    if (emit.isDone || requestId != _historyRequestId) return;
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoadingHistory: false, error: failure.message)),
      (history) =>
          emit(state.copyWith(isLoadingHistory: false, history: history)),
    );
  }

  void _onSaveAcknowledged(
      PainSaveAcknowledged event, Emitter<PainState> emit) {
    emit(state.copyWith(recordSaved: false));
  }

  void _onErrorAcknowledged(
      PainErrorAcknowledged event, Emitter<PainState> emit) {
    emit(state.copyWith(clearError: true));
  }

  Future<void> _onExercisesRequested(
      PainExercisesRequested event, Emitter<PainState> emit) async {
    final requestId = ++_exerciseRequestId;
    emit(state.copyWith(
        isLoadingExercises: true, exercises: const [], clearError: true));
    final result = await getExercisesByBodyRegion(
      ExerciseParams(region: event.region, evaScore: event.evaScore),
    );
    if (emit.isDone || requestId != _exerciseRequestId) return;
    result.fold(
      (failure) => emit(
          state.copyWith(isLoadingExercises: false, error: failure.message)),
      (exercises) =>
          emit(state.copyWith(isLoadingExercises: false, exercises: exercises)),
    );
  }
}
