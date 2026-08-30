class ExerciseVideo {
  final String key;
  final String youtubeVideoId;
  final String sourceLabel;
  final String sourcePageUrl;
  final bool showsRealPerson;

  const ExerciseVideo({
    required this.key,
    required this.youtubeVideoId,
    required this.sourceLabel,
    required this.sourcePageUrl,
    this.showsRealPerson = true,
  });

  bool get isAvailable => youtubeVideoId.isNotEmpty;

  Uri get youtubeUri =>
      Uri.parse('https://www.youtube.com/watch?v=$youtubeVideoId');

  Uri get sourceUri => Uri.parse(sourcePageUrl);
}

/// Catalog of real-person exercise videos embedded from their original host.
///
/// Videos are not downloaded, altered, or presented as an ErgoWorkCoach
/// production. Source attribution and exercise assignment remain explicit so
/// the catalog can be audited independently from the exercise prescriptions.
class ExerciseMediaCatalog {
  ExerciseMediaCatalog._();

  static const fallback = ExerciseVideo(
    key: 'video_unavailable',
    youtubeVideoId: '',
    sourceLabel: 'Video pendiente de validacion',
    sourcePageUrl: 'https://www.youtube.com/',
    showsRealPerson: false,
  );

  static ExerciseVideo forExercise(String exerciseId) {
    final mediaKey = _exerciseMediaKeys[exerciseId];
    if (mediaKey == null) return fallback;
    return _videos[mediaKey] ?? fallback;
  }

  static Set<String> get registeredExerciseIds =>
      Set.unmodifiable(_exerciseMediaKeys.keys);

  static Iterable<ExerciseVideo> get allMedia => _videos.values;

  static const _southTeesLibrary =
      'https://www.southtees.nhs.uk/services/physiotherapy/community-outpatient-physiotherapy-middlesbrough-redcar-and-cleveland/staff-area/menu/exercises/';
  static const _southTeesHand =
      'https://www.southtees.nhs.uk/services/physiotherapy/hand-therapy/hand-therapy-exercise-videos/';
  static const _oxfordLibrary =
      'https://www.ouh.nhs.uk/physiotherapy/outpatients/videos/';
  static const _bartsLibrary = 'https://www.bartshealth.nhs.uk/physiotherapy';

