# ERGOWORKCOACH — Prompt de Arquitectura para Desarrollo Flutter

---

## CONTEXTO DEL PROYECTO

**ErgoWorkCoach** es una aplicación móvil multiplataforma (iOS/Android) que combina salud postural, bienestar emocional y mejora cognitiva mediante IA, gamificación y un avatar interactivo. Se desarrollará en **Flutter** (Dart) para garantizar una sola base de código compartida entre plataformas.

---

## PROMPT MAESTRO DE ARQUITECTURA

Actúa como arquitecto senior de aplicaciones Flutter. Debes diseñar y estructurar el proyecto completo de **ErgoWorkCoach**, una aplicación de salud integral con las siguientes características y restricciones:

---

## 1. STACK TECNOLÓGICO OBLIGATORIO

```
Framework:        Flutter 3.x (Dart 3.x)
Arquitectura:     Clean Architecture + BLoC Pattern
State Management: flutter_bloc / cubit
Navegación:       go_router (rutas declarativas)
Base de datos:    SQLite local (drift/isar) + Firebase Firestore (nube)
Autenticación:    Firebase Auth (email, Google, Apple)
Backend/API:      Firebase (Auth, Firestore, Storage, Functions)
IA/ML local:      Google ML Kit (pose detection, image labeling)
IA/ML remota:     OpenAI API (coaching, generación de planes)
Avatar 3D:        Rive (animaciones 2D/3D reactivas) o Three.js via WebView
Push Notifs:      Firebase Cloud Messaging (FCM)
Analytics:        Firebase Analytics + Crashlytics
Pagos:            RevenueCat (suscripciones iOS/Android unificadas)
CI/CD:            GitHub Actions + Fastlane
```

---

## 2. ESTRUCTURA DE DIRECTORIOS DEL PROYECTO

```
ergoworkcoach/
├── lib/
│   ├── main.dart
│   ├── app.dart                         # MaterialApp + GoRouter setup
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_typography.dart
│   │   │   ├── app_strings.dart
│   │   │   └── app_dimensions.dart
│   │   ├── errors/
│   │   │   ├── failures.dart
│   │   │   └── exceptions.dart
│   │   ├── network/
│   │   │   └── network_info.dart
│   │   ├── usecases/
│   │   │   └── usecase.dart             # Interfaz base UseCase<Type, Params>
│   │   ├── utils/
│   │   │   ├── date_utils.dart
│   │   │   ├── validators.dart
│   │   │   └── pain_scale_utils.dart
│   │   └── extensions/
│   │       ├── context_ext.dart
│   │       └── string_ext.dart
│   │
│   ├── config/
│   │   ├── router/
│   │   │   ├── app_router.dart          # GoRouter config + rutas nombradas
│   │   │   └── route_names.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── light_theme.dart
│   │   │   └── dark_theme.dart
│   │   └── injection/
│   │       └── injection_container.dart # GetIt DI container
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── onboarding/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── avatar/                      # Visual Avatar
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── work_coach/                  # Work Coach
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── pain/                        # Pain Manager
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── pain_record_model.dart
│   │   │   │   │   └── exercise_model.dart
│   │   │   │   ├── repositories/
│   │   │   │   └── datasources/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   │       ├── get_exercises_by_body_region.dart
│   │   │   │       ├── record_pain_entry.dart
│   │   │   │       └── get_pain_history.dart
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── pain_bloc.dart
│   │   │       │   ├── pain_event.dart
│   │   │       │   └── pain_state.dart
│   │   │       ├── pages/
│   │   │       │   ├── pain_map_page.dart
│   │   │       │   ├── pain_detail_page.dart
│   │   │       │   └── pain_history_page.dart
│   │   │       └── widgets/
│   │   │           ├── body_map_widget.dart     # SVG interactivo cuerpo humano
│   │   │           ├── pain_scale_widget.dart
│   │   │           └── exercise_card_widget.dart
│   │   │
│   │   ├── fitness_coach/               # Fitness Coach (análisis postural IA)
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── attitude_coach/              # Coach Actitud
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── breathing/                   # Entrenador Respiratorio
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       └── widgets/
│   │   │           └── breathing_circle_widget.dart  # Animación círculo expansivo
│   │   │
│   │   ├── gamification/               # Sistema de logros compartido
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── community/                  # Ranking y comunidad
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   └── settings/
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   │
│   └── shared/
│       ├── widgets/
│       │   ├── avatar_display_widget.dart     # Avatar Rive reutilizable
│       │   ├── motivational_message_widget.dart
│       │   ├── progress_bar_widget.dart
│       │   ├── achievement_badge_widget.dart
│       │   └── custom_bottom_nav.dart
│       ├── services/
│       │   ├── notification_service.dart
│       │   ├── ai_service.dart               # Wrapper OpenAI/Firebase ML
│       │   ├── analytics_service.dart
│       │   └── storage_service.dart
│       └── models/
│           └── user_profile_model.dart
│
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── assets/
│   ├── animations/                      # Archivos .riv (Rive)
│   │   ├── avatar_idle.riv
│   │   ├── avatar_breathing.riv
│   │   └── breathing_circle.riv
│   ├── images/
│   ├── svg/
│   │   └── body_map.svg                 # Mapa corporal SVG interactivo
│   ├── audio/
│   │   └── breathing_guides/
│   └── lottie/                          # Animaciones Lottie secundarias
│
├── pubspec.yaml
└── firebase.json
```

