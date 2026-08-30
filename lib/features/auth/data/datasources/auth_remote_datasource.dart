import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Stream<UserEntity?> get authStateChanges;
  Future<UserEntity> signInWithEmail(String email, String password);
  Future<UserEntity> signUpWithEmail(
      String email, String password, String displayName);
  Future<UserEntity?> restoreSession();
  Future<void> signOut();
  UserEntity? get currentUser;
}

// Implementación local sin Firebase para desarrollo inicial.
// Reemplazar por FirebaseAuthDataSourceImpl cuando Firebase esté configurado.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  static const _sessionKey = 'auth_session';
  UserEntity? _currentUser;
  final StreamController<UserEntity?> _authController =
      StreamController<UserEntity?>.broadcast();

  @override
  Stream<UserEntity?> get authStateChanges => _authController.stream;

  @override
  UserEntity? get currentUser => _currentUser;

  @override
  Future<UserEntity> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (password.length < 6) throw const AuthException('Contraseña incorrecta');
    final user = UserEntity(
      uid: 'local_${email.hashCode}',
      email: email,
      displayName: email.split('@').first,
    );
    _currentUser = user;
    await _persistUser(user);
    _authController.add(user);
    return user;
  }

  @override
  Future<UserEntity> signUpWithEmail(
      String email, String password, String displayName) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final user = UserEntity(
      uid: 'local_${email.hashCode}',
      email: email,
      displayName: displayName,
    );
    _currentUser = user;
    await _persistUser(user);
    _authController.add(user);
    return user;
  }

  @override
  Future<UserEntity?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final uid = map['uid'] as String?;
      if (uid == null || uid.isEmpty) throw const FormatException();

      final user = UserEntity(
        uid: uid,
        email: map['email'] as String?,
        displayName: map['displayName'] as String?,
        photoUrl: map['photoUrl'] as String?,
        emailVerified: map['emailVerified'] as bool? ?? false,
      );
      _currentUser = user;
      _authController.add(user);
      return user;
    } catch (_) {
      await prefs.remove(_sessionKey);
      _currentUser = null;
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    _currentUser = null;
    _authController.add(null);
  }

  Future<void> _persistUser(UserEntity user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _sessionKey,
      jsonEncode({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoUrl,
        'emailVerified': user.emailVerified,
      }),
    );
  }
}
