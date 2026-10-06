import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:ergonoworkcoah/core/errors/failures.dart';
import 'package:ergonoworkcoah/core/usecases/usecase.dart';
import 'package:ergonoworkcoah/features/avatar/domain/usecases/load_avatar_config.dart';
import 'package:ergonoworkcoah/features/avatar/domain/usecases/save_avatar_config.dart';
import 'package:ergonoworkcoah/features/avatar/presentation/cubit/avatar_cubit.dart';
import 'package:ergonoworkcoah/features/settings/presentation/cubit/theme_cubit.dart';
import 'package:ergonoworkcoah/shared/models/user_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Load extends Mock implements LoadAvatarConfig {}

class _Save extends Mock implements SaveAvatarConfig {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const AvatarConfig());
  });
  setUp(() => SharedPreferences.setMockInitialValues({'theme_mode': 'dark'}));

  test('closing the avatar during a load ignores the late result', () async {
    final load = _Load();
    final result = Completer<Either<Failure, AvatarConfig>>();
    when(() => load(any())).thenAnswer((_) => result.future);
    final cubit =
        AvatarCubit(loadAvatarConfig: load, saveAvatarConfig: _Save());
    final pending = cubit.loadConfig();
    await cubit.close();
    result.complete(const Right(AvatarConfig()));
    await pending;
  });

  test('an avatar edit is not overwritten by an older pending load', () async {
    final load = _Load();
    final result = Completer<Either<Failure, AvatarConfig>>();
    when(() => load(any())).thenAnswer((_) => result.future);
    final cubit =
        AvatarCubit(loadAvatarConfig: load, saveAvatarConfig: _Save());
    addTearDown(cubit.close);
    final pending = cubit.loadConfig();
    cubit.updateTopColor('#123456');
    result.complete(const Right(AvatarConfig()));
    await pending;
    expect(cubit.state.config.topColor, '#123456');
    expect(cubit.state.isLoading, isFalse);
  });

  test('editing during save does not mark the newer unsaved config as saved',
      () async {
    final save = _Save();
    final result = Completer<Either<Failure, bool>>();
    when(() => save(any())).thenAnswer((_) => result.future);
    final cubit =
        AvatarCubit(loadAvatarConfig: _Load(), saveAvatarConfig: save);
    addTearDown(cubit.close);
    final pending = cubit.save();
    cubit.updateTopColor('#123456');
    result.complete(const Right(true));
    await pending;
    expect(cubit.state.saveSuccess, isFalse);
    expect(cubit.state.config.topColor, '#123456');
  });

  test('an explicit theme choice wins over the initial asynchronous load',
      () async {
    final theme = ThemeCubit();
    addTearDown(theme.close);
    await theme.setMode(ThemeMode.light);
    expect(theme.state, ThemeMode.light);
    expect((await SharedPreferences.getInstance()).getString('theme_mode'),
        'light');
  });

  test('closing the theme before initialization completes is safe', () async {
    final theme = ThemeCubit();
    await theme.close();
    await Future<void>.delayed(Duration.zero);
  });
}
