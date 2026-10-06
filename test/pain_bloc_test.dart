import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:ergonoworkcoah/core/constants/body_region.dart';
import 'package:ergonoworkcoah/core/errors/failures.dart';
import 'package:ergonoworkcoah/features/pain/data/datasources/pain_local_datasource.dart';
import 'package:ergonoworkcoah/features/pain/domain/entities/exercise.dart';
import 'package:ergonoworkcoah/features/pain/domain/entities/pain_record.dart';
import 'package:ergonoworkcoah/features/pain/domain/usecases/get_exercises_by_body_region.dart';
import 'package:ergonoworkcoah/features/pain/domain/usecases/get_pain_history.dart';
import 'package:ergonoworkcoah/features/pain/domain/usecases/record_pain_entry.dart';
import 'package:ergonoworkcoah/features/pain/presentation/bloc/pain_bloc.dart';
import 'package:ergonoworkcoah/features/pain/presentation/bloc/pain_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Exercises extends Mock implements GetExercisesByBodyRegion {}

class _Record extends Mock implements RecordPainEntry {}

class _History extends Mock implements GetPainHistory {}

void main() {
  final record = PainRecord(
      id: 'one',
      region: BodyRegion.neck,
      type: PainType.presion,
      evaScore: 4,
      recordedAt: DateTime(2026));
  const params = ExerciseParams(region: BodyRegion.neck, evaScore: 4);
  late _Exercises exercises;
  late _Record save;
  late PainBloc bloc;

  setUpAll(() {
    registerFallbackValue(params);
    registerFallbackValue(record);
  });
  setUp(() {
    exercises = _Exercises();
    save = _Record();
  });
  tearDown(() => bloc.close());
  void create() {
    bloc = PainBloc(
        getExercisesByBodyRegion: exercises,
        recordPainEntry: save,
        getPainHistory: _History());
  }

  testWidgets('changing region discards an earlier exercise response',
      (tester) async {
    create();
    final response = Completer<Either<Failure, List<Exercise>>>();
    when(() => exercises(any())).thenAnswer((_) => response.future);
    bloc.add(const PainRegionSelected(BodyRegion.neck));
    bloc.add(
        const PainExercisesRequested(region: BodyRegion.neck, evaScore: 4));
    await tester.pump();
    bloc.add(const PainRegionSelected(BodyRegion.lowerBack));
    await tester.pump();
    response.complete(Right(ExerciseSeedData.getExercises(BodyRegion.neck, 2)));
    await tester.pump();
    expect(bloc.state.selectedRegion, BodyRegion.lowerBack);
    expect(bloc.state.exercises, isEmpty);
    expect(bloc.state.isLoadingExercises, isFalse);
  });

  testWidgets('latest exercise request wins when responses arrive out of order',
      (tester) async {
    create();
    final first = Completer<Either<Failure, List<Exercise>>>();
    final second = Completer<Either<Failure, List<Exercise>>>();
    when(() => exercises(any())).thenAnswer((invocation) =>
        (invocation.positionalArguments.first as ExerciseParams).evaScore == 4
            ? first.future
            : second.future);
    bloc.add(
        const PainExercisesRequested(region: BodyRegion.neck, evaScore: 4));
    bloc.add(
        const PainExercisesRequested(region: BodyRegion.neck, evaScore: 2));
    await tester.pump();
    final latest = ExerciseSeedData.getExercises(BodyRegion.neck, 3);
    second.complete(Right(latest));
    await tester.pump();
    first.complete(Right(ExerciseSeedData.getExercises(BodyRegion.neck, 2)));
    await tester.pump();
    expect(bloc.state.exercises, latest);
  });

  testWidgets(
      'rapid save taps create one write and a failed save does not fetch exercises',
      (tester) async {
    create();
    final response = Completer<Either<Failure, String>>();
    when(() => save(any())).thenAnswer((_) => response.future);
    bloc.add(PainRecordSavedAndExercisesRequested(record));
    bloc.add(PainRecordSavedAndExercisesRequested(record));
    await tester.pump();
    verify(() => save(record)).called(1);
    response.complete(const Left(CacheFailure('No se pudo guardar')));
    await tester.pump();
    expect(bloc.state.recordSaved, isFalse);
    expect(bloc.state.isSaving, isFalse);
    expect(bloc.state.isLoadingExercises, isFalse);
    verifyNever(() => exercises(any()));
  });

  testWidgets(
      'a successful save is acknowledged once before exercises finish loading',
      (tester) async {
    create();
    final response = Completer<Either<Failure, List<Exercise>>>();
    when(() => save(any())).thenAnswer((_) async => const Right('one'));
    when(() => exercises(any())).thenAnswer((_) => response.future);
    bloc.add(PainRecordSavedAndExercisesRequested(record));
    await tester.pump();
    expect(bloc.state.recordSaved, isTrue);
    expect(bloc.state.isLoadingExercises, isTrue);
    bloc.add(const PainSaveAcknowledged());
    await tester.pump();
    response.complete(Right(ExerciseSeedData.getExercises(BodyRegion.neck, 2)));
    await tester.pump();
    expect(bloc.state.recordSaved, isFalse);
    expect(bloc.state.exercises, isNotEmpty);
  });
}
