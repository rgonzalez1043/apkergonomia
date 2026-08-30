import 'package:ergonoworkcoah/features/pain/data/datasources/pain_local_datasource.dart';
import 'package:ergonoworkcoah/features/pain/presentation/widgets/exercise_demo_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('exercise guide renders content and registers a repetition',
      (tester) async {
    var registeredRepetitions = 0;
    final exercise = ExerciseSeedData.allExercises.first;

    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ExerciseDemoWidget(
              exercise: exercise,
              completedReps: 0,
              onAddRepetition: () => registeredRepetitions++,
              onReset: () {},
              videoBuilder: (_, __) => const AspectRatio(
                aspectRatio: 16 / 9,
                child: ColoredBox(color: Colors.black),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('VIDEO DE MOVIMIENTO REAL'), findsOneWidget);
    expect(find.text(exercise.name), findsOneWidget);
    expect(find.textContaining('Fuente:'), findsOneWidget);
    expect(find.text('0 / ${exercise.reps}'), findsOneWidget);

    await tester.tap(find.text('Registrar repetición'));
    expect(registeredRepetitions, 1);
    expect(tester.takeException(), isNull);
  });
}