  static const Map<String, ExerciseVideo> _videos = {
    'neck_retraction': ExerciseVideo(
      key: 'neck_retraction',
      youtubeVideoId: 'QBKtIAqyj9o',
      sourceLabel: 'South Tees Hospitals NHS - fisioterapia',
      sourcePageUrl: _southTeesLibrary,
    ),
    'neck_lateral_stretch': ExerciseVideo(
      key: 'neck_lateral_stretch',
      youtubeVideoId: 'xvZ9_5lqcVI',
      sourceLabel: 'National University Hospital Singapore - fisioterapia',
      sourcePageUrl: 'https://www.youtube.com/watch?v=xvZ9_5lqcVI',
    ),
    'neck_rotation': ExerciseVideo(
      key: 'neck_rotation',
      youtubeVideoId: 'b6b_8mmexj4',
      sourceLabel: 'South Tees Hospitals NHS - fisioterapia',
      sourcePageUrl: _southTeesLibrary,
    ),
    'neck_isometric': ExerciseVideo(
      key: 'neck_isometric',
      youtubeVideoId: '0kWF968uFXY',
      sourceLabel: 'Kinetic Health - Dr. Brian Abelson',
      sourcePageUrl: 'https://www.youtube.com/watch?v=0kWF968uFXY',
    ),
    'neck_mobility': ExerciseVideo(
      key: 'neck_mobility',
      youtubeVideoId: 'VkL5lek03OI',
      sourceLabel: 'South Tees Hospitals NHS - fisioterapia',
      sourcePageUrl: _southTeesLibrary,
    ),
    'codman_pendulum': ExerciseVideo(
      key: 'codman_pendulum',
      youtubeVideoId: 'TidD7VfwVhg',
      sourceLabel: 'South Tees Hospitals NHS - fisioterapia',
      sourcePageUrl: _southTeesLibrary,
    ),
    'shoulder_internal_rotation': ExerciseVideo(
      key: 'shoulder_internal_rotation',
      youtubeVideoId: 'vR14UMfRrZM',
      sourceLabel: 'South Tees Hospitals NHS - fisioterapia',
      sourcePageUrl: _southTeesLibrary,
    ),
    'wall_walk': ExerciseVideo(
      key: 'wall_walk',
      youtubeVideoId: 'dSZg65nkVSQ',
      sourceLabel: 'South Tees Hospitals NHS - fisioterapia',
      sourcePageUrl: _southTeesLibrary,
    ),
    'external_rotation_band': ExerciseVideo(
      key: 'external_rotation_band',
      youtubeVideoId: '2A_gZy05TqY',
      sourceLabel: 'South Tees Hospitals NHS - fisioterapia',
      sourcePageUrl: _southTeesLibrary,
    ),
    'scapular_retraction': ExerciseVideo(
      key: 'scapular_retraction',
      youtubeVideoId: 'hNseglwRJhY',
      sourceLabel: 'South Tees Hospitals NHS - fisioterapia',
      sourcePageUrl: _southTeesLibrary,
    ),
    'doorway_stretch': ExerciseVideo(
      key: 'doorway_stretch',
      youtubeVideoId: 'sNq9bVP1QG8',
      sourceLabel: 'South Tees Hospitals NHS - fisioterapia',
      sourcePageUrl: _southTeesLibrary,
    ),
    'seated_twist': ExerciseVideo(
      key: 'seated_twist',
      youtubeVideoId: 'Lm7GDqIGa-I',
      sourceLabel: 'South Tees Hospitals NHS - fisioterapia',
      sourcePageUrl: _southTeesLibrary,
    ),
    'cat_cow': ExerciseVideo(
      key: 'cat_cow',
      youtubeVideoId: 'jnpFgCkN2LA',
      sourceLabel: 'South Tees Hospitals NHS - fisioterapia',
      sourcePageUrl: _southTeesLibrary,
    ),
    'bird_dog': ExerciseVideo(
      key: 'bird_dog',
      youtubeVideoId: '_o2-NZCRJm8',
      sourceLabel: 'Speare Memorial Hospital - RehabFit',
      sourcePageUrl:
          'https://spearehospital.com/rehabfit-exercise-of-the-week-the-bird-dog/',
    ),
    'knee_to_chest': ExerciseVideo(
      key: 'knee_to_chest',
      youtubeVideoId: 'LQ76gxJAZlE',
      sourceLabel: 'Oxford University Hospitals NHS - fisioterapia',
      sourcePageUrl: _oxfordLibrary,
    ),
    'glute_bridge': ExerciseVideo(
      key: 'glute_bridge',
      youtubeVideoId: 'NhisKl88VOA',
      sourceLabel: 'Oxford University Hospitals NHS - fisioterapia',
      sourcePageUrl: _oxfordLibrary,
    ),
    'plank': ExerciseVideo(
      key: 'plank',
      youtubeVideoId: 'vByrjbQHyWA',
      sourceLabel: 'Henry Ford Health - fisioterapia',
      sourcePageUrl: 'https://www.hap.org/blog/2016/08/plank',
    ),
    'knee_sway': ExerciseVideo(
      key: 'knee_sway',
      youtubeVideoId: '59gKM04R5bo',
      sourceLabel: 'South Tees Hospitals NHS - fisioterapia',
      sourcePageUrl: _southTeesLibrary,
    ),
    'diaphragmatic_breathing': ExerciseVideo(
      key: 'diaphragmatic_breathing',
      youtubeVideoId: 'CTY2T579YKE',
      sourceLabel: 'Hospital Universitario de La Princesa - Rehabilitacion',
      sourcePageUrl:
          'https://www.comunidad.madrid/hospital/laprincesa/profesionales/servicios-medicos/medicina-fisica-rehabilitacion',
    ),
    'dead_bug': ExerciseVideo(
      key: 'dead_bug',
      youtubeVideoId: 'DdUKPepLsTw',
      sourceLabel: 'Rehab My Patient - ejercicio terapeutico',
      sourcePageUrl: 'https://www.youtube.com/watch?v=DdUKPepLsTw',
    ),
    'forearm_stretch': ExerciseVideo(
      key: 'forearm_stretch',
      youtubeVideoId: 'T8kVzSE8hoQ',
      sourceLabel: 'South Tees Hospitals NHS - fisioterapia',
      sourcePageUrl: _southTeesLibrary,
    ),
    'wrist_flexion': ExerciseVideo(
      key: 'wrist_flexion',
      youtubeVideoId: 'dtwfwjMKWz4',
      sourceLabel: 'South Tees Hospitals NHS - terapia de mano',
      sourcePageUrl: _southTeesHand,
    ),
    'hand_open_close': ExerciseVideo(
      key: 'hand_open_close',
      youtubeVideoId: '0jJWmuSibTs',
      sourceLabel: 'South Tees Hospitals NHS - terapia de mano',
      sourcePageUrl: _southTeesHand,
    ),
    'piriformis_stretch': ExerciseVideo(
      key: 'piriformis_stretch',
      youtubeVideoId: 'UXZq95QcfBY',
      sourceLabel: 'East Suffolk and North Essex NHS - fisioterapia',
      sourcePageUrl:
          'https://www.esneft.nhs.uk/service/physiotherapy-finn-clinic/exercise-videos-and-advice/',
    ),
    'single_leg_bridge': ExerciseVideo(
      key: 'single_leg_bridge',
      youtubeVideoId: 'dDNyuCzQKhY',
      sourceLabel: 'Cornell Health - fisioterapia',
      sourcePageUrl:
          'https://health.cornell.edu/services/physical-therapy-massage/pt-exercise-videos',
    ),
    'quad_stretch_standing': ExerciseVideo(
      key: 'quad_stretch_standing',
      youtubeVideoId: 'AeENQBwA1dg',
      sourceLabel: 'Advantage Physiotherapy',
      sourcePageUrl: 'https://www.youtube.com/watch?v=AeENQBwA1dg',
    ),
    'partial_squat': ExerciseVideo(
      key: 'partial_squat',
      youtubeVideoId: 'WiW5PO4cnqc',
      sourceLabel: 'NHS Ayrshire and Arran - fisioterapia',
      sourcePageUrl: 'https://www.youtube.com/watch?v=WiW5PO4cnqc',
    ),
    'quad_set': ExerciseVideo(
      key: 'quad_set',
      youtubeVideoId: 'Srsrma2gCYY',
      sourceLabel: 'South Tees Hospitals NHS - fisioterapia',
      sourcePageUrl: _southTeesLibrary,
    ),
    'straight_leg_raise': ExerciseVideo(
      key: 'straight_leg_raise',
      youtubeVideoId: 'GSw10hW1Kj8',
      sourceLabel: 'South Tees Hospitals NHS - fisioterapia',
      sourcePageUrl: _southTeesLibrary,
    ),
    'wall_sit': ExerciseVideo(
      key: 'wall_sit',
      youtubeVideoId: '2EwWIc5nAAo',
      sourceLabel: 'Emory Healthcare - rehabilitacion',
      sourcePageUrl:
          'https://www.emoryhealthcare.org/centers-programs/acl-program/return-to-play/wall-sits',
    ),
    'calf_wall_stretch': ExerciseVideo(
      key: 'calf_wall_stretch',
      youtubeVideoId: '-IMZ90bI0Io',
      sourceLabel: 'Oxford University Hospitals NHS - fisioterapia',
      sourcePageUrl: _oxfordLibrary,
    ),
    'calf_raise': ExerciseVideo(
      key: 'calf_raise',
      youtubeVideoId: 'Nyo2ogQLvCg',
      sourceLabel: 'NHS Greater Glasgow and Clyde - fisioterapia',
      sourcePageUrl: 'https://www.youtube.com/watch?v=Nyo2ogQLvCg',
    ),
    'ankle_pump': ExerciseVideo(
      key: 'ankle_pump',
      youtubeVideoId: 'hh_fsJOpFjQ',
      sourceLabel: 'University Hospitals Plymouth NHS - fisioterapia',
      sourcePageUrl: 'https://www.youtube.com/watch?v=hh_fsJOpFjQ',
    ),
    'ankle_circle': ExerciseVideo(
      key: 'ankle_circle',
      youtubeVideoId: 't5gMOv3muUU',
      sourceLabel: 'South West UK Burn Care NHS - terapia',
      sourcePageUrl:
          'https://www.southwest-burncare-network.nhs.uk/_common/getdocument?id=295080',
    ),
    'single_calf_raise': ExerciseVideo(
      key: 'single_calf_raise',
      youtubeVideoId: '8etk1rMiHCU',
      sourceLabel: 'Barts Health NHS - fisioterapia',
      sourcePageUrl: _bartsLibrary,
    ),
  };

