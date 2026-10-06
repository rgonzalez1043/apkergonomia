import 'dart:async';
import 'dart:convert';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/user_local_storage.dart';
import '../../../../core/utils/validators.dart';
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
  final UserLocalStorage storage;

  AuthRemoteDataSourceImpl(this.storage);
  UserEntity? _currentUser;
  final StreamController<UserEntity?> _authController =
      StreamController<UserEntity?>.broadcast();

  @override
  Stream<UserEntity?> get authStateChanges => _authController.stream;

  @override
  UserEntity? get currentUser => _currentUser;

  @override
  Future<UserEntity> signInWithEmail(String email, String password) async {
    email = email.trim().toLowerCase();
    _validateCredentials(email, password);
    final user = UserEntity(
      uid: _localId(email),
      email: email,
      displayName: email.split('@').first,
    );
    await _persistUser(user);
    await storage.activate(user.uid);
    _currentUser = user;
    _authController.add(user);
    return user;
  }

  @override
  Future<UserEntity> signUpWithEmail(
      String email, String password, String displayName) async {
    email = email.trim().toLowerCase();
    _validateCredentials(email, password);
    final nameError = Validators.displayName(displayName);
    if (nameError != null) throw AuthException(nameError);
    final user = UserEntity(
      uid: _localId(email),
      email: email,
      displayName: displayName.trim(),
    );
    await _persistUser(user);
    await storage.activate(user.uid);
    _currentUser = user;
    _authController.add(user);
    return user;
  }

  @override
  Future<UserEntity?> restoreSession() async {
    final prefs = storage.preferences;
    final raw = prefs.get(_sessionKey);
    _currentUser = null;
    storage.clearSession();
    if (raw == null) return null;

    final UserEntity user;
    try {
      final map = jsonDecode(raw as String) as Map<String, dynamic>;
      final uid = map['uid'] as String?;
      if (uid == null || uid.isEmpty) throw const FormatException();

      final email = (map['email'] as String?)?.trim().toLowerCase();
      user = UserEntity(
        uid: uid.startsWith('local_') && email != null ? _localId(email) : uid,
        email: email,
        displayName: map['displayName'] as String?,
        photoUrl: map['photoUrl'] as String?,
        emailVerified: map['emailVerified'] as bool? ?? false,
      );
    } catch (_) {
      await prefs.remove(_sessionKey);
      _currentUser = null;
      return null;
    }
    await storage.activate(user.uid, migrateLegacy: true);
    await _persistUser(user);
    _currentUser = user;
    _authController.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    if (!await storage.preferences.remove(_sessionKey)) {
      throw const CacheException('No se pudo cerrar la sesión');
    }
    storage.clearSession();
    _currentUser = null;
    _authController.add(null);
  }

  Future<void> _persistUser(UserEntity user) async {
    await storage.writeString(
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

  String _localId(String email) =>
      'local_${base64Url.encode(utf8.encode(email))}';

  void _validateCredentials(String email, String password) {
    final error = Validators.email(email) ?? Validators.password(password);
    if (error != null) throw AuthException(error);
  }

  Future<void> dispose() => _authController.close();
}
