import 'package:dartz/dartz.dart';

import '../../../../core/constants/body_region.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/pain_record.dart';
import '../../domain/repositories/pain_repository.dart';
import '../datasources/pain_local_datasource.dart';

class PainRepositoryImpl implements PainRepository {
  final PainLocalDataSource localDataSource;

  PainRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<Exercise>>> getExercisesByRegionAndStage(
      BodyRegion region, int evaStage) async {
    try {
      final exercises =
          await localDataSource.getExercisesByRegionAndStage(region, evaStage);
      return Right(exercises);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> recordPainEntry(PainRecord record) async {
    try {
      final id = await localDataSource.savePainRecord(record);
      return Right(id);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PainRecord>>> getPainHistory(
      {int limit = 50}) async {
    try {
      final records = await localDataSource.getPainHistory(limit: limit);
      return Right(records);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PainRecord>>> getPainHistoryByRegion(
      BodyRegion region) async {
    try {
      final all = await localDataSource.getPainHistory();
      return Right(all.where((r) => r.region == region).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
