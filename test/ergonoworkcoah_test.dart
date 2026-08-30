import 'package:ergonoworkcoah/core/utils/pain_scale_utils.dart';
import 'package:ergonoworkcoah/features/pain/data/datasources/pain_local_datasource.dart';
import 'package:ergonoworkcoah/features/pain/presentation/widgets/exercise_media_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Exercise media catalog', () {
    test('registers every seeded exercise exactly once', () {
      final exercises = ExerciseSeedData.allExercises;
      final ids = exercises.map((exercise) => exercise.id).toSet();

      expect(ids, hasLength(exercises.length));
      expect(ExerciseMediaCatalog.registeredExerciseIds, ids);

      for (final exercise in exercises) {
        final media = ExerciseMediaCatalog.forExercise(exercise.id);
        expect(media.key, isNot('video_unavailable'), reason: exercise.id);
        expect(media.isAvailable, isTrue, reason: exercise.id);
      }
    });

    test('all demonstrations are attributable real-person HTTPS videos', () {
      final videoIdPattern = RegExp(r'^[A-Za-z0-9_-]{11}$');

      for (final media in ExerciseMediaCatalog.allMedia) {
        expect(media.showsRealPerson, isTrue, reason: media.key);
        expect(videoIdPattern.hasMatch(media.youtubeVideoId), isTrue,
            reason: media.key);
        expect(media.sourceUri.scheme, 'https', reason: media.key);
        expect(media.sourceLabel, isNotEmpty, reason: media.key);
      }
    });

    test('similar knee movements remain assigned to the correct videos', () {
      expect(
        ExerciseMediaCatalog.forExercise('sacro_1_1').youtubeVideoId,
        '59gKM04R5bo',
      );
      expect(
        ExerciseMediaCatalog.forExercise('knee_r_1_2').youtubeVideoId,
        'GSw10hW1Kj8',
      );
    });
  });

  group('PainScaleUtils', () {
    test('maps pain scores to progressive exercise stages', () {
      expect(PainScaleUtils.getEvaStage(1), 3);
      expect(PainScaleUtils.getEvaStage(2), 3);
      expect(PainScaleUtils.getEvaStage(3), 2);
      expect(PainScaleUtils.getEvaStage(4), 2);
      expect(PainScaleUtils.getEvaStage(5), 1);
      expect(PainScaleUtils.getEvaStage(10), 1);
    });

    test('uses the expected severity boundaries', () {
      expect(PainScaleUtils.getLabelForEva(0), 'Sin dolor');
      expect(PainScaleUtils.getLabelForEva(3), 'Dolor leve');
      expect(PainScaleUtils.getLabelForEva(6), 'Dolor moderado');
      expect(PainScaleUtils.getLabelForEva(8), 'Dolor intenso');
      expect(PainScaleUtils.getLabelForEva(10), 'Dolor insoportable');
    });
  });
}
