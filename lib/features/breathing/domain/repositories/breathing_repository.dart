import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/breathing_session.dart';
import '../entities/breathing_technique.dart';

abstract class BreathingRepository {
  Future<Either<Failure, List<BreathingTechnique>>> getBreathingTechniques();
  Future<Either<Failure, void>> saveSession(BreathingSession session);
  Future<Either<Failure, List<BreathingSession>>> getSessionHistory();
}
