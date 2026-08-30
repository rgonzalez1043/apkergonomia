import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../../core/constants/body_region.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/pain_record.dart';

abstract class PainLocalDataSource {
  Future<List<Exercise>> getExercisesByRegionAndStage(
      BodyRegion region, int evaStage);
  Future<String> savePainRecord(PainRecord record);
  Future<List<PainRecord>> getPainHistory({int limit = 50});
}

class PainLocalDataSourceImpl implements PainLocalDataSource {
  static const _painRecordsKey = 'pain_records';

  @override
  Future<List<Exercise>> getExercisesByRegionAndStage(
      BodyRegion region, int evaStage) async {
    return ExerciseSeedData.getExercises(region, evaStage);
  }

  @override
  Future<String> savePainRecord(PainRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_painRecordsKey) ?? [];
    // Use the record's own ID instead of generating a new one to avoid mismatch.
    final map = {
      'id': record.id,
      'region': record.region.name,
      'type': record.type.name,
      'evaScore': record.evaScore,
      'recordedAt': record.recordedAt.toIso8601String(),
      'exercisesCompleted': record.exercisesCompleted,
      'notes': record.notes,
    };
    existing.add(jsonEncode(map));
    await prefs.setStringList(_painRecordsKey, existing);
    return record.id;
  }

  @override
  Future<List<PainRecord>> getPainHistory({int limit = 50}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_painRecordsKey) ?? [];
    final records = <PainRecord>[];
    for (final s in raw) {
      try {
        final map = jsonDecode(s) as Map<String, dynamic>;
        records.add(PainRecord(
          id: map['id'] as String,
          region: BodyRegion.values.byName(map['region'] as String),
          type: PainType.values.byName(map['type'] as String),
          evaScore: map['evaScore'] as int,
          recordedAt: DateTime.parse(map['recordedAt'] as String),
          exercisesCompleted:
              List<String>.from(map['exercisesCompleted'] as List? ?? []),
          notes: map['notes'] as String?,
        ));
      } catch (_) {
        // Saltar registros corruptos
      }
    }
    // Sort by date descending (most recent first) to guarantee correct order
    // regardless of insertion order in SharedPreferences.
    records.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return records.take(limit).toList();
  }
}

// ─── Datos semilla: ejercicios para TODAS las regiones corporales ───────────
class ExerciseSeedData {
  static List<Exercise> get allExercises => List.unmodifiable(_allExercises);

  static List<Exercise> getExercises(BodyRegion region, int evaStage) {
    final all = _allExercises
        .where((e) => e.targetRegion == region && e.evaStage == evaStage)
        .toList();
    if (all.isNotEmpty) return all;
    // Fallback: cualquier etapa de la misma región
    final sameRegion =
        _allExercises.where((e) => e.targetRegion == region).toList();
    if (sameRegion.isNotEmpty) return sameRegion;
    // Último recurso: región genérica similar
    return _fallbackExercises(region);
  }

  static List<Exercise> _fallbackExercises(BodyRegion region) {
    return [
      Exercise(
        id: '${region.name}_generic',
        targetRegion: region,
        evaStage: 1,
        name: 'Movilidad articular suave',
        description:
            'Realiza movimientos lentos y controlados de la zona afectada, respetando tu rango de movimiento sin dolor.',
        postureFocus: 'Movimiento lento, sin rebotes, respira profundo',
        reps: 10,
        setsPerDay: 3,
        holdSeconds: 5,
        advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días consecutivos',
      ),
    ];
  }

  // ═════════════════════════════════════════════════════════════════════════
  // CATÁLOGO COMPLETO DE EJERCICIOS
  // ═════════════════════════════════════════════════════════════════════════

