import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/breathing_technique.dart';
import '../repositories/breathing_repository.dart';

class GetBreathingTechniques extends UseCaseNoParams<List<BreathingTechnique>> {
  final BreathingRepository repository;
  GetBreathingTechniques(this.repository);

  @override
  Future<Either<Failure, List<BreathingTechnique>>> call() {
    return repository.getBreathingTechniques();
  }
}
