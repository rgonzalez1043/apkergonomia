import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  Future<Either<Failure, UserEntity>> signInWithEmail(
      String email, String password);
  Future<Either<Failure, UserEntity>> signUpWithEmail(
      String email, String password, String displayName);
  Future<Either<Failure, UserEntity?>> restoreSession();
  Future<Either<Failure, void>> signOut();
  UserEntity? get currentUser;
}