---

## 3. MÓDULOS Y FEATURES — ESPECIFICACIÓN DETALLADA

### 3.1 AUTH + ONBOARDING

```dart
// Flujo de pantallas:
// SplashScreen → OnboardingCarousel → AuthPage (login/register)
// → ProfileSetupWizard (5 pasos) → MainShell

// Preguntas del perfil inicial:
// 1. Ocupación (enum: administrativo, conductor, manual, teletrabajo, otro)
// 2. Horas sentado/día (enum: <2h, 2-4h, 4-6h, >6h)
// 3. Zonas de dolor recurrente (multiselect: lista BodyRegion)
// 4. Nivel actividad física (enum: sedentario, leve, moderado, intenso)
// 5. Objetivos prioritarios (multiselect: postura, estrés, energía, dolor, fitnes)

// Entidad UserProfile:
class UserProfile {
  final String uid;
  final String displayName;
  final OccupationType occupation;
  final SittingHours sittingHours;
  final List<BodyRegion> painAreas;
  final ActivityLevel activityLevel;
  final List<AppGoal> goals;
  final AvatarConfig avatarConfig;
  final SubscriptionTier tier;          // free | premium
  final DateTime createdAt;
}
```

---

### 3.2 VISUAL AVATAR

```dart
// Tecnología: Rive (animaciones reactivas en tiempo real)
// El avatar persiste en todas las secciones via shared/widgets/avatar_display_widget.dart

// Entidad AvatarConfig:
class AvatarConfig {
  // Ropa
  final ShoeStyle shoes;
  final PantsStyle pants;
  final TopStyle top;
  final String shoeColor;      // hex
  final String pantsColor;     // hex
  final String topColor;       // hex
  
  // Accesorios
  final GlassesStyle? glasses;
  final HatStyle? hat;
  final List<AccessoryItem> accessories;
  
  // Físico
  final HairStyle hair;
  final String hairColor;
  final EyeColor eyeColor;
  final SkinTone skinTone;
  final bool hasBeard;
  final BeardStyle? beardStyle;
  
  // Estado emocional dinámico
  final AvatarEmotion currentEmotion;  // happy|neutral|focused|proud|concerned
}

// BLoC:
// AvatarCubit: gestiona AvatarConfig, persiste en Firestore
// Eventos: UpdateClothing, UpdateHair, UpdateAccessory, SetEmotion
// El avatar reacciona con emoción según logros/progreso del usuario
```

**Pantallas a desarrollar:**
- `AvatarEditorPage` — editor completo con paneles por categoría
- `AvatarPreviewWidget` — vista 360° con Rive
- `ColorPickerWidget` — paleta + modo pintura libre

---

### 3.3 WORK COACH

