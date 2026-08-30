import 'package:dartz/dartz.dart';

import '../../../../core/constants/body_region.dart';
import '../../../../core/errors/failures.dart';
import '../entities/exercise.dart';
import '../entities/pain_record.dart';

abstract class PainRepository {
  Future<Either<Failure, List<Exercise>>> getExercisesByRegionAndStage(
      BodyRegion region, int evaStage);
  Future<Either<Failure, String>> recordPainEntry(PainRecord record);
  Future<Either<Failure, List<PainRecord>>> getPainHistory({int limit = 50});
  Future<Either<Failure, List<PainRecord>>> getPainHistoryByRegion(
      BodyRegion region);
}
