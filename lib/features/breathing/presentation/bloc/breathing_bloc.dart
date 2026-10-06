import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_breathing_techniques.dart';
import 'breathing_event.dart';
import 'breathing_state.dart';

class BreathingBloc extends Bloc<BreathingEvent, BreathingState> {
  final GetBreathingTechniques getBreathingTechniques;
  Timer? _timer;
  int _phaseSecondsLeft = 0;

  BreathingBloc({required this.getBreathingTechniques})
      : super(const BreathingState()) {
    on<BreathingTechniquesLoaded>(_onLoad);
    on<BreathingTechniqueSelected>(_onSelected);
    on<BreathingSessionStarted>(_onStart);
    on<BreathingSessionPaused>(_onPause);
    on<BreathingSessionResumed>(_onResume);
    on<BreathingSessionStopped>(_onStop);
    on<BreathingTickAdvanced>(_onTick);
  }

  Future<void> _onLoad(
      BreathingTechniquesLoaded event, Emitter<BreathingState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await getBreathingTechniques();
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (techniques) =>
          emit(state.copyWith(isLoading: false, techniques: techniques)),
    );
  }

  void _onSelected(
      BreathingTechniqueSelected event, Emitter<BreathingState> emit) {
    _timer?.cancel();
    _phaseSecondsLeft = 0;
    emit(state.copyWith(
      selectedTechnique: event.technique,
      phase: BreathingPhase.idle,
      currentCycle: 0,
      secondsRemaining: 0,
      isRunning: false,
      clearError: true,
    ));
  }

  void _onStart(BreathingSessionStarted event, Emitter<BreathingState> emit) {
    final technique = state.selectedTechnique;
    if (technique == null || state.isRunning) return;
    emit(state.copyWith(currentCycle: 0));
    _startPhase(BreathingPhase.inhaling, technique.inhaleSeconds, emit);
  }

  void _startPhase(
      BreathingPhase phase, int seconds, Emitter<BreathingState> emit) {
    _timer?.cancel();
    _phaseSecondsLeft = seconds;
    emit(state.copyWith(
        phase: phase, secondsRemaining: seconds, isRunning: true));
    _timer = Timer.periodic(
        const Duration(seconds: 1), (_) => add(const BreathingTickAdvanced()));
  }

  void _onTick(BreathingTickAdvanced event, Emitter<BreathingState> emit) {
    if (!state.isRunning ||
        state.phase == BreathingPhase.idle ||
        state.phase == BreathingPhase.complete) {
      _timer?.cancel();
      return;
    }
    _phaseSecondsLeft--;
    if (_phaseSecondsLeft > 0) {
      emit(state.copyWith(secondsRemaining: _phaseSecondsLeft));
      return;
    }
    _advancePhase(emit);
  }

  void _advancePhase(Emitter<BreathingState> emit) {
    final technique = state.selectedTechnique;
    if (technique == null) return;

    switch (state.phase) {
      case BreathingPhase.inhaling:
        if (technique.holdAfterInhale > 0) {
          _startPhase(BreathingPhase.holding, technique.holdAfterInhale, emit);
        } else {
          _startPhase(BreathingPhase.exhaling, technique.exhaleSeconds, emit);
        }
      case BreathingPhase.holding:
        _startPhase(BreathingPhase.exhaling, technique.exhaleSeconds, emit);
      case BreathingPhase.exhaling:
        if (technique.holdAfterExhale > 0) {
          _startPhase(BreathingPhase.holdingAfterExhale,
              technique.holdAfterExhale, emit);
        } else {
          _finishCycle(emit);
        }
      case BreathingPhase.holdingAfterExhale:
        _finishCycle(emit);
      default:
        break;
    }
  }

  void _finishCycle(Emitter<BreathingState> emit) {
    final technique = state.selectedTechnique!;
    final completedCycles = state.currentCycle + 1;
    if (completedCycles >= technique.totalCycles) {
      _timer?.cancel();
      _phaseSecondsLeft = 0;
      emit(state.copyWith(
        phase: BreathingPhase.complete,
        isRunning: false,
        secondsRemaining: 0,
        currentCycle: completedCycles,
      ));
    } else {
      emit(state.copyWith(currentCycle: completedCycles));
      _startPhase(BreathingPhase.inhaling, technique.inhaleSeconds, emit);
    }
  }

  void _onPause(BreathingSessionPaused event, Emitter<BreathingState> emit) {
    _timer?.cancel();
    emit(state.copyWith(isRunning: false));
  }

  void _onResume(BreathingSessionResumed event, Emitter<BreathingState> emit) {
    if (state.isRunning ||
        state.phase == BreathingPhase.idle ||
        state.phase == BreathingPhase.complete ||
        _phaseSecondsLeft <= 0) {
      return;
    }
    _startPhase(state.phase, _phaseSecondsLeft, emit);
  }

  void _onStop(BreathingSessionStopped event, Emitter<BreathingState> emit) {
    _timer?.cancel();
    _phaseSecondsLeft = 0;
    emit(state.copyWith(
      phase: BreathingPhase.idle,
      currentCycle: 0,
      isRunning: false,
      secondsRemaining: 0,
    ));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