```dart
// Flujo:
// WorkCoachPage → CaptureWorkspacePage → AnalysisResultPage
//              → HabitsCheckPage → RecommendationsPage

// Análisis de imagen con ML Kit Image Labeling + custom API call
// para detectar: ergonomía del espacio, posición de monitor, silla, etc.

// Entidad WorkspaceAnalysis:
class WorkspaceAnalysis {
  final String imageUrl;
  final OccupationType occupationType;
  final List<ErgonomicIssue> detectedIssues;
  final List<ErgonomicRecommendation> recommendations;
  final double ergonomicScore;         // 0-100
  final DateTime analyzedAt;
}

// BLoC:
// WorkCoachBloc:
//   Events: CaptureImage, AnalyzeWorkspace, SaveAnalysis, LoadHistory
//   States: Initial, Capturing, Analyzing, AnalysisComplete, Error

// Widgets clave:
// - CameraOverlayWidget: cuadrícula guía para foto de espacio
// - ComparisonSliderWidget: foto actual vs modelo ideal (slider interactivo)
// - ActiveBreakWidget: contador + animación de estiramiento
// - ErgonomicScoreWidget: indicador visual 0-100 con color
```

---

### 3.4 PAIN MANAGER

```dart
// MAPA CORPORAL: usar SVG interactivo con flutter_svg + GestureDetector
// Regiones definidas como paths SVG con ID mapeado a enum BodyRegion

enum BodyRegion {
  neck, shoulderLeft, shoulderRight,
  upperBackLeft, upperBackRight,
  midBack, lowerBack, sacroiliac,
  chestLeft, chestRight, abdomen,
  armLeft, armRight, forearmLeft, forearmRight,
  handLeft, handRight,
  hipLeft, hipRight,
  thighLeft, thighRight,
  kneeLeft, kneeRight,
  calfLeft, calfRight,
  ankleLeft, ankleRight
}

// Entidad PainRecord:
class PainRecord {
  final String id;
  final BodyRegion region;
  final PainType type;          // punzante|ardor|presión|constante|intermitente
  final int evaScore;           // 0-10
  final DateTime recordedAt;
  final List<String> exercisesCompleted;
}

// Entidad Exercise:
class Exercise {
  final String id;
  final BodyRegion targetRegion;
  final int evaStage;           // 1(5-7) | 2(3-4) | 3(≤2)
  final String name;
  final String description;
  final String postureFocus;
  final int reps;
  final int setsPerDay;
  final int holdSeconds;
  final String? videoAssetPath;
  final String? animationAssetPath;
  final String advancementCriteria;
}

// Base de datos local (Drift/Isar):
// Tablas: pain_records, exercises, exercise_completions
// Seed data: TODAS las tablas del documento (cuello, hombros, espalda, etc.)
// 13 regiones × 3 etapas × 3 ejercicios ≈ 117 ejercicios precargados

// Widgets:
// BodyMapWidget: SVG con hit testing por path ID → BodyRegion
// PainTypeSelector: chips seleccionables para tipo de dolor
// EVAScaleWidget: slider visual 0-10 con emojis
// ExercisePlayerWidget: animación + timer + rep counter
// PainHistoryChart: gráfico fl_chart mostrando evolución EVA
```

---

### 3.5 FITNESS COACH

```dart
// Tecnología IA: Google ML Kit Pose Detection (33 puntos articulares)
// Para análisis offline en dispositivo (privacidad, sin latencia)

// Flujo captura:
// FitnessCoachPage → PhotoCaptureGuide (5 vistas) → Processing → Results → Plan

enum PosturalView { frontal, posterior, lateralLeft, lateralRight, seated }

// Entidad PosturalAnalysis:
class PosturalAnalysis {
  final String userId;
  final Map<PosturalView, String> imageUrls;
  final List<PosturalDeviation> deviations;
  final double overallPostureScore;
  final TrainingPlan generatedPlan;
  final DateTime analyzedAt;
}

enum PosturalDeviation {
  forwardHead,        // Cabeza adelantada
  forwardShoulders,   // Hombros adelantados
  kyphosisDorsal,     // Cifosis dorsal
  hyperlordosis,      // Hiperlordosis lumbar
  functionalScoliosis,// Escoliosis funcional
  pelvicTilt,         // Pelvis inclinada
  pelvicRotation,     // Pelvis rotada
  kneeValgus,         // Rodillas valgo
  kneeVarus,          // Rodillas varo
  flatFoot,           // Pie plano
  headLateralTilt,    // Inclinación lateral cabeza
  scapularDyskinesis, // Desalineación escapular
  cervicalRectification // Rectificación cervical
}

// Árbol de decisión para asignar ejercicios según desviación detectada:
// Map<PosturalDeviation, List<PosturalExercise>> prescriptionMap

// Pantallas:
// CameraGuideWidget: líneas guía (cuadrícula + línea media vertical) sobre cámara
// PoseOverlayWidget: puntos articulares ML Kit sobre foto analizada
// PosturalDeviationCard: resumen visual de cada desviación
// TrainingPlanPage: lista de ejercicios con progresión básico→intermedio→avanzado
```

