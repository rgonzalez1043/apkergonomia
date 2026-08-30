import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../injection/injection_container.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/breathing/presentation/bloc/breathing_bloc.dart';
import '../../features/breathing/presentation/bloc/breathing_event.dart';
import '../../features/breathing/presentation/pages/breathing_page.dart';
import '../../features/gamification/presentation/pages/achievements_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/widgets/main_shell.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/onboarding/presentation/pages/splash_page.dart';
import '../../features/avatar/presentation/cubit/avatar_cubit.dart';
import '../../features/avatar/presentation/pages/avatar_page.dart';
import '../../features/pain/presentation/bloc/pain_bloc.dart';
import '../../features/pain/presentation/pages/pain_map_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: RouteNames.auth,
        builder: (_, __) => const AuthPage(),
      ),
      GoRoute(
        path: RouteNames.avatar,
        builder: (context, __) => BlocProvider(
          create: (_) => getIt<AvatarCubit>()..loadConfig(),
          child: const AvatarPage(),
        ),
      ),

      // Shell con NavigationBar
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.home,
                builder: (_, __) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.pain,
                builder: (context, __) => BlocProvider(
                  create: (_) => getIt<PainBloc>(),
                  child: const PainMapPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.breathing,
                builder: (context, __) => BlocProvider(
                  create: (_) => getIt<BreathingBloc>()
                    ..add(const BreathingTechniquesLoaded()),
                  child: const BreathingPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.achievements,
                builder: (_, __) => const AchievementsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.settings,
                builder: (_, __) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
