import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'config/injection/injection_container.dart';
import 'config/router/app_router.dart';
import 'config/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/gamification/presentation/cubit/gamification_cubit.dart';
import 'features/settings/presentation/cubit/theme_cubit.dart';

class ErgoWorkCoachApp extends StatefulWidget {
  const ErgoWorkCoachApp({super.key});

  @override
  State<ErgoWorkCoachApp> createState() => _ErgoWorkCoachAppState();
}

class _ErgoWorkCoachAppState extends State<ErgoWorkCoachApp> {
  late final AuthBloc _auth;
  late final GoRouter _router;
  final _routerRefresh = ValueNotifier<int>(0);
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _auth = getIt<AuthBloc>();
    _router = AppRouter.create(_auth, _routerRefresh);
    _authSubscription = _auth.stream.listen((_) => _routerRefresh.value++);
    _auth.add(const AuthCheckRequested());
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _router.dispose();
    _routerRefresh.dispose();
    _auth.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _auth),
        BlocProvider<ThemeCubit>(
          create: (_) => getIt<ThemeCubit>(),
        ),
        BlocProvider<GamificationCubit>(
          create: (_) => getIt<GamificationCubit>(),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          final progress = context.read<GamificationCubit>();
          if (state is AuthAuthenticated &&
              progress.state.progress.userId != state.user.uid) {
            progress.init(state.user.uid);
            progress.recordVisit();
          } else if (state is AuthUnauthenticated) {
            progress.reset();
          }
        },
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp.router(
              title: 'ErgoWorkCoach',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              routerConfig: _router,
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}
