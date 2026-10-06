import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import '../../domain/usecases/restore_session.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmail signInWithEmail;
  final SignUpWithEmail signUpWithEmail;
  final SignOutUseCase signOut;
  final RestoreSession restoreSession;

  AuthBloc({
    required this.signInWithEmail,
    required this.signUpWithEmail,
    required this.signOut,
    required this.restoreSession,
  }) : super(const AuthInitial()) {
    // Serialize all auth operations so a late restore/sign-in cannot undo logout.
    on<AuthEvent>((event, emit) async {
      if (event is AuthCheckRequested) await _onCheckRequested(event, emit);
      if (event is AuthSignInRequested) await _onSignIn(event, emit);
      if (event is AuthSignUpRequested) await _onSignUp(event, emit);
      if (event is AuthSignOutRequested) await _onSignOut(event, emit);
    }, transformer: (events, mapper) => events.asyncExpand(mapper));
  }

  Future<void> _onCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    final result = await restoreSession();
    result.fold(
      (_) => emit(const AuthUnauthenticated()),
      (user) => emit(
        user == null ? const AuthUnauthenticated() : AuthAuthenticated(user),
      ),
    );
  }

  Future<void> _onSignIn(
      AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await signInWithEmail(
        SignInParams(email: event.email, password: event.password));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignUp(
      AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await signUpWithEmail(
      SignUpParams(
          email: event.email,
          password: event.password,
          displayName: event.displayName),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignOut(
      AuthSignOutRequested event, Emitter<AuthState> emit) async {
    final previous = state;
    final result = await signOut();
    result.fold(
      (failure) => emit(previous is AuthAuthenticated
          ? AuthAuthenticated(previous.user, error: failure.message)
          : AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }
}
