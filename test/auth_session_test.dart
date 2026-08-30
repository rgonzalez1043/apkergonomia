import 'package:ergonoworkcoah/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ergonoworkcoah/features/onboarding/data/onboarding_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('local authentication persists, restores, and removes the session',
      () async {
    final firstDataSource = AuthRemoteDataSourceImpl();
    final signedUp = await firstDataSource.signUpWithEmail(
      'persona@example.com',
      'password-segura',
      'Persona',
    );

    final restoredDataSource = AuthRemoteDataSourceImpl();
    final restored = await restoredDataSource.restoreSession();
    expect(restored, signedUp);

    await restoredDataSource.signOut();
    final afterSignOut = await AuthRemoteDataSourceImpl().restoreSession();
    expect(afterSignOut, isNull);
  });

  test('a corrupt stored session is discarded', () async {
    SharedPreferences.setMockInitialValues({'auth_session': '{invalid'});

    final restored = await AuthRemoteDataSourceImpl().restoreSession();

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
