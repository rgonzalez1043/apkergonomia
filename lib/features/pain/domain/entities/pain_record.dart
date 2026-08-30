import 'package:equatable/equatable.dart';

import '../../../../core/constants/body_region.dart';

enum PainType { punzante, ardor, presion, constante, intermitente }

class PainRecord extends Equatable {
  final String id;
  final BodyRegion region;
  final PainType type;
  final int evaScore;
  final DateTime recordedAt;
  final List<String> exercisesCompleted;
  final String? notes;

  const PainRecord({
    required this.id,
    required this.region,
    required this.type,
    required this.evaScore,
    required this.recordedAt,
    this.exercisesCompleted = const [],
    this.notes,
  });

  @override
  List<Object?> get props =>
      [id, region, type, evaScore, recordedAt, exercisesCompleted, notes];
}
