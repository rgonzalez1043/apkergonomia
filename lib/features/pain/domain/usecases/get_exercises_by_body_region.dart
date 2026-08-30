import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/constants/body_region.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/pain_scale_utils.dart';
import '../entities/exercise.dart';
import '../repositories/pain_repository.dart';

class GetExercisesByBodyRegion extends UseCase<List<Exercise>, ExerciseParams> {
  final PainRepository repository;
  GetExercisesByBodyRegion(this.repository);

  @override
  Future<Either<Failure, List<Exercise>>> call(ExerciseParams params) {
    final stage = PainScaleUtils.getEvaStage(params.evaScore);
    return repository.getExercisesByRegionAndStage(params.region, stage);
  }
}

class ExerciseParams extends Equatable {
  final BodyRegion region;
  final int evaScore;
  const ExerciseParams({required this.region, required this.evaScore});

  @override
  List<Object> get props => [region, evaScore];
}
