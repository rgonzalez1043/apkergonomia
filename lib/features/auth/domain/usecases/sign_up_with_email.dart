import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmail extends UseCase<UserEntity, SignUpParams> {
  final AuthRepository repository;
  SignUpWithEmail(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) {
    return repository.signUpWithEmail(
        params.email, params.password, params.displayName);
  }
}

class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String displayName;
  const SignUpParams(
      {required this.email, required this.password, required this.displayName});

  @override
  List<Object> get props => [email, password, displayName];
}
