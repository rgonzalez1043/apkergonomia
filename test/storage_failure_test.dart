import 'package:ergonoworkcoah/core/errors/exceptions.dart';
import 'package:ergonoworkcoah/core/constants/body_region.dart';
import 'package:ergonoworkcoah/core/storage/user_local_storage.dart';
import 'package:ergonoworkcoah/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ergonoworkcoah/features/pain/data/datasources/pain_local_datasource.dart';
import 'package:ergonoworkcoah/features/pain/domain/entities/pain_record.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Preferences extends Mock implements SharedPreferences {}

void main() {
  test('a refused pain write reports failure and the next save still works',
      () async {
    final prefs = _Preferences();
    when(() => prefs.containsKey(any())).thenReturn(true);
    when(() => prefs.getStringList(any())).thenReturn([]);
    when(() => prefs.setStringList(any(), any()))
        .thenAnswer((_) async => false);
    final storage = UserLocalStorage(prefs);
    await storage.activate('alice');
    final source = PainLocalDataSourceImpl(storage);
    final record = PainRecord(
        id: 'one',
        region: BodyRegion.neck,
        type: PainType.presion,
        evaScore: 4,
        recordedAt: DateTime(2026));
    await expectLater(
        source.savePainRecord(record), throwsA(isA<CacheException>()));
    when(() => prefs.setStringList(any(), any())).thenAnswer((_) async => true);
    expect(await source.savePainRecord(record), 'one');
  });

  test('failed session persistence does not authenticate a user in memory',
      () async {
    final prefs = _Preferences();
    when(() => prefs.setString(any(), any())).thenAnswer((_) async => false);
    final storage = UserLocalStorage(prefs);
    final source = AuthRemoteDataSourceImpl(storage);
    addTearDown(source.dispose);
    await expectLater(source.signInWithEmail('alice@example.com', 'secret1'),
        throwsA(isA<CacheException>()));
    expect(source.currentUser, isNull);
    expect(storage.userId, isNull);
  });
}