  static const Map<String, String> _exerciseMediaKeys = {
    'neck_1_1': 'neck_retraction',
    'neck_1_2': 'neck_lateral_stretch',
    'neck_1_3': 'neck_rotation',
    'neck_2_1': 'neck_lateral_stretch',
    'neck_2_2': 'neck_isometric',
    'neck_3_1': 'neck_mobility',
    'shoulder_r_1_1': 'codman_pendulum',
    'shoulder_r_1_2': 'shoulder_internal_rotation',
    'shoulder_r_2_1': 'wall_walk',
    'shoulder_r_3_1': 'external_rotation_band',
    'shoulder_l_1_1': 'codman_pendulum',
    'shoulder_l_1_2': 'shoulder_internal_rotation',
    'shoulder_l_2_1': 'wall_walk',
    'shoulder_l_3_1': 'external_rotation_band',
    'upperback_r_1_1': 'scapular_retraction',
    'upperback_r_1_2': 'doorway_stretch',
    'upperback_l_1_1': 'scapular_retraction',
    'upperback_l_1_2': 'doorway_stretch',
    'midback_1_1': 'seated_twist',
    'midback_1_2': 'cat_cow',
    'midback_2_1': 'bird_dog',
    'lower_back_1_1': 'knee_to_chest',
    'lower_back_1_2': 'cat_cow',
    'lower_back_2_1': 'glute_bridge',
    'lower_back_2_2': 'bird_dog',
    'lower_back_3_1': 'plank',
    'sacro_1_1': 'knee_sway',
    'sacro_2_1': 'glute_bridge',
    'chest_r_1_1': 'doorway_stretch',
    'chest_l_1_1': 'doorway_stretch',
    'abdomen_1_1': 'diaphragmatic_breathing',
    'abdomen_2_1': 'dead_bug',
    'arm_r_1_1': 'codman_pendulum',
    'arm_r_2_1': 'wall_walk',
    'arm_l_1_1': 'codman_pendulum',
    'arm_l_2_1': 'wall_walk',
    'forearm_r_1_1': 'forearm_stretch',
    'forearm_l_1_1': 'forearm_stretch',
    'hand_r_1_1': 'wrist_flexion',
    'hand_r_1_2': 'hand_open_close',
    'hand_l_1_1': 'wrist_flexion',
    'hand_l_1_2': 'hand_open_close',
    'hip_r_1_1': 'piriformis_stretch',
    'hip_r_2_1': 'single_leg_bridge',
    'hip_l_1_1': 'piriformis_stretch',
    'hip_l_2_1': 'single_leg_bridge',
    'thigh_r_1_1': 'quad_stretch_standing',
    'thigh_r_2_1': 'partial_squat',
    'thigh_l_1_1': 'quad_stretch_standing',
    'thigh_l_2_1': 'partial_squat',
    'knee_r_1_1': 'quad_set',
    'knee_r_1_2': 'straight_leg_raise',
    'knee_r_2_1': 'wall_sit',
    'knee_l_1_1': 'quad_set',
    'knee_l_1_2': 'straight_leg_raise',
    'knee_l_2_1': 'wall_sit',
    'calf_r_1_1': 'calf_wall_stretch',
    'calf_r_2_1': 'calf_raise',
    'calf_l_1_1': 'calf_wall_stretch',
    'calf_l_2_1': 'calf_raise',
    'ankle_r_1_1': 'ankle_pump',
    'ankle_r_1_2': 'ankle_circle',
    'ankle_r_2_1': 'single_calf_raise',
    'ankle_l_1_1': 'ankle_pump',
    'ankle_l_1_2': 'ankle_circle',
    'ankle_l_2_1': 'single_calf_raise',
  };
}
