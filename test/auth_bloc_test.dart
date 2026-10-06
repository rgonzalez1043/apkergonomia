import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:ergonoworkcoah/core/errors/failures.dart';
import 'package:ergonoworkcoah/features/auth/domain/entities/user_entity.dart';
import 'package:ergonoworkcoah/features/auth/domain/repositories/auth_repository.dart';
import 'package:ergonoworkcoah/features/auth/domain/usecases/restore_session.dart';
import 'package:ergonoworkcoah/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:ergonoworkcoah/features/auth/domain/usecases/sign_out.dart';
import 'package:ergonoworkcoah/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:ergonoworkcoah/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ergonoworkcoah/features/auth/presentation/bloc/auth_event.dart';
import 'package:ergonoworkcoah/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Repository extends Mock implements AuthRepository {}

void main() {
  const user = UserEntity(uid: 'alice');
  late _Repository repository;
  late AuthBloc bloc;
  void create() {
    repository = _Repository();
    bloc = AuthBloc(
        signInWithEmail: SignInWithEmail(repository),
        signUpWithEmail: SignUpWithEmail(repository),
        signOut: SignOutUseCase(repository),
        restoreSession: RestoreSession(repository));
  }

  tearDown(() => bloc.close());

  testWidgets(
      'logout waits for a pending sign-in and cannot be undone by its result',
      (tester) async {
    create();
    final result = Completer<Either<Failure, UserEntity>>();
    when(() => repository.signInWithEmail(any(), any()))
        .thenAnswer((_) => result.future);
    when(() => repository.signOut()).thenAnswer((_) async => const Right(null));
    bloc.add(const AuthSignInRequested(
        email: 'alice@example.com', password: 'secret'));
    bloc.add(const AuthSignOutRequested());
    await tester.pump();
    verifyNever(() => repository.signOut());
    result.complete(const Right(user));
    await tester.pump();
    expect(bloc.state, isA<AuthUnauthenticated>());
    verify(() => repository.signOut()).called(1);
  });

  testWidgets('failed logout keeps the current session and exposes an error',
      (tester) async {
    create();
    when(() => repository.restoreSession())
        .thenAnswer((_) async => const Right(user));
    when(() => repository.signOut())
        .thenAnswer((_) async => const Left(CacheFailure('No se pudo cerrar')));
    bloc.add(const AuthCheckRequested());
    await tester.pump();
    bloc.add(const AuthSignOutRequested());
    await tester.pump();
    expect(bloc.state, isA<AuthAuthenticated>());
    expect((bloc.state as AuthAuthenticated).user, user);
    expect((bloc.state as AuthAuthenticated).error, 'No se pudo cerrar');
  });
}
