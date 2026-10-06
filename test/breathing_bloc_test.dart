import 'package:ergonoworkcoah/features/breathing/domain/entities/breathing_technique.dart';
import 'package:ergonoworkcoah/features/breathing/domain/usecases/get_breathing_techniques.dart';
import 'package:ergonoworkcoah/features/breathing/presentation/bloc/breathing_bloc.dart';
import 'package:ergonoworkcoah/features/breathing/presentation/bloc/breathing_event.dart';
import 'package:ergonoworkcoah/features/breathing/presentation/bloc/breathing_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetBreathingTechniques extends Mock
    implements GetBreathingTechniques {}

void main() {
  late BreathingBloc bloc;
  tearDown(() => bloc.close());

  Future<void> start(WidgetTester tester, BreathingTechnique technique) async {
    bloc = BreathingBloc(getBreathingTechniques: _MockGetBreathingTechniques());
    bloc.add(BreathingTechniqueSelected(technique));
    await tester.pump();
    bloc.add(const BreathingSessionStarted());
    await tester.pump();
  }

  testWidgets('selecting another technique stops the active timer',
      (tester) async {
    await start(tester, BreathingTechnique.defaults.first);
    final second = BreathingTechnique.defaults[1];
    bloc.add(BreathingTechniqueSelected(second));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(bloc.state.selectedTechnique, second);
    expect(bloc.state.phase, BreathingPhase.idle);
    expect(bloc.state.secondsRemaining, 0);
    expect(bloc.state.isRunning, isFalse);
  });

  for (final technique in BreathingTechnique.defaults) {
    testWidgets('${technique.id} completes after its full advertised duration',
        (tester) async {
      await start(tester, technique);
      for (var second = 1; second < technique.totalDurationSeconds; second++) {
        await tester.pump(const Duration(seconds: 1));
        expect(bloc.state.isComplete, isFalse,
            reason: 'completed at second $second');
        expect(bloc.state.currentCycle, lessThan(technique.totalCycles));
      }
      await tester.pump(const Duration(seconds: 1));
      expect(bloc.state.isComplete, isTrue);
      expect(bloc.state.secondsRemaining, 0);
      expect(bloc.state.currentCycle, technique.totalCycles);
      expect(bloc.state.isRunning, isFalse);
    });
  }

  testWidgets('pause preserves time and resume continues the same phase',
      (tester) async {
    await start(tester, BreathingTechnique.defaults.first);
    await tester.pump(const Duration(seconds: 2));
    bloc.add(const BreathingSessionPaused());
    await tester.pump();
    final paused = bloc.state;
    await tester.pump(const Duration(seconds: 30));
    expect(bloc.state, paused);
    bloc.add(const BreathingSessionResumed());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(bloc.state.phase, paused.phase);
    expect(bloc.state.secondsRemaining, paused.secondsRemaining - 1);
    bloc.add(const BreathingSessionStopped());
    await tester.pump();
    bloc.add(const BreathingSessionResumed());
    await tester.pump();
    expect(bloc.state.isRunning, isFalse);
  });
}
