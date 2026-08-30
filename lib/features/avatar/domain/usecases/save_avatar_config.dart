import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/avatar_repository.dart';
import '../../../../shared/models/user_profile_model.dart';

class SaveAvatarConfig extends UseCase<bool, AvatarConfig> {
  final AvatarRepository repository;

  SaveAvatarConfig(this.repository);

  @override
  Future<Either<Failure, bool>> call(AvatarConfig params) {
    return repository.saveAvatarConfig(params);
  }
}
