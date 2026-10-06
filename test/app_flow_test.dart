import 'package:ergonoworkcoah/app.dart';
import 'package:ergonoworkcoah/config/injection/injection_container.dart';
import 'package:ergonoworkcoah/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ergonoworkcoah/features/auth/presentation/bloc/auth_event.dart';
import 'package:ergonoworkcoah/features/auth/presentation/pages/auth_page.dart';
import 'package:ergonoworkcoah/features/breathing/domain/entities/breathing_technique.dart';
import 'package:ergonoworkcoah/features/breathing/presentation/bloc/breathing_bloc.dart';
import 'package:ergonoworkcoah/features/breathing/presentation/bloc/breathing_event.dart';
import 'package:ergonoworkcoah/features/breathing/presentation/pages/breathing_page.dart';
import 'package:ergonoworkcoah/features/gamification/presentation/cubit/gamification_cubit.dart';
import 'package:ergonoworkcoah/features/home/presentation/pages/home_page.dart';
import 'package:ergonoworkcoah/features/onboarding/data/onboarding_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await OnboardingPreferences.markCompleted();
    await configureDependencies();
  });
  tearDown(() => getIt.reset());

  Future<BuildContext> openAuth(WidgetTester tester) async {
    await tester.pumpWidget(const ErgoWorkCoachApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    return tester.element(find.byType(AuthPage));
  }

  Future<void> signIn(
      WidgetTester tester, BuildContext context, String email) async {
    context
        .read<AuthBloc>()
        .add(AuthSignInRequested(email: email, password: 'secret1'));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
  }

  testWidgets('routes require a session and logout clears in-memory progress',
      (tester) async {
    final authContext = await openAuth(tester);
    final router = GoRouter.of(authContext);
    router.go('/achievements');
    await tester.pumpAndSettle();
    expect(find.byType(AuthPage), findsOneWidget);
    await signIn(
        tester, tester.element(find.byType(AuthPage)), 'alice@example.com');
    final home = tester.element(find.byType(HomePage));
    final progress = home.read<GamificationCubit>();
    await progress.recordPainEntry();
    expect(progress.state.progress.totalXP, 50);
    home.read<AuthBloc>().add(const AuthSignOutRequested());
    await tester.pumpAndSettle();
    expect(find.byType(AuthPage), findsOneWidget);
    expect(progress.state.progress.totalXP, 0);
    router.go('/home');
    await tester.pumpAndSettle();
    expect(find.byType(AuthPage), findsOneWidget);
    await signIn(
        tester, tester.element(find.byType(AuthPage)), 'bob@example.com');
    expect(progress.state.progress.totalXP, 0);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('breathing pauses on tab changes and app backgrounding',
      (tester) async {
    await signIn(tester, await openAuth(tester), 'alice@example.com');
    final router = GoRouter.of(tester.element(find.byType(HomePage)));
    router.go('/breathing');
    await tester.pumpAndSettle();
    final breathing =
        tester.element(find.byType(BreathingPage)).read<BreathingBloc>();
    breathing
        .add(BreathingTechniqueSelected(BreathingTechnique.defaults.first));
    breathing.add(const BreathingSessionStarted());
    await tester.pump();
    expect(breathing.state.isRunning, isTrue);
    router.go('/home');
    await tester.pump();
    await tester.pump();
    expect(breathing.state.isRunning, isFalse);
    final left = breathing.state.secondsRemaining;
    await tester.pump(const Duration(seconds: 10));
    expect(breathing.state.secondsRemaining, left);
    router.go('/breathing');
    await tester.pumpAndSettle();
    breathing.add(const BreathingSessionResumed());
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(breathing.state.isRunning, isFalse);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(breathing.state.isRunning, isFalse);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('registration validation fits a small screen with large text',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.8;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await openAuth(tester);
    await tester.ensureVisible(find.text('Registrarse'));
    await tester.tap(find.text('Registrarse'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Crear cuenta'));
    await tester.tap(find.text('Crear cuenta'));
    await tester.pumpAndSettle();
    expect(find.text('El nombre es requerido'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('completed breathing session awards XP once through the real UI',
      (tester) async {
    await signIn(tester, await openAuth(tester), 'alice@example.com');
    final home = tester.element(find.byType(HomePage));
    final progress = home.read<GamificationCubit>();
    final router = GoRouter.of(home);
    router.go('/breathing');
    await tester.pumpAndSettle();
    final bloc =
        tester.element(find.byType(BreathingPage)).read<BreathingBloc>();
    final technique = BreathingTechnique.defaults.first;
    bloc.add(BreathingTechniqueSelected(technique));
    bloc.add(const BreathingSessionStarted());
    await tester.pump();
    for (var i = 0; i < technique.totalDurationSeconds; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(find.text('¡Sesión completa!'), findsOneWidget);
    expect(progress.state.progress.totalXP,
        100); // Session + first-session achievement.
    router.go('/home');
    await tester.pumpAndSettle();
    router.go('/breathing');
    await tester.pumpAndSettle();
    expect(progress.state.progress.totalXP, 100);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets(
      'desktop pain and avatar screens provide a usable viewer fallback',
      (tester) async {
    await signIn(tester, await openAuth(tester), 'alice@example.com');
    final router = GoRouter.of(tester.element(find.byType(HomePage)));
    router.go('/pain');
    await tester.pumpAndSettle();
    expect(find.text('Modelo 3D no disponible'), findsOneWidget);
    await tester.ensureVisible(find.text('Cabeza y cuello'));
    await tester.tap(find.text('Cabeza y cuello'));
    await tester.pumpAndSettle();
    expect(find.text('Cuello'), findsWidgets);
    router.go('/avatar');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Vista previa'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  }, variant: TargetPlatformVariant({TargetPlatform.windows}));
}
