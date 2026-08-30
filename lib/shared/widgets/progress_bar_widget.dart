import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class ErgoProgressBar extends StatelessWidget {
  final double value;
  final Color? color;
  final double height;
  final String? label;

  const ErgoProgressBar({
    super.key,
    required this.value,
    this.color,
    this.height = 8,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(height),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            backgroundColor: Theme.of(context).dividerColor,
            valueColor:
                AlwaysStoppedAnimation<Color>(color ?? AppColors.primary),
            minHeight: height,
          ),
        ),
      ],
    );
  }
}

class ScoreRing extends StatelessWidget {
  final double score;
  final double size;
  final Color? color;
  final String? centerLabel;

  const ScoreRing({
    super.key,
    required this.score,
    this.size = 80,
    this.color,
    this.centerLabel,
  });

  @override
  Widget build(BuildContext context) {
    final ringColor = color ?? AppColors.primary;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: size * 0.08,
            backgroundColor: Theme.of(context).dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(ringColor),
          ),
          Center(
            child: Text(
              centerLabel ?? '${score.round()}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: ringColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
