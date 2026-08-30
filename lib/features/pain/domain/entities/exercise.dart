import 'package:equatable/equatable.dart';

import '../../../../core/constants/body_region.dart';

class Exercise extends Equatable {
  final String id;
  final BodyRegion targetRegion;
  final int evaStage;
  final String name;
  final String description;
  final String postureFocus;
  final int reps;
  final int setsPerDay;
  final int holdSeconds;
  final String? videoAssetPath;
  final String? animationAssetPath;
  final String advancementCriteria;

  const Exercise({
    required this.id,
    required this.targetRegion,
    required this.evaStage,
    required this.name,
    required this.description,
    required this.postureFocus,
    required this.reps,
    required this.setsPerDay,
    required this.holdSeconds,
    this.videoAssetPath,
    this.animationAssetPath,
    required this.advancementCriteria,
  });

  @override
  List<Object?> get props =>
      [id, targetRegion, evaStage, name, reps, setsPerDay, holdSeconds];
}
