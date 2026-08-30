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
  test('selecting another technique stops the active timer', () async {
    final bloc = BreathingBloc(
      getBreathingTechniques: _MockGetBreathingTechniques(),
    );
    addTearDown(bloc.close);
    final first = BreathingTechnique.defaults.first;
    final second = BreathingTechnique.defaults[1];

    bloc.add(BreathingTechniqueSelected(first));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    bloc.add(const BreathingSessionStarted());
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(bloc.state.isRunning, isTrue);

    bloc.add(BreathingTechniqueSelected(second));
    await Future<void>.delayed(const Duration(milliseconds: 1100));

    expect(bloc.state.selectedTechnique, second);
    expect(bloc.state.phase, BreathingPhase.idle);
    expect(bloc.state.secondsRemaining, 0);
    expect(bloc.state.isRunning, isFalse);
  });
}
