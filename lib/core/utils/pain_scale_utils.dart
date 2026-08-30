import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class PainScaleUtils {
  PainScaleUtils._();

  static Color getColorForEva(int eva) {
    if (eva == 0) return AppColors.painNone;
    if (eva <= 3) return AppColors.painMild;
    if (eva <= 6) return AppColors.painModerate;
    return AppColors.painSevere;
  }

  static String getLabelForEva(int eva) {
    if (eva == 0) return 'Sin dolor';
    if (eva <= 3) return 'Dolor leve';
    if (eva <= 6) return 'Dolor moderado';
    if (eva <= 8) return 'Dolor intenso';
    return 'Dolor insoportable';
  }

  static String getEmojiForEva(int eva) {
    if (eva == 0) return '😊';
    if (eva <= 2) return '🙂';
    if (eva <= 4) return '😐';
    if (eva <= 6) return '😟';
    if (eva <= 8) return '😣';
    return '😭';
  }

  static IconData getIconForEva(int eva) {
    if (eva == 0) return Icons.sentiment_very_satisfied_rounded;
    if (eva <= 2) return Icons.sentiment_satisfied_alt_rounded;
    if (eva <= 4) return Icons.sentiment_neutral_rounded;
    if (eva <= 6) return Icons.sentiment_dissatisfied_rounded;
    if (eva <= 8) return Icons.sentiment_very_dissatisfied_rounded;
    return Icons.sick_outlined;
  }

  static int getEvaStage(int eva) {
    if (eva >= 5) return 1;
    if (eva >= 3) return 2;
    return 3;
  }
}
