import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/repositories/avatar_repository.dart';
import '../datasources/avatar_local_datasource.dart';
import '../../../../shared/models/user_profile_model.dart';

class AvatarRepositoryImpl implements AvatarRepository {
  final AvatarLocalDataSource localDataSource;

  AvatarRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, AvatarConfig>> loadAvatarConfig() async {
    try {
      final config = await localDataSource.loadAvatarConfig();
      return Right(config ?? const AvatarConfig());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> saveAvatarConfig(AvatarConfig config) async {
    try {
      await localDataSource.saveAvatarConfig(config);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
