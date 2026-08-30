import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/user_profile_model.dart';

abstract class AvatarRepository {
  Future<Either<Failure, AvatarConfig>> loadAvatarConfig();
  Future<Either<Failure, bool>> saveAvatarConfig(AvatarConfig config);
}
