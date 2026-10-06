import 'package:ergonoworkcoah/features/breathing/presentation/bloc/breathing_state.dart';
import 'package:ergonoworkcoah/features/breathing/presentation/widgets/breathing_circle_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'the breathing circle follows the phase duration and stops while paused',
      (tester) async {
    Widget circle(bool running, int seconds) => MaterialApp(
            home: Scaffold(
                body: BreathingCircleWidget(
          phase: BreathingPhase.inhaling,
          secondsRemaining: seconds,
          ambientColor: Colors.teal,
          isRunning: running,
        )));
    double scale() => tester
        .widget<Transform>(find.descendant(
          of: find.byType(BreathingCircleWidget),
          matching: find.byType(Transform),
        ))
        .transform
        .entry(0, 0);

    await tester.pumpWidget(circle(true, 6));
    await tester.pump(const Duration(seconds: 1));
    final early = scale();
    expect(early, lessThan(1));
    await tester.pump(const Duration(seconds: 2));
    final middle = scale();
    expect(middle, greaterThan(early));
    expect(middle, lessThan(1));
    await tester.pumpWidget(circle(false, 3));
    await tester.pump(const Duration(seconds: 10));
    expect(scale(), middle);
    await tester.pumpWidget(circle(true, 3));
    await tester.pump(const Duration(seconds: 3));
    expect(scale(), 1);
  });
}
