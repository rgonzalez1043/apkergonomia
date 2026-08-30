import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/avatar_repository.dart';
import '../../../../shared/models/user_profile_model.dart';

class LoadAvatarConfig extends UseCase<AvatarConfig, NoParams> {
  final AvatarRepository repository;

  LoadAvatarConfig(this.repository);

  @override
  Future<Either<Failure, AvatarConfig>> call(NoParams params) {
    return repository.loadAvatarConfig();
  }
}