  static final List<Exercise> _allExercises = [
    // ─── CUELLO ──────────────────────────────────────────────────────────
    const Exercise(
      id: 'neck_1_1',
      targetRegion: BodyRegion.neck,
      evaStage: 1,
      name: 'Retracción cervical suave',
      description:
          'Sentado erguido, lleva la barbilla hacia atrás sin mover la cabeza hacia abajo. Mantén 5 segundos.',
      postureFocus: 'Mantén los hombros relajados y columna recta',
      reps: 10,
      setsPerDay: 3,
      holdSeconds: 5,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días consecutivos',
    ),
    const Exercise(
      id: 'neck_1_2',
      targetRegion: BodyRegion.neck,
      evaStage: 1,
      name: 'Flexión lateral cervical asistida',
      description:
          'Inclina la oreja hacia el hombro suavemente. Usa la mano para dar presión suave.',
      postureFocus: 'No elevar el hombro opuesto',
      reps: 5,
      setsPerDay: 2,
      holdSeconds: 20,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días consecutivos',
    ),
    const Exercise(
      id: 'neck_1_3',
      targetRegion: BodyRegion.neck,
      evaStage: 1,
      name: 'Rotación cervical suave',
      description:
          'Gira la cabeza hacia un lado lentamente hasta donde puedas sin dolor. Mantén 5 segundos.',
      postureFocus: 'Movimiento lento y controlado',
      reps: 8,
      setsPerDay: 2,
      holdSeconds: 5,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días consecutivos',
    ),
    const Exercise(
      id: 'neck_2_1',
      targetRegion: BodyRegion.neck,
      evaStage: 2,
      name: 'Estiramiento trapecio superior',
      description:
          'Lleva la oreja al hombro y con la mano opuesta da tracción suave. Mantén 30 seg.',
      postureFocus: 'Hombros caídos, respiración profunda',
      reps: 3,
      setsPerDay: 3,
      holdSeconds: 30,
      advancementCriteria: 'Dolor EVA ≤ 2 durante 3 días consecutivos',
    ),
    const Exercise(
      id: 'neck_2_2',
      targetRegion: BodyRegion.neck,
      evaStage: 2,
      name: 'Fortalecimiento isométrico cervical',
      description:
          'Coloca la mano en la frente y empuja suavemente sin mover la cabeza. Mantén 10 segundos.',
      postureFocus: 'Cuello neutro, sin tensión en mandíbula',
      reps: 8,
      setsPerDay: 3,
      holdSeconds: 10,
      advancementCriteria: 'Dolor EVA ≤ 2 durante 3 días consecutivos',
    ),
    const Exercise(
      id: 'neck_3_1',
      targetRegion: BodyRegion.neck,
      evaStage: 3,
      name: 'Movilidad cervical completa',
      description:
          'Realiza rotaciones completas lentas en ambas direcciones: flexión, extensión y laterales.',
      postureFocus: 'Amplitud máxima sin dolor',
      reps: 10,
      setsPerDay: 2,
      holdSeconds: 3,
      advancementCriteria: 'Mantén EVA 0-1 durante 7 días',
    ),

    // ─── HOMBROS (ambos) ────────────────────────────────────────────────
    const Exercise(
      id: 'shoulder_r_1_1',
      targetRegion: BodyRegion.shoulderRight,
      evaStage: 1,
      name: 'Péndulo de Codman',
      description:
          'Inclínate hacia adelante y deja que el brazo cuelgue. Realiza círculos pequeños con gravedad.',
      postureFocus: 'Hombro relajado, no fuerces el movimiento',
      reps: 20,
      setsPerDay: 3,
      holdSeconds: 0,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'shoulder_r_1_2',
      targetRegion: BodyRegion.shoulderRight,
      evaStage: 1,
      name: 'Rotación interna asistida',
      description:
          'Usa la mano sana para llevar el brazo afectado hacia la espalda suavemente.',
      postureFocus: 'Sin elevar el hombro',
      reps: 10,
      setsPerDay: 2,
      holdSeconds: 15,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'shoulder_r_2_1',
      targetRegion: BodyRegion.shoulderRight,
      evaStage: 2,
      name: 'Elevación de brazo en pared',
      description:
          'De frente a la pared, desliza los dedos hacia arriba lentamente. Baja con control.',
      postureFocus: 'No arquear la espalda, hombro abajo',
      reps: 10,
      setsPerDay: 3,
      holdSeconds: 3,
      advancementCriteria: 'Dolor EVA ≤ 2 durante 3 días',
    ),
    const Exercise(
      id: 'shoulder_r_3_1',
      targetRegion: BodyRegion.shoulderRight,
      evaStage: 3,
      name: 'Rotación externa con banda',
      description:
          'Brazo pegado al cuerpo, codo a 90°. Rota el brazo hacia afuera contra resistencia.',
      postureFocus: 'Codo fijo pegado al costado',
      reps: 12,
      setsPerDay: 3,
      holdSeconds: 3,
      advancementCriteria: 'Mantén EVA 0-1 durante 7 días',
    ),
    const Exercise(
      id: 'shoulder_l_1_1',
      targetRegion: BodyRegion.shoulderLeft,
      evaStage: 1,
      name: 'Péndulo de Codman',
      description:
          'Inclínate hacia adelante y deja que el brazo cuelgue. Realiza círculos pequeños con gravedad.',
      postureFocus: 'Hombro relajado, no fuerces el movimiento',
      reps: 20,
      setsPerDay: 3,
      holdSeconds: 0,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'shoulder_l_1_2',
      targetRegion: BodyRegion.shoulderLeft,
      evaStage: 1,
      name: 'Rotación interna asistida',
      description:
          'Usa la mano sana para llevar el brazo afectado hacia la espalda suavemente.',
      postureFocus: 'Sin elevar el hombro',
      reps: 10,
      setsPerDay: 2,
      holdSeconds: 15,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'shoulder_l_2_1',
      targetRegion: BodyRegion.shoulderLeft,
      evaStage: 2,
      name: 'Elevación de brazo en pared',
      description:
          'De frente a la pared, desliza los dedos hacia arriba lentamente. Baja con control.',
      postureFocus: 'No arquear la espalda, hombro abajo',
      reps: 10,
      setsPerDay: 3,
      holdSeconds: 3,
      advancementCriteria: 'Dolor EVA ≤ 2 durante 3 días',
    ),
    const Exercise(
      id: 'shoulder_l_3_1',
      targetRegion: BodyRegion.shoulderLeft,
      evaStage: 3,
      name: 'Rotación externa con banda',
      description:
          'Brazo pegado al cuerpo, codo a 90°. Rota el brazo hacia afuera contra resistencia.',
      postureFocus: 'Codo fijo pegado al costado',
      reps: 12,
      setsPerDay: 3,
      holdSeconds: 3,
      advancementCriteria: 'Mantén EVA 0-1 durante 7 días',
    ),

    // ─── ESPALDA SUPERIOR (ambos lados) ────────────────────────────────
    const Exercise(
      id: 'upperback_r_1_1',
      targetRegion: BodyRegion.upperBackRight,
      evaStage: 1,
      name: 'Retracción escapular',
      description:
          'Sentado, junta los omóplatos hacia atrás y abajo como si quisieras sostener un lápiz entre ellos.',
      postureFocus: 'Hombros abajo, cuello alargado',
      reps: 10,
      setsPerDay: 4,
      holdSeconds: 5,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'upperback_r_1_2',
      targetRegion: BodyRegion.upperBackRight,
      evaStage: 1,
      name: 'Estiramiento de pecho en puerta',
      description:
          'De pie en una puerta, apoya los antebrazos y estira el pecho abriendo los brazos.',
      postureFocus: 'No arquear la zona lumbar, core activo',
      reps: 3,
      setsPerDay: 3,
      holdSeconds: 20,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'upperback_l_1_1',
      targetRegion: BodyRegion.upperBackLeft,
      evaStage: 1,
      name: 'Retracción escapular',
      description:
          'Sentado, junta los omóplatos hacia atrás y abajo como si quisieras sostener un lápiz entre ellos.',
      postureFocus: 'Hombros abajo, cuello alargado',
      reps: 10,
      setsPerDay: 4,
      holdSeconds: 5,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'upperback_l_1_2',
      targetRegion: BodyRegion.upperBackLeft,
      evaStage: 1,
      name: 'Estiramiento de pecho en puerta',
      description:
          'De pie en una puerta, apoya los antebrazos y estira el pecho abriendo los brazos.',
      postureFocus: 'No arquear la lumbar, core activo',
      reps: 3,
      setsPerDay: 3,
      holdSeconds: 20,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),

    // ─── ESPALDA MEDIA ──────────────────────────────────────────────────
    const Exercise(
      id: 'midback_1_1',
      targetRegion: BodyRegion.midBack,
      evaStage: 1,
      name: 'Rotación de tronco sentado',
      description:
          'Sentado, gira el torso hacia un lado lentamente, apoyando una mano en la rodilla opuesta.',
      postureFocus: 'Caderas fijas, solo rota la columna',
      reps: 8,
      setsPerDay: 3,
      holdSeconds: 10,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'midback_1_2',
      targetRegion: BodyRegion.midBack,
      evaStage: 1,
      name: 'Gato-vaca suave',
      description:
          'En cuatro puntos: arquea y redondea la espalda suavemente. Movimiento controlado.',
      postureFocus: 'Muñecas bajo hombros, rodillas bajo caderas',
      reps: 10,
      setsPerDay: 2,
      holdSeconds: 3,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'midback_2_1',
      targetRegion: BodyRegion.midBack,
      evaStage: 2,
      name: 'Perro-pájaro (Bird Dog)',
      description:
          'En cuatro puntos: extiende brazo y pierna opuestos simultáneamente. Mantén 5 segundos.',
      postureFocus: 'Columna neutra, sin rotación de cadera',
      reps: 10,
      setsPerDay: 3,
      holdSeconds: 5,
      advancementCriteria: 'Dolor EVA ≤ 2 durante 3 días',
    ),

    // ─── ESPALDA BAJA ───────────────────────────────────────────────────
    const Exercise(
      id: 'lower_back_1_1',
      targetRegion: BodyRegion.lowerBack,
      evaStage: 1,
      name: 'Rodilla al pecho',
      description:
          'Acostado, lleva una rodilla al pecho y mantén. Alterna ambas piernas.',
      postureFocus: 'Espalda baja pegada al suelo',
      reps: 10,
      setsPerDay: 3,
      holdSeconds: 20,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'lower_back_1_2',
      targetRegion: BodyRegion.lowerBack,
      evaStage: 1,
      name: 'Cat-Cow suave',
      description:
          'En cuatro puntos: arquea y redondea la espalda suavemente. Movimiento controlado.',
      postureFocus: 'Muñecas bajo hombros, rodillas bajo caderas',
      reps: 10,
      setsPerDay: 2,
      holdSeconds: 3,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'lower_back_2_1',
      targetRegion: BodyRegion.lowerBack,
      evaStage: 2,
      name: 'Puente glúteo',
      description:
          'Acostado boca arriba, eleva las caderas contrayendo glúteos. Mantén 5 segundos.',
      postureFocus: 'No hiperextender la lumbar',
      reps: 12,
      setsPerDay: 3,
      holdSeconds: 5,
      advancementCriteria: 'Dolor EVA ≤ 2 durante 3 días',
    ),
    const Exercise(
      id: 'lower_back_2_2',
      targetRegion: BodyRegion.lowerBack,
      evaStage: 2,
      name: 'Perro-pájaro (Bird Dog)',
      description:
          'En cuatro puntos: extiende brazo y pierna opuestos simultáneamente. Mantén 5 segundos.',
      postureFocus: 'Columna neutra, sin rotación de cadera',
      reps: 10,
      setsPerDay: 3,
      holdSeconds: 5,
      advancementCriteria: 'Dolor EVA ≤ 2 durante 3 días',
    ),
    const Exercise(
      id: 'lower_back_3_1',
      targetRegion: BodyRegion.lowerBack,
      evaStage: 3,
      name: 'Plancha frontal',
      description:
          'Posición de plancha sobre antebrazos. Mantén columna neutra y core activo.',
      postureFocus: 'Sin hundir caderas ni elevar glúteos',
      reps: 3,
      setsPerDay: 1,
      holdSeconds: 30,
      advancementCriteria: 'Mantén EVA 0-1 durante 7 días',
    ),

    // ─── SACROILÍACA ────────────────────────────────────────────────────
    const Exercise(
      id: 'sacro_1_1',
      targetRegion: BodyRegion.sacroiliac,
      evaStage: 1,
      name: 'Inclinación de rodillas lateral',
      description:
          'Acostado boca arriba, rodillas dobladas y pies en el suelo. Inclina las rodillas suavemente lado a lado.',
      postureFocus: 'Hombros en el suelo, movimiento desde la cadera',
      reps: 10,
      setsPerDay: 3,
      holdSeconds: 3,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'sacro_2_1',
      targetRegion: BodyRegion.sacroiliac,
      evaStage: 2,
      name: 'Puente glúteo bilateral',
      description:
          'Acostado, eleva caderas contrayendo glúteos. Sube y baja con control.',
      postureFocus: 'Core activo, sin rotar la pelvis',
      reps: 12,
      setsPerDay: 3,
      holdSeconds: 5,
      advancementCriteria: 'Dolor EVA ≤ 2 durante 3 días',
    ),

    // ─── PECHO (ambos lados) ───────────────────────────────────────────
    const Exercise(
      id: 'chest_r_1_1',
      targetRegion: BodyRegion.chestRight,
      evaStage: 1,
      name: 'Apertura de pecho en puerta',
      description:
          'De pie en una puerta, apoya los antebrazos en el marco y estira el pecho avanzando un paso.',
      postureFocus: 'Columna recta, no arquear lumbar',
      reps: 3,
      setsPerDay: 3,
      holdSeconds: 20,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'chest_l_1_1',
      targetRegion: BodyRegion.chestLeft,
      evaStage: 1,
      name: 'Apertura de pecho en puerta',
      description:
          'De pie en una puerta, apoya los antebrazos en el marco y estira el pecho avanzando un paso.',
      postureFocus: 'Columna recta, no arquear lumbar',
      reps: 3,
      setsPerDay: 3,
      holdSeconds: 20,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),

    // ─── ABDOMEN ────────────────────────────────────────────────────────
    const Exercise(
      id: 'abdomen_1_1',
      targetRegion: BodyRegion.abdomen,
      evaStage: 1,
      name: 'Respiración diafragmática',
      description:
          'Acostado, una mano en el pecho y otra en el abdomen. Respira hinchando solo el abdomen.',
      postureFocus: 'El pecho no debe moverse',
      reps: 10,
      setsPerDay: 3,
      holdSeconds: 5,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'abdomen_2_1',
      targetRegion: BodyRegion.abdomen,
      evaStage: 2,
      name: 'Dead bug (insecto muerto)',
      description:
          'Acostado, brazos y piernas al techo. Baja brazo y pierna opuestos alternadamente sin tocar el suelo.',
      postureFocus: 'Lumbar pegada al suelo siempre',
      reps: 10,
      setsPerDay: 3,
      holdSeconds: 3,
      advancementCriteria: 'Dolor EVA ≤ 2 durante 3 días',
    ),

    // ─── BRAZOS (ambos lados) ──────────────────────────────────────────
    const Exercise(
      id: 'arm_r_1_1',
      targetRegion: BodyRegion.armRight,
      evaStage: 1,
      name: 'Péndulo de brazo',
      description:
          'Inclinado hacia adelante, deja el brazo colgar y haz movimientos circulares pequeños.',
      postureFocus: 'Brazo completamente relajado',
      reps: 15,
      setsPerDay: 3,
      holdSeconds: 0,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'arm_r_2_1',
      targetRegion: BodyRegion.armRight,
      evaStage: 2,
      name: 'Elevación de brazo en pared',
      description:
          'De frente a la pared, desliza los dedos hacia arriba lentamente.',
      postureFocus: 'Hombro abajo, sin arquear la espalda',
      reps: 10,
      setsPerDay: 3,
      holdSeconds: 3,
      advancementCriteria: 'Dolor EVA ≤ 2 durante 3 días',
    ),
    const Exercise(
      id: 'arm_l_1_1',
      targetRegion: BodyRegion.armLeft,
      evaStage: 1,
      name: 'Péndulo de brazo',
      description:
          'Inclinado hacia adelante, deja el brazo colgar y haz movimientos circulares pequeños.',
      postureFocus: 'Brazo completamente relajado',
      reps: 15,
      setsPerDay: 3,
      holdSeconds: 0,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'arm_l_2_1',
      targetRegion: BodyRegion.armLeft,
      evaStage: 2,
      name: 'Elevación de brazo en pared',
      description:
          'De frente a la pared, desliza los dedos hacia arriba lentamente.',
      postureFocus: 'Hombro abajo, sin arquear la espalda',
      reps: 10,
      setsPerDay: 3,
      holdSeconds: 3,
      advancementCriteria: 'Dolor EVA ≤ 2 durante 3 días',
    ),

    // ─── ANTEBRAZOS (ambos lados) ──────────────────────────────────────
    const Exercise(
      id: 'forearm_r_1_1',
      targetRegion: BodyRegion.forearmRight,
      evaStage: 1,
      name: 'Estiramiento de antebrazo',
      description:
          'Extiende el brazo, palma hacia arriba. Con la otra mano tira de los dedos hacia atrás.',
      postureFocus: 'Codo completamente extendido',
      reps: 3,
      setsPerDay: 4,
      holdSeconds: 20,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'forearm_l_1_1',
      targetRegion: BodyRegion.forearmLeft,
      evaStage: 1,
      name: 'Estiramiento de antebrazo',
      description:
          'Extiende el brazo, palma hacia arriba. Con la otra mano tira de los dedos hacia atrás.',
      postureFocus: 'Codo completamente extendido',
      reps: 3,
      setsPerDay: 4,
      holdSeconds: 20,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),

    // ─── MANOS / MUÑECAS (ambos lados) ─────────────────────────────────
    const Exercise(
      id: 'hand_r_1_1',
      targetRegion: BodyRegion.handRight,
      evaStage: 1,
      name: 'Extensión y flexión de muñeca',
      description:
          'Con el codo apoyado, sube y baja la mano lentamente. Rango sin dolor.',
      postureFocus: 'Antebrazo fijo, solo mueve la muñeca',
      reps: 15,
      setsPerDay: 3,
      holdSeconds: 3,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'hand_r_1_2',
      targetRegion: BodyRegion.handRight,
      evaStage: 1,
      name: 'Apertura y cierre de mano',
      description:
          'Cierra el puño con fuerza y luego abre la mano estirando los dedos al máximo.',
      postureFocus: 'Movimiento completo y controlado',
      reps: 15,
      setsPerDay: 3,
      holdSeconds: 3,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'hand_l_1_1',
      targetRegion: BodyRegion.handLeft,
      evaStage: 1,
      name: 'Extensión y flexión de muñeca',
      description:
          'Con el codo apoyado, sube y baja la mano lentamente. Rango sin dolor.',
      postureFocus: 'Antebrazo fijo, solo mueve la muñeca',
      reps: 15,
      setsPerDay: 3,
      holdSeconds: 3,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'hand_l_1_2',
      targetRegion: BodyRegion.handLeft,
      evaStage: 1,
      name: 'Apertura y cierre de mano',
      description:
          'Cierra el puño con fuerza y luego abre la mano estirando los dedos al máximo.',
      postureFocus: 'Movimiento completo y controlado',
      reps: 15,
      setsPerDay: 3,
      holdSeconds: 3,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),

    // ─── CADERAS (ambos lados) ─────────────────────────────────────────
    const Exercise(
      id: 'hip_r_1_1',
      targetRegion: BodyRegion.hipRight,
      evaStage: 1,
      name: 'Estiramiento piriforme',
      description:
          'Acostado, cruza el tobillo sobre la rodilla opuesta y acerca ambas piernas al pecho.',
      postureFocus: 'Espalda baja en contacto con el suelo',
      reps: 3,
      setsPerDay: 2,
      holdSeconds: 30,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'hip_r_2_1',
      targetRegion: BodyRegion.hipRight,
      evaStage: 2,
      name: 'Puente glúteo mono pierna',
      description:
          'Acostado, eleva caderas con ambas piernas. Luego extiende una pierna al aire manteniendo la cadera alta.',
      postureFocus: 'Caderas niveladas, no dejar caer de un lado',
      reps: 8,
      setsPerDay: 3,
      holdSeconds: 5,
      advancementCriteria: 'Dolor EVA ≤ 2 durante 3 días',
    ),
    const Exercise(
      id: 'hip_l_1_1',
      targetRegion: BodyRegion.hipLeft,
      evaStage: 1,
      name: 'Estiramiento piriforme',
      description:
          'Acostado, cruza el tobillo sobre la rodilla opuesta y acerca ambas piernas al pecho.',
      postureFocus: 'Espalda baja en contacto con el suelo',
      reps: 3,
      setsPerDay: 2,
      holdSeconds: 30,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'hip_l_2_1',
      targetRegion: BodyRegion.hipLeft,
      evaStage: 2,
      name: 'Puente glúteo mono pierna',
      description:
          'Acostado, eleva caderas con ambas piernas. Luego extiende una pierna al aire manteniendo la cadera alta.',
      postureFocus: 'Caderas niveladas, no dejar caer de un lado',
      reps: 8,
      setsPerDay: 3,
      holdSeconds: 5,
      advancementCriteria: 'Dolor EVA ≤ 2 durante 3 días',
    ),

    // ─── MUSLOS (ambos lados) ──────────────────────────────────────────
    const Exercise(
      id: 'thigh_r_1_1',
      targetRegion: BodyRegion.thighRight,
      evaStage: 1,
      name: 'Estiramiento de cuádriceps de pie',
      description:
          'De pie, sujeta el tobillo y llévalo hacia el glúteo. Mantén la rodilla apuntando al suelo.',
      postureFocus: 'Rodillas juntas, columna recta',
      reps: 3,
      setsPerDay: 3,
      holdSeconds: 20,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'thigh_r_2_1',
      targetRegion: BodyRegion.thighRight,
      evaStage: 2,
      name: 'Sentadilla parcial',
      description:
          'De pie, baja como si te sentaras, hasta 45°. Sube apretando glúteos y cuádriceps.',
      postureFocus: 'Rodillas no pasan la punta del pie',
      reps: 12,
      setsPerDay: 3,
      holdSeconds: 3,
      advancementCriteria: 'Dolor EVA ≤ 2 durante 3 días',
    ),
    const Exercise(
      id: 'thigh_l_1_1',
      targetRegion: BodyRegion.thighLeft,
      evaStage: 1,
      name: 'Estiramiento de cuádriceps de pie',
      description:
          'De pie, sujeta el tobillo y llévalo hacia el glúteo. Mantén la rodilla apuntando al suelo.',
      postureFocus: 'Rodillas juntas, columna recta',
      reps: 3,
      setsPerDay: 3,
      holdSeconds: 20,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'thigh_l_2_1',
      targetRegion: BodyRegion.thighLeft,
      evaStage: 2,
      name: 'Sentadilla parcial',
      description:
          'De pie, baja como si te sentaras, hasta 45°. Sube apretando glúteos y cuádriceps.',
      postureFocus: 'Rodillas no pasan la punta del pie',
      reps: 12,
      setsPerDay: 3,
      holdSeconds: 3,
      advancementCriteria: 'Dolor EVA ≤ 2 durante 3 días',
    ),

    // ─── RODILLAS (ambos lados) ────────────────────────────────────────
    const Exercise(
      id: 'knee_r_1_1',
      targetRegion: BodyRegion.kneeRight,
      evaStage: 1,
      name: 'Quad sets',
      description:
          'Sentado con pierna extendida, contrae el cuádriceps empujando la rodilla hacia el suelo. Mantén 10 seg.',
      postureFocus: 'Pierna completamente extendida',
      reps: 15,
      setsPerDay: 3,
      holdSeconds: 10,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'knee_r_1_2',
      targetRegion: BodyRegion.kneeRight,
      evaStage: 1,
      name: 'Elevación pierna extendida',
      description:
          'Acostado, con una rodilla doblada, levanta la pierna extendida hasta 45°. Mantén 3 seg.',
      postureFocus: 'Cuádriceps contraído, pie en 90°',
      reps: 15,
      setsPerDay: 3,
      holdSeconds: 3,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'knee_r_2_1',
      targetRegion: BodyRegion.kneeRight,
      evaStage: 2,
      name: 'Sentadilla en pared',
      description:
          'Espalda contra la pared, baja hasta 60° de flexión de rodilla. Mantén la posición.',
      postureFocus: 'Rodillas alineadas con los pies',
      reps: 3,
      setsPerDay: 3,
      holdSeconds: 20,
      advancementCriteria: 'Dolor EVA ≤ 2 durante 3 días',
    ),
    const Exercise(
      id: 'knee_l_1_1',
      targetRegion: BodyRegion.kneeLeft,
      evaStage: 1,
      name: 'Quad sets',
      description:
          'Sentado con pierna extendida, contrae el cuádriceps empujando la rodilla hacia el suelo. Mantén 10 seg.',
      postureFocus: 'Pierna completamente extendida',
      reps: 15,
      setsPerDay: 3,
      holdSeconds: 10,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'knee_l_1_2',
      targetRegion: BodyRegion.kneeLeft,
      evaStage: 1,
      name: 'Elevación pierna extendida',
      description:
          'Acostado, con una rodilla doblada, levanta la pierna extendida hasta 45°. Mantén 3 seg.',
      postureFocus: 'Cuádriceps contraído, pie en 90°',
      reps: 15,
      setsPerDay: 3,
      holdSeconds: 3,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'knee_l_2_1',
      targetRegion: BodyRegion.kneeLeft,
      evaStage: 2,
      name: 'Sentadilla en pared',
      description:
          'Espalda contra la pared, baja hasta 60° de flexión de rodilla. Mantén la posición.',
      postureFocus: 'Rodillas alineadas con los pies',
      reps: 3,
      setsPerDay: 3,
      holdSeconds: 20,
      advancementCriteria: 'Dolor EVA ≤ 2 durante 3 días',
    ),

    // ─── PANTORRILLAS (ambos lados) ────────────────────────────────────
    const Exercise(
      id: 'calf_r_1_1',
      targetRegion: BodyRegion.calfRight,
      evaStage: 1,
      name: 'Estiramiento de pantorrilla en pared',
      description:
          'De pie, apoya las manos en la pared. Pierna adelantada doblada, trasera recta con talón en el suelo.',
      postureFocus: 'Talón trasero siempre en el suelo',
      reps: 3,
      setsPerDay: 4,
      holdSeconds: 20,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'calf_r_2_1',
      targetRegion: BodyRegion.calfRight,
      evaStage: 2,
      name: 'Elevación de talones',
      description:
          'De pie, elévate sobre la punta de los pies contrayendo las pantorrillas. Baja con control.',
      postureFocus: 'Subida controlada, bajada lenta',
      reps: 15,
      setsPerDay: 3,
      holdSeconds: 2,
      advancementCriteria: 'Dolor EVA ≤ 2 durante 3 días',
    ),
    const Exercise(
      id: 'calf_l_1_1',
      targetRegion: BodyRegion.calfLeft,
      evaStage: 1,
      name: 'Estiramiento de pantorrilla en pared',
      description:
          'De pie, apoya las manos en la pared. Pierna adelantada doblada, trasera recta con talón en el suelo.',
      postureFocus: 'Talón trasero siempre en el suelo',
      reps: 3,
      setsPerDay: 4,
      holdSeconds: 20,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'calf_l_2_1',
      targetRegion: BodyRegion.calfLeft,
      evaStage: 2,
      name: 'Elevación de talones',
      description:
          'De pie, elévate sobre la punta de los pies contrayendo las pantorrillas. Baja con control.',
      postureFocus: 'Subida controlada, bajada lenta',
      reps: 15,
      setsPerDay: 3,
      holdSeconds: 2,
      advancementCriteria: 'Dolor EVA ≤ 2 durante 3 días',
    ),

    // ─── TOBILLOS (ambos lados) ────────────────────────────────────────
    const Exercise(
      id: 'ankle_r_1_1',
      targetRegion: BodyRegion.ankleRight,
      evaStage: 1,
      name: 'Bombeo de tobillo',
      description:
          'Sentado o acostado, mueve el pie hacia arriba y hacia abajo repetidamente como un pedal.',
      postureFocus: 'Solo mueve el tobillo, pierna fija',
      reps: 20,
      setsPerDay: 4,
      holdSeconds: 2,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'ankle_r_1_2',
      targetRegion: BodyRegion.ankleRight,
      evaStage: 1,
      name: 'Círculos de tobillo',
      description:
          'Haz círculos lentos y amplios con el pie en el sentido horario y antihorario.',
      postureFocus: 'Movimiento desde el tobillo, no la rodilla',
      reps: 10,
      setsPerDay: 3,
      holdSeconds: 0,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'ankle_r_2_1',
      targetRegion: BodyRegion.ankleRight,
      evaStage: 2,
      name: 'Elevación de talones unilateral',
      description:
          'De pie sobre un solo pie, elévate sobre la punta del pie. Baja con control.',
      postureFocus: 'Equilibrio, mira al frente',
      reps: 10,
      setsPerDay: 3,
      holdSeconds: 2,
      advancementCriteria: 'Dolor EVA ≤ 2 durante 3 días',
    ),
    const Exercise(
      id: 'ankle_l_1_1',
      targetRegion: BodyRegion.ankleLeft,
      evaStage: 1,
      name: 'Bombeo de tobillo',
      description:
          'Sentado o acostado, mueve el pie hacia arriba y hacia abajo repetidamente como un pedal.',
      postureFocus: 'Solo mueve el tobillo, pierna fija',
      reps: 20,
      setsPerDay: 4,
      holdSeconds: 2,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'ankle_l_1_2',
      targetRegion: BodyRegion.ankleLeft,
      evaStage: 1,
      name: 'Círculos de tobillo',
      description:
          'Haz círculos lentos y amplios con el pie en el sentido horario y antihorario.',
      postureFocus: 'Movimiento desde el tobillo, no la rodilla',
      reps: 10,
      setsPerDay: 3,
      holdSeconds: 0,
      advancementCriteria: 'Dolor EVA ≤ 4 durante 3 días',
    ),
    const Exercise(
      id: 'ankle_l_2_1',
      targetRegion: BodyRegion.ankleLeft,
      evaStage: 2,
      name: 'Elevación de talones unilateral',
      description:
          'De pie sobre un solo pie, elévate sobre la punta del pie. Baja con control.',
      postureFocus: 'Equilibrio, mira al frente',
      reps: 10,
      setsPerDay: 3,
      holdSeconds: 2,
      advancementCriteria: 'Dolor EVA ≤ 2 durante 3 días',
    ),
  ];
}