---

### 3.6 ATTITUDE COACH

```dart
// Integración con OpenAI API para mensajes personalizados y microlecturas
// Sistema de retos diarios con progresión mensual

// Entidad UserEmotionalState:
class UserEmotionalState {
  final String userId;
  final EmotionalProfile profile;      // autoexigente|ansioso|disperso|baja_autoestima|explorador
  final int currentStreakDays;
  final MoodType todayMood;            // emoji scale 1-5
  final DateTime updatedAt;
}

// Entidad DailyChallenge:
class DailyChallenge {
  final String id;
  final int weekNumber;                // 1-4
  final String theme;                  // autoconciencia, acción, zona_confort, autocompasión
  final String challengeText;
  final String motivationalMessage;
  final bool isCompleted;
  final DateTime scheduledDate;
}

// Servicios:
// AICoachService: llama OpenAI con contexto del perfil para generar mensajes únicos
// PomodoroService: temporizador motivacional con frases cada ciclo

// Widgets:
// DailyCheckInWidget: selector de estado emocional (emojis + texto)
// MicroReadingCard: tarjeta con extracto + fuente (Dispenza, Tracy, etc.)
// ChallengeCardWidget: reto del día con botón "Completar"
// WeeklyProgressWidget: calendario visual de constancia
// StreakCounterWidget: contador de racha con animación de fuego
```

---

### 3.7 BREATHING COACH

```dart
// Animación central: círculo expansivo sincronizado con fases de respiración
// Usar Rive (breathing_circle.riv) con controladores de estado

// 8 técnicas implementadas como objetos configurables:
class BreathingTechnique {
  final String id;
  final String name;
  final BreathingScenario scenario;    // deporte|estrés|calma|foco|emergencia|recuperación|pausa|energía
  final int inhaleSeconds;
  final int holdAfterInhale;
  final int exhaleSeconds;
  final int holdAfterExhale;
  final int totalCycles;
  final String avatarGuideScript;
  final String audioAssetPath;
  final Color ambientColor;            // color de fondo adaptado al escenario
}

// Técnicas precargadas:
// 1. Coherencia cardíaca (6-0-6-0)  → Deporte
// 2. Diafragmática profunda (4-0-6-0) → Estrés
// 3. 4-7-8 Weil (4-7-8-0)           → Calma/Sueño
// 4. Respiración coherente (5-0-5-0) → Crisis emocional
// 5. Box Breathing (4-4-4-4)         → Concentración
// 6. Pranayama alternada (manual)    → Recuperación
// 7. Activa + estiramiento (4-0-4-0) → Pausa laboral
// 8. Kapalabhati (ráfagas)           → Energía

// Widget principal:
// BreathingCircleWidget: animación Rive con fases (expand=inhale, hold, contract=exhale)
// AvatarBreathingWidget: avatar sincronizado con la respiración
// BreathingStatsWidget: sesiones completadas, minutos, tendencia semanal

// BLoC:
// BreathingBloc:
//   States: SelectingScenario | Preparing | Inhaling | Holding | Exhaling | SessionComplete
//   Timer: StreamSubscription que avanza fases automáticamente
```

---

### 3.8 GAMIFICATION ENGINE

```dart
// Sistema transversal a todos los módulos

// Entidad Achievement:
class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementCategory category;  // postura|dolor|respiración|actitud|trabajo
  final int xpReward;
  final String badgeAssetPath;
  final AchievementTrigger trigger;    // condición para desbloquear
}

// Entidad UserProgress:
class UserProgress {
  final String userId;
  final int totalXP;
  final int currentLevel;
  final List<String> unlockedAchievements;
  final Map<String, int> streaksByModule;  // módulo → días consecutivos
  final int weeklyRanking;
}

// Triggers automáticos (ejemplos):
// - PainCoach: 3 días seguidos con ejercicios → "Constante"
// - Breathing: 7 sesiones completadas → "Maestro del Aliento"
// - WorkCoach: primera foto analizada → "Espacio Saludable"
// - Avatar: primer look guardado → "Estilista Digital"
// - FitnessCoach: análisis postural completado → "Autoconocimiento"

// GamificationService: escucha eventos de todos los módulos via EventBus
// Cuando detecta trigger → crea Achievement → notifica UI → actualiza Firestore
```

