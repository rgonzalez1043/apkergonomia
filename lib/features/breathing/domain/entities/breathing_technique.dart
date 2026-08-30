import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum BreathingScenario {
  deporte,
  estres,
  calma,
  foco,
  emergencia,
  recuperacion,
  pausa,
  energia
}

class BreathingTechnique extends Equatable {
  final String id;
  final String name;
  final String description;
  final BreathingScenario scenario;
  final int inhaleSeconds;
  final int holdAfterInhale;
  final int exhaleSeconds;
  final int holdAfterExhale;
  final int totalCycles;
  final String avatarGuideScript;
  final Color ambientColor;

  const BreathingTechnique({
    required this.id,
    required this.name,
    required this.description,
    required this.scenario,
    required this.inhaleSeconds,
    required this.holdAfterInhale,
    required this.exhaleSeconds,
    required this.holdAfterExhale,
    required this.totalCycles,
    required this.avatarGuideScript,
    required this.ambientColor,
  });

  int get totalCycleDuration =>
      inhaleSeconds + holdAfterInhale + exhaleSeconds + holdAfterExhale;
  int get totalDurationSeconds => totalCycleDuration * totalCycles;

  static List<BreathingTechnique> get defaults => [
        const BreathingTechnique(
          id: 'coherencia_cardiaca',
          name: 'Coherencia Cardíaca',
          description:
              'Sincroniza tu corazón y mente. Ideal antes del ejercicio o competición.',
          scenario: BreathingScenario.deporte,
          inhaleSeconds: 6,
          holdAfterInhale: 0,
          exhaleSeconds: 6,
          holdAfterExhale: 0,
          totalCycles: 10,
          avatarGuideScript:
              'Inhala lento contando hasta 6... ahora exhala suavemente durante 6 segundos.',
          ambientColor: Color(0xFF10B981),
        ),
        const BreathingTechnique(
          id: 'diafragmatica_profunda',
          name: 'Diafragmática Profunda',
          description:
              'Activa el sistema parasimpático. Reduce el cortisol rápidamente.',
          scenario: BreathingScenario.estres,
          inhaleSeconds: 4,
          holdAfterInhale: 0,
          exhaleSeconds: 6,
          holdAfterExhale: 0,
          totalCycles: 8,
          avatarGuideScript:
              'Inhala por la nariz 4 segundos, sintiendo cómo se expande tu abdomen...',
          ambientColor: Color(0xFF6366F1),
        ),
        const BreathingTechnique(
          id: '4_7_8_weil',
          name: '4-7-8 (Técnica Weil)',
          description: 'Induce relajación profunda y mejora el sueño.',
          scenario: BreathingScenario.calma,
          inhaleSeconds: 4,
          holdAfterInhale: 7,
          exhaleSeconds: 8,
          holdAfterExhale: 0,
          totalCycles: 6,
          avatarGuideScript:
              'Inhala por nariz 4 segundos... mantén 7... exhala por boca 8 segundos.',
          ambientColor: Color(0xFF0F172A),
        ),
        const BreathingTechnique(
          id: 'box_breathing',
          name: 'Box Breathing',
          description:
              'Mejora la concentración y reduce la ansiedad. Técnica usada por fuerzas especiales.',
          scenario: BreathingScenario.foco,
          inhaleSeconds: 4,
          holdAfterInhale: 4,
          exhaleSeconds: 4,
          holdAfterExhale: 4,
          totalCycles: 8,
          avatarGuideScript:
              'Visualiza un cuadrado: inhala 4... retén 4... exhala 4... pausa 4.',
          ambientColor: Color(0xFF2DD4BF),
        ),
        const BreathingTechnique(
          id: 'respiracion_coherente',
          name: 'Respiración Coherente',
          description:
              'Estabiliza el sistema nervioso en momentos de crisis emocional.',
          scenario: BreathingScenario.emergencia,
          inhaleSeconds: 5,
          holdAfterInhale: 0,
          exhaleSeconds: 5,
          holdAfterExhale: 0,
          totalCycles: 12,
          avatarGuideScript:
              'Respira lento y constante... 5 segundos adentro, 5 segundos afuera.',
          ambientColor: Color(0xFFF59E0B),
        ),
        const BreathingTechnique(
          id: 'pausa_activa',
          name: 'Pausa Activa Laboral',
          description: 'Recarga energía y reduce tensión en pausas de trabajo.',
          scenario: BreathingScenario.pausa,
          inhaleSeconds: 4,
          holdAfterInhale: 0,
          exhaleSeconds: 4,
          holdAfterExhale: 0,
          totalCycles: 6,
          avatarGuideScript:
              'Aprovecha esta pausa. Inhala y estira... exhala y suelta la tensión.',
          ambientColor: Color(0xFFEC4899),
        ),
        const BreathingTechnique(
          id: 'activacion_energia',
          name: 'Respiración Energizante',
          description:
              'Aumenta el nivel de energía y la claridad mental rápidamente.',
          scenario: BreathingScenario.energia,
          inhaleSeconds: 3,
          holdAfterInhale: 0,
          exhaleSeconds: 3,
          holdAfterExhale: 0,
          totalCycles: 15,
          avatarGuideScript:
              'Respira rápido y con intención... activa tu energía interior.',
          ambientColor: Color(0xFFFFD700),
        ),
        const BreathingTechnique(
          id: 'recuperacion_pranayama',
          name: 'Pranayama Alterna',
          description:
              'Equilibra ambos hemisferios cerebrales. Ideal para recuperación.',
          scenario: BreathingScenario.recuperacion,
          inhaleSeconds: 4,
          holdAfterInhale: 4,
          exhaleSeconds: 4,
          holdAfterExhale: 2,
          totalCycles: 8,
          avatarGuideScript:
              'Alterna fosas nasales. Tapa la derecha, inhala por la izquierda...',
          ambientColor: Color(0xFF818CF8),
        ),
      ];

  @override
  List<Object?> get props => [
        id,
        scenario,
        inhaleSeconds,
        holdAfterInhale,
        exhaleSeconds,
        holdAfterExhale,
        totalCycles
      ];
}
