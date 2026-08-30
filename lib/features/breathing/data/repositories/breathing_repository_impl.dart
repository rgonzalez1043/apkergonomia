import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/breathing_session.dart';
import '../../domain/entities/breathing_technique.dart';
import '../../domain/repositories/breathing_repository.dart';

class BreathingRepositoryImpl implements BreathingRepository {
  @override
  Future<Either<Failure, List<BreathingTechnique>>>
      getBreathingTechniques() async {
    return Right(BreathingTechnique.defaults);
  }

  @override
  Future<Either<Failure, void>> saveSession(BreathingSession session) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<BreathingSession>>> getSessionHistory() async {
    return const Right([]);
  }
}
