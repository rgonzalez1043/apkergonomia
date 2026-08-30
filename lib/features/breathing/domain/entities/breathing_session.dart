import 'package:equatable/equatable.dart';

class BreathingSession extends Equatable {
  final String id;
  final String techniqueId;
  final String techniqueName;
  final int cyclesCompleted;
  final int durationSeconds;
  final DateTime completedAt;

  const BreathingSession({
    required this.id,
    required this.techniqueId,
    required this.techniqueName,
    required this.cyclesCompleted,
    required this.durationSeconds,
    required this.completedAt,
  });

  @override
  List<Object?> get props =>
      [id, techniqueId, cyclesCompleted, durationSeconds, completedAt];
}
