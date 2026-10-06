import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/network_info.dart';
import '../../core/storage/user_local_storage.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_with_email.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/sign_up_with_email.dart';
import '../../features/auth/domain/usecases/restore_session.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/breathing/data/repositories/breathing_repository_impl.dart';
import '../../features/breathing/domain/repositories/breathing_repository.dart';
import '../../features/breathing/domain/usecases/get_breathing_techniques.dart';
import '../../features/breathing/presentation/bloc/breathing_bloc.dart';
import '../../features/gamification/presentation/cubit/gamification_cubit.dart';
import '../../features/pain/data/datasources/pain_local_datasource.dart';
import '../../features/pain/data/repositories/pain_repository_impl.dart';
import '../../features/pain/domain/repositories/pain_repository.dart';
import '../../features/pain/domain/usecases/get_exercises_by_body_region.dart';
import '../../features/avatar/data/datasources/avatar_local_datasource.dart';
import '../../features/avatar/data/repositories/avatar_repository_impl.dart';
import '../../features/avatar/domain/repositories/avatar_repository.dart';
import '../../features/avatar/domain/usecases/load_avatar_config.dart';
import '../../features/avatar/domain/usecases/save_avatar_config.dart';
import '../../features/avatar/presentation/cubit/avatar_cubit.dart';
import '../../features/pain/domain/usecases/get_pain_history.dart';
import '../../features/pain/domain/usecases/record_pain_entry.dart';
import '../../features/pain/presentation/bloc/pain_bloc.dart';
import '../../features/settings/presentation/cubit/theme_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerSingleton(
      UserLocalStorage(await SharedPreferences.getInstance()));
  // Core
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt()));

  // Auth
  getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(getIt()),
      dispose: (source) => (source as AuthRemoteDataSourceImpl).dispose());
  getIt.registerLazySingleton<AuthRepository>(
    () =>
        AuthRepositoryImpl(getIt<AuthRemoteDataSource>(), getIt<NetworkInfo>()),
  );
  getIt.registerLazySingleton(() => SignInWithEmail(getIt()));
  getIt.registerLazySingleton(() => SignUpWithEmail(getIt()));
  getIt.registerLazySingleton(() => SignOutUseCase(getIt()));
  getIt.registerLazySingleton(() => RestoreSession(getIt()));
  getIt.registerFactory(() => AuthBloc(
        signInWithEmail: getIt(),
        signUpWithEmail: getIt(),
        signOut: getIt(),
        restoreSession: getIt(),
      ));

  // Pain
  getIt.registerLazySingleton<PainLocalDataSource>(
      () => PainLocalDataSourceImpl(getIt()));
  getIt.registerLazySingleton<PainRepository>(
    () => PainRepositoryImpl(getIt<PainLocalDataSource>()),
  );
  getIt.registerLazySingleton(() => GetExercisesByBodyRegion(getIt()));
  getIt.registerLazySingleton(() => RecordPainEntry(getIt()));
  getIt.registerLazySingleton(() => GetPainHistory(getIt()));
  getIt.registerFactory(() => PainBloc(
        getExercisesByBodyRegion: getIt(),
        recordPainEntry: getIt(),
        getPainHistory: getIt(),
      ));

  // Breathing
  getIt.registerLazySingleton<BreathingRepository>(
      () => BreathingRepositoryImpl());
  getIt.registerLazySingleton(() => GetBreathingTechniques(getIt()));
  getIt.registerFactory(() => BreathingBloc(getBreathingTechniques: getIt()));

  // Avatar
  getIt.registerLazySingleton<AvatarLocalDataSource>(
      () => AvatarLocalDataSourceImpl(getIt()));
  getIt.registerLazySingleton<AvatarRepository>(
      () => AvatarRepositoryImpl(getIt<AvatarLocalDataSource>()));
  getIt.registerLazySingleton(() => LoadAvatarConfig(getIt()));
  getIt.registerLazySingleton(() => SaveAvatarConfig(getIt()));
  getIt.registerFactory(() => AvatarCubit(
        loadAvatarConfig: getIt(),
        saveAvatarConfig: getIt(),
      ));

  // Gamification
  getIt.registerFactory(() => GamificationCubit(getIt()));

  // Settings
  getIt.registerFactory(() => ThemeCubit());
}
