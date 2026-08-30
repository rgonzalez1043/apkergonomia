import 'package:equatable/equatable.dart';

import '../../../../core/constants/body_region.dart';
import '../../domain/entities/pain_record.dart';

abstract class PainEvent extends Equatable {
  const PainEvent();
  @override
  List<Object?> get props => [];
}

class PainRegionSelected extends PainEvent {
  final BodyRegion region;
  const PainRegionSelected(this.region);
  @override
  List<Object> get props => [region];
}

class PainEvaChanged extends PainEvent {
  final int evaScore;
  const PainEvaChanged(this.evaScore);
  @override
  List<Object> get props => [evaScore];
}

class PainTypeSelected extends PainEvent {
  final PainType type;
  const PainTypeSelected(this.type);
  @override
  List<Object> get props => [type];
}

class PainRecordSaved extends PainEvent {
  final PainRecord record;
  const PainRecordSaved(this.record);
  @override
  List<Object> get props => [record];
}

class PainRecordSavedAndExercisesRequested extends PainEvent {
  final PainRecord record;

  const PainRecordSavedAndExercisesRequested(this.record);

  @override
  List<Object> get props => [record];
}

class PainHistoryLoaded extends PainEvent {
  const PainHistoryLoaded();
}

class PainSaveAcknowledged extends PainEvent {
  const PainSaveAcknowledged();
}

class PainErrorAcknowledged extends PainEvent {
  const PainErrorAcknowledged();
}

class PainExercisesRequested extends PainEvent {
  final BodyRegion region;
  final int evaScore;
  const PainExercisesRequested({required this.region, required this.evaScore});
  @override
  List<Object> get props => [region, evaScore];
}