---

## 4. NAVEGACIÓN — GoRouter

```dart
// Estructura de rutas:

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/splash',    builder: SplashPage),
    GoRoute(path: '/onboarding', builder: OnboardingPage),
    GoRoute(path: '/auth',      builder: AuthPage),
    GoRoute(path: '/setup',     builder: ProfileSetupWizard),

    ShellRoute(                  // MainShell con BottomNav
      builder: MainShell,
      routes: [
        GoRoute(path: '/home',         builder: HomePage),
        GoRoute(path: '/avatar',       builder: AvatarEditorPage),
        GoRoute(path: '/work-coach',   builder: WorkCoachPage,
          routes: [
            GoRoute(path: 'capture',   builder: CaptureWorkspacePage),
            GoRoute(path: 'results',   builder: WorkspaceAnalysisResultPage),
          ]
        ),
        GoRoute(path: '/pain',         builder: PainMapPage,
          routes: [
            GoRoute(path: ':region',   builder: PainDetailPage),
            GoRoute(path: 'history',   builder: PainHistoryPage),
          ]
        ),
        GoRoute(path: '/fitness',      builder: FitnessCoachPage,
          routes: [
            GoRoute(path: 'capture',   builder: PosturalCapturePage),
            GoRoute(path: 'results',   builder: PosturalAnalysisResultPage),
            GoRoute(path: 'plan',      builder: TrainingPlanPage),
          ]
        ),
        GoRoute(path: '/attitude',     builder: AttitudeCoachPage),
        GoRoute(path: '/breathing',    builder: BreathingPage),
        GoRoute(path: '/achievements', builder: AchievementsPage),
        GoRoute(path: '/settings',     builder: SettingsPage),
      ]
    ),
  ]
);
```

---

## 5. DESIGN SYSTEM

```dart
// Paleta de colores principal:
// Primario:    #2DD4BF (teal vibrante - bienestar)
// Secundario:  #6366F1 (índigo - tecnología/IA)
// Acento:      #F59E0B (ámbar - energía/logros)
// Background:  #0F172A (slate oscuro - premium)
// Surface:     #1E293B (slate medio)
// Error:       #EF4444
// Success:     #10B981

// Tipografía:
// Display:  'Nunito' (rounded, friendly, legible en mobile)
// Body:     'Inter' (clean, neutral, alta legibilidad)
// Mono:     'JetBrains Mono' (datos, scores)

// Componentes personalizados obligatorios:
// - ErgoCard: tarjeta con glassmorphism sutil
// - ErgoButton: botón con ripple y estado de carga
// - ErgoAvatar: contenedor del avatar Rive con halo animado
// - ScoreRing: anillo de progreso circular (para scores ergonómicos)
// - ModuleHero: hero image/animation para cada módulo

// Tema oscuro por defecto (premium look)
// Tema claro disponible en settings
```

---

## 6. GESTIÓN DE ESTADO (BLoC)

```dart
// REGLAS:
// - 1 BLoC por feature (no BLoC globales excepto: AuthBloc, UserProfileCubit, GamificationCubit)
// - Usar Cubit para estados simples (settings, avatar config)
// - Usar BLoC para flujos complejos con múltiples eventos (pain, fitness, work coach)
// - Nunca hacer llamadas async directas en Widgets; siempre via BLoC/Cubit

// BLoCs globales (en MaterialApp level):
// AuthBloc          → estado de sesión, token
// UserProfileCubit  → perfil de usuario cargado
// GamificationCubit → XP, nivel, logros
// ThemeCubit        → light/dark mode

// BLoCs por feature (dentro de cada página):
// PainBloc, WorkCoachBloc, FitnessCoachBloc
// AttitudeBloc, BreathingBloc, AvatarCubit

// Inyección de dependencias con GetIt + injectable
```

