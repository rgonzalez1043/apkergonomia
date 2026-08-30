import 'package:equatable/equatable.dart';

import '../../domain/entities/breathing_technique.dart';

enum BreathingPhase {
  idle,
  inhaling,
  holding,
  exhaling,
  holdingAfterExhale,
  complete
}

class BreathingState extends Equatable {
  final List<BreathingTechnique> techniques;
  final BreathingTechnique? selectedTechnique;
  final BreathingPhase phase;
  final int currentCycle;
  final int secondsRemaining;
  final bool isRunning;
  final bool isLoading;
  final String? error;

  const BreathingState({
    this.techniques = const [],
    this.selectedTechnique,
    this.phase = BreathingPhase.idle,
    this.currentCycle = 0,
    this.secondsRemaining = 0,
    this.isRunning = false,
    this.isLoading = false,
    this.error,
  });

  bool get isComplete => phase == BreathingPhase.complete;

  String get phaseLabel {
    switch (phase) {
      case BreathingPhase.inhaling:
        return 'Inhala';
      case BreathingPhase.holding:
        return 'Mantén';
      case BreathingPhase.exhaling:
        return 'Exhala';
      case BreathingPhase.holdingAfterExhale:
        return 'Pausa';
      case BreathingPhase.complete:
        return '¡Completado!';
      default:
        return 'Preparado';
    }
  }

  BreathingState copyWith({
    List<BreathingTechnique>? techniques,
    BreathingTechnique? selectedTechnique,
    BreathingPhase? phase,
    int? currentCycle,
    int? secondsRemaining,
    bool? isRunning,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return BreathingState(
      techniques: techniques ?? this.techniques,
      selectedTechnique: selectedTechnique ?? this.selectedTechnique,
      phase: phase ?? this.phase,
      currentCycle: currentCycle ?? this.currentCycle,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      isRunning: isRunning ?? this.isRunning,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        techniques,
        selectedTechnique,
        phase,
        currentCycle,
        secondsRemaining,
        isRunning,
        isLoading,
        error,
      ];
}
