import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../errors/failures.dart';

abstract class UseCase<T, P> {
  Future<Either<Failure, T>> call(P params);
}

abstract class UseCaseNoParams<T> {
  Future<Either<Failure, T>> call();
}

class NoParams extends Equatable {
  const NoParams();
  @override
  List<Object?> get props => [];
}