---

## 7. SERVICIOS IA

```dart
// 7.1 AIAnalysisService (análisis de imágenes)
class AIAnalysisService {
  // Workspace analysis: ML Kit + Firebase ML custom model
  Future<WorkspaceAnalysis> analyzeWorkspace(File image, OccupationType type);
  
  // Postural analysis: ML Kit Pose Detection local
  Future<PosturalAnalysis> analyzePosture(Map<PosturalView, File> images);
  
  // Pain recommendations: reglas deterministas desde base de datos local
  List<Exercise> getExercisesByRegionAndEVA(BodyRegion region, int evaScore);
}

// 7.2 AICoachService (generación de contenido personalizado)
class AICoachService {
  // OpenAI GPT para mensajes motivacionales únicos según perfil
  Future<String> generateMotivationalMessage(UserProfile profile, String context);
  
  // Generar plan de entrenamiento personalizado
  Future<TrainingPlan> generateTrainingPlan(PosturalAnalysis analysis);
  
  // Generar micro-lectura del día
  Future<MicroReading> generateDailyReading(EmotionalProfile profile);
}

// Nota: cachear respuestas AI en Firestore para evitar costos excesivos
// Regenerar solo cuando el perfil cambia significativamente
```

---

## 8. BASE DE DATOS

```dart
// LOCAL (Drift - SQLite):
// Tablas offline-first:
// - user_profile         (perfil local)
// - pain_records         (historial de dolor)
// - exercises            (catálogo completo precargado - 117 ejercicios)
// - exercise_completions (registro de ejercicios realizados)
// - breathing_sessions   (historial de respiración)
// - workspace_analyses   (historial de análisis de espacio)
// - daily_challenges     (retos precargados 30 días)

// NUBE (Firebase Firestore):
// Colecciones:
// - users/{uid}/profile
// - users/{uid}/achievements
// - users/{uid}/postural_analyses
// - users/{uid}/progress
// - community/rankings/{period}    → ranking semanal/mensual

// Estrategia: Local-first, sync en background cuando hay conexión
// Conflicto: "last-write-wins" con timestamp del servidor
```

---

## 9. NOTIFICACIONES

```dart
// FCM + flutter_local_notifications

// Tipos de notificaciones:
// 1. Pausas activas (configurable por usuario, default: cada 45 min en horario laboral)
// 2. Reto diario actitud (hora configurable, default: 8:00 AM)
// 3. Recordatorio respiración (default: 12:00 PM y 6:00 PM)
// 4. Streak en peligro ("¡Llevas X días de racha, no la rompas!")
// 5. Logro desbloqueado (push inmediato)
// 6. Recordatorio semanal análisis postural

// NotificationService:
class NotificationService {
  Future<void> scheduleActiveBreakReminders(TimeRange workingHours, int intervalMinutes);
  Future<void> scheduleDailyChallenge(TimeOfDay time);
  Future<void> sendAchievementUnlocked(Achievement achievement);
  Future<void> cancelAll();
}
```

---

## 10. MONETIZACIÓN (RevenueCat)

```dart
// Tiers:
// FREE: onboarding + work coach básico + pain (sin historial) + respiración (3 técnicas)
// PREMIUM ($X/mes): todo desbloqueado + IA personalizada + historial completo + avatar premium

// Implementar con RevenueCat:
// - Paywall screen con comparativa FREE vs PREMIUM
// - Paywalls contextuales al intentar acceder a feature premium
// - Trial gratuito 7 días
// - SubscriptionService: verifica tier en cada feature gate

class FeatureGate extends StatelessWidget {
  // Widget que envuelve features premium
  // Muestra paywall si tier == free
  final Widget child;
  final PremiumFeature feature;
}
```

---

## 11. FASES DE DESARROLLO RECOMENDADAS

### FASE 1 — MVP (8-10 semanas)
- Auth (Firebase Auth)
- Onboarding + UserProfile
- Avatar básico (2D con Rive, opciones limitadas)
- Pain Manager (mapa corporal + ejercicios, sin IA)
- Breathing (3 técnicas básicas)
- Gamification (logros simples)
- Navigation shell

