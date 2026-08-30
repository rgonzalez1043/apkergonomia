import 'package:flutter/material.dart';

import '../../core/constants/app_dimensions.dart';

class ErgoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final double? borderRadius;
  final Border? border;

  const ErgoCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppDimensions.cardPadding),
        decoration: BoxDecoration(
          color: color ?? theme.cardColor,
          borderRadius:
              BorderRadius.circular(borderRadius ?? AppDimensions.radiusLg),
          border: border ??
              Border.all(
                color: theme.dividerColor,
                width: 1,
              ),
        ),
        child: child,
      ),
    );
  }
}
