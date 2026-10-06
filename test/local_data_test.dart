import 'dart:convert';

import 'package:ergonoworkcoah/core/constants/body_region.dart';
import 'package:ergonoworkcoah/core/storage/user_local_storage.dart';
import 'package:ergonoworkcoah/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ergonoworkcoah/features/avatar/data/datasources/avatar_local_datasource.dart';
import 'package:ergonoworkcoah/features/pain/data/datasources/pain_local_datasource.dart';
import 'package:ergonoworkcoah/features/pain/data/repositories/pain_repository_impl.dart';
import 'package:ergonoworkcoah/features/pain/domain/entities/pain_record.dart';
import 'package:ergonoworkcoah/shared/models/user_profile_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late UserLocalStorage storage;
  late PainLocalDataSourceImpl pain;
  late AvatarLocalDataSourceImpl avatar;

  PainRecord record(String id,
          {BodyRegion region = BodyRegion.neck, int day = 1}) =>
      PainRecord(
        id: id,
        region: region,
        type: PainType.presion,
        evaScore: 4,
        recordedAt: DateTime(2026, 1, day),
      );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = UserLocalStorage(await SharedPreferences.getInstance());
    await storage.activate('alice');
    pain = PainLocalDataSourceImpl(storage);
    avatar = AvatarLocalDataSourceImpl(storage);
  });

  test('pain and avatar remain separate across profiles and sign-out',
      () async {
    await pain.savePainRecord(record('alice-record'));
    await avatar.saveAvatarConfig(const AvatarConfig(topColor: '#123456'));
    await storage.activate('bob');
    expect(await pain.getPainHistory(), isEmpty);
    expect(await avatar.loadAvatarConfig(), isNull);
    await pain.savePainRecord(record('bob-record'));
    await storage.activate('alice');
    expect((await pain.getPainHistory()).single.id, 'alice-record');
    expect((await avatar.loadAvatarConfig())!.topColor, '#123456');
    storage.clearSession();
    await expectLater(pain.getPainHistory(), throwsA(isA<Exception>()));
  });

  test('concurrent saves survive and saving the same ID is idempotent',
      () async {
    await Future.wait(List.generate(
        60, (i) => pain.savePainRecord(record('$i', day: i + 1))));
    await pain.savePainRecord(record('0'));
    final all = await pain.getPainHistory(limit: null);
    expect(all, hasLength(60));
    expect(all.first.id, '59');
    expect(await pain.getPainHistory(), hasLength(50));
    expect(await pain.getPainHistory(limit: 0), isEmpty);
  });

  test('region history filters before any display limit', () async {
    await pain.savePainRecord(record('old-neck'));
    for (var i = 0; i < 51; i++) {
      await pain.savePainRecord(
          record('back-$i', region: BodyRegion.lowerBack, day: i + 2));
    }
    final result =
        await PainRepositoryImpl(pain).getPainHistoryByRegion(BodyRegion.neck);
    expect(result.getOrElse(() => []).single.id, 'old-neck');
  });

  test('invalid entries do not hide valid history', () async {
    await pain.savePainRecord(record('valid'));
    final key = storage.keyFor('pain_records');
    final entries = storage.preferences.getStringList(key)!;
    final invalid = jsonDecode(entries.single) as Map<String, dynamic>;
    invalid['evaScore'] = 99;
    await storage.preferences
        .setStringList(key, [...entries, '{broken', jsonEncode(invalid)]);
    expect((await pain.getPainHistory()).single.id, 'valid');
  });

  test(
      'legacy data is copied only to the restored owner and preserved as backup',
      () async {
    SharedPreferences.setMockInitialValues({
      'pain_records': <String>['legacy'],
      'avatar_config': jsonEncode(const AvatarConfig().toJson()),
    });
    final migrated = UserLocalStorage(await SharedPreferences.getInstance());
    await migrated.activate('existing', migrateLegacy: true);
    expect(migrated.preferences.getStringList(migrated.keyFor('pain_records')),
        ['legacy']);
    expect(migrated.preferences.containsKey('pain_records'), isTrue);
    await migrated.activate('another', migrateLegacy: true);
    expect(migrated.preferences.containsKey(migrated.keyFor('pain_records')),
        isFalse);
  });

  test('a new login cannot claim legacy data without an existing session',
      () async {
    SharedPreferences.setMockInitialValues({
      'pain_records': <String>['legacy']
    });
    final migrated = UserLocalStorage(await SharedPreferences.getInstance());
    await migrated.activate('new');
    await migrated.activate('new', migrateLegacy: true);
    expect(migrated.preferences.containsKey(migrated.keyFor('pain_records')),
        isFalse);
  });

  test('local identity is stable across case, whitespace, and new instances',
      () async {
    final first = AuthRemoteDataSourceImpl(storage);
    final second = AuthRemoteDataSourceImpl(storage);
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    final a = await first.signUpWithEmail(
        ' PERSON@example.com ', 'secret1', 'Person');
    await first.signOut();
    final b = await second.signInWithEmail('person@EXAMPLE.com', 'secret1');
    expect(a.uid, b.uid);
    expect(b.email, 'person@example.com');
  });

  test(
      'every body region and stage has media-backed exercises without advancing stages',
      () {
    for (final region in BodyRegion.values) {
      for (var stage = 1; stage <= 3; stage++) {
        final exercises = ExerciseSeedData.getExercises(region, stage);
        expect(exercises, isNotEmpty, reason: '$region stage $stage');
        expect(
            exercises
                .every((e) => e.targetRegion == region && e.evaStage <= stage),
            isTrue);
        expect(
            exercises.every((e) => ExerciseSeedData.allExercises.contains(e)),
            isTrue);
      }
    }
  });
}