### FASE 2 — Core Features (6-8 semanas)
- Work Coach (con análisis de imagen ML Kit)
- Fitness Coach (captura fotográfica guiada + análisis básico)
- Avatar completo (3D, customización full)
- Attitude Coach (retos diarios, sin IA)
- Notificaciones push

### FASE 3 — IA & Community (6-8 semanas)
- Integración OpenAI (mensajes personalizados)
- Análisis postural avanzado (ML Kit Pose Detection)
- Community / Rankings
- Monetización (RevenueCat)
- Analytics (Firebase Analytics)

### FASE 4 — Polish & Growth (4 semanas)
- Animaciones avanzadas Rive
- Dark/Light theme completo
- Accesibilidad (semantics, font scaling)
- A/B testing
- App Store + Play Store launch

---

## 12. DEPENDENCIAS pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_bloc: ^8.x
  
  # Navigation
  go_router: ^13.x
  
  # DI
  get_it: ^7.x
  injectable: ^2.x
  
  # Firebase
  firebase_core: ^2.x
  firebase_auth: ^4.x
  cloud_firestore: ^4.x
  firebase_storage: ^11.x
  firebase_messaging: ^14.x
  firebase_analytics: ^10.x
  firebase_crashlytics: ^3.x
  
  # Database local
  drift: ^2.x
  sqlite3_flutter_libs: ^0.5.x
  
  # IA / ML
  google_mlkit_pose_detection: ^0.9.x
  google_mlkit_image_labeling: ^0.7.x
  
  # HTTP / API
  dio: ^5.x
  
  # Animations
  rive: ^0.12.x
  lottie: ^3.x
  
  # Camera / Image
  camera: ^0.10.x
  image_picker: ^1.x
  image: ^4.x
  flutter_svg: ^2.x
  
  # Notifications
  flutter_local_notifications: ^16.x
  
  # Charts
  fl_chart: ^0.66.x
  
  # Monetization
  purchases_flutter: ^6.x  # RevenueCat
  
  # Utils
  intl: ^0.18.x
  shared_preferences: ^2.x
  connectivity_plus: ^5.x
  permission_handler: ^11.x
  uuid: ^4.x
  equatable: ^2.x
  dartz: ^0.10.x            # Functional programming (Either)
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.x
  mocktail: ^1.x
  injectable_generator: ^2.x
  drift_dev: ^2.x
  build_runner: ^2.x
  flutter_lints: ^3.x
```

---

## 13. INSTRUCCIONES PARA EL LLM/DESARROLLADOR

Al implementar este proyecto, seguir este orden y estas reglas:

1. **Nunca mezclar lógica de negocio en Widgets.** Toda lógica va en BLoC/Cubit o en los casos de uso del dominio.

2. **El mapa corporal de Pain** debe implementarse con `flutter_svg` y hit-testing por ID de path SVG, mapeado a `BodyRegion`. No usar imágenes rasterizadas.

3. **Los 117 ejercicios** del documento deben estar como seed data en la base de datos Drift al primer inicio de la app (AppDatabase.seedExercises()).

4. **El avatar Rive** debe tener al menos 5 estados de emoción controlados por `StateMachineController`. La emoción cambia automáticamente según eventos (logro → happy, inactividad 3 días → concerned).

5. **La animación de respiración** usa un `RiveAnimationController` con inputs `Float` para inhaleProgress, holdProgress, exhaleProgress, sincronizados con el timer del BLoC.

6. **Cada módulo** tiene su propio `_injection.dart` con los bindings de GetIt para ese módulo, registrado en el contenedor principal.

7. **Error handling**: usar `Either<Failure, Success>` de dartz en todos los repositorios. Los BLoC mapean `Left` a estados de error con mensajes user-friendly.

8. **Offline first**: todas las funciones críticas (ver ejercicios, registrar dolor, sesión de respiración) deben funcionar sin internet. Sync en background cuando hay conexión.

9. **Tests obligatorios**: al menos 1 unit test por UseCase, 1 bloc_test por BLoC, 1 widget test por pantalla principal.

10. **Internacionalización**: usar `flutter_localizations` con soporte inicial español (es_CL). Preparar la estructura para inglés en fase posterior.

---

*Documento generado para desarrollo de ErgoWorkCoach — versión 1.0*
*Stack: Flutter 3.x | Firebase | ML Kit | OpenAI | Rive | RevenueCat*
