import 'package:equatable/equatable.dart';

import '../../domain/entities/breathing_technique.dart';

abstract class BreathingEvent extends Equatable {
  const BreathingEvent();
  @override
  List<Object?> get props => [];
}

class BreathingTechniquesLoaded extends BreathingEvent {
  const BreathingTechniquesLoaded();
}

class BreathingTechniqueSelected extends BreathingEvent {
  final BreathingTechnique technique;
  const BreathingTechniqueSelected(this.technique);
  @override
  List<Object> get props => [technique];
}

class BreathingSessionStarted extends BreathingEvent {
  const BreathingSessionStarted();
}

class BreathingSessionPaused extends BreathingEvent {
  const BreathingSessionPaused();
}

class BreathingSessionResumed extends BreathingEvent {
  const BreathingSessionResumed();
}

class BreathingSessionStopped extends BreathingEvent {
  const BreathingSessionStopped();
}

class BreathingTickAdvanced extends BreathingEvent {
  const BreathingTickAdvanced();
}
