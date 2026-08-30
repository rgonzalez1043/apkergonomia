import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/pain_scale_utils.dart';

class PainScaleWidget extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const PainScaleWidget(
      {super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Escala EVA: $value/10',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Icon(
              PainScaleUtils.getIconForEva(value),
              size: 30,
              color: PainScaleUtils.getColorForEva(value),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sm),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: PainScaleUtils.getColorForEva(value),
            thumbColor: PainScaleUtils.getColorForEva(value),
            overlayColor:
                PainScaleUtils.getColorForEva(value).withValues(alpha: 0.2),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            label: '$value - ${PainScaleUtils.getLabelForEva(value)}',
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Sin dolor', style: Theme.of(context).textTheme.labelSmall),
            Text(
              PainScaleUtils.getLabelForEva(value),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: PainScaleUtils.getColorForEva(value),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text('Máximo', style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ],
    );
  }
}
