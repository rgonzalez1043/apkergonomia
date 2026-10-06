import 'package:ergonoworkcoah/core/storage/user_local_storage.dart';
import 'package:ergonoworkcoah/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ergonoworkcoah/features/onboarding/data/onboarding_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late UserLocalStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = UserLocalStorage(await SharedPreferences.getInstance());
  });

  test('local authentication persists, restores, and removes the session',
      () async {
    final firstDataSource = AuthRemoteDataSourceImpl(storage);
    addTearDown(firstDataSource.dispose);
    final signedUp = await firstDataSource.signUpWithEmail(
      'persona@example.com',
      'password-segura',
      'Persona',
    );

    final restoredDataSource = AuthRemoteDataSourceImpl(storage);
    addTearDown(restoredDataSource.dispose);
    final restored = await restoredDataSource.restoreSession();
    expect(restored, signedUp);

    await restoredDataSource.signOut();
    final afterSignOut = await restoredDataSource.restoreSession();
    expect(afterSignOut, isNull);
  });

  test('a corrupt stored session is discarded', () async {
    await storage.preferences.setString('auth_session', '{invalid');

    final source = AuthRemoteDataSourceImpl(storage);
    addTearDown(source.dispose);
    final restored = await source.restoreSession();

    expect(restored, isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('auth_session'), isFalse);
  });

  test('onboarding completion is persisted', () async {
    expect(await OnboardingPreferences.isCompleted(), isFalse);

    await OnboardingPreferences.markCompleted();

    expect(await OnboardingPreferences.isCompleted(), isTrue);
  });
}
