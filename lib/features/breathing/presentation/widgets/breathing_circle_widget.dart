import 'package:flutter/material.dart';

import '../bloc/breathing_state.dart';

class BreathingCircleWidget extends StatefulWidget {
  final BreathingPhase phase;
  final int secondsRemaining;
  final Color ambientColor;
  final bool isRunning;

  const BreathingCircleWidget({
    super.key,
    required this.phase,
    required this.secondsRemaining,
    required this.ambientColor,
    this.isRunning = true,
  });

  @override
  State<BreathingCircleWidget> createState() => _BreathingCircleWidgetState();
}

class _BreathingCircleWidgetState extends State<BreathingCircleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _updateAnimation();
  }

  @override
  void didUpdateWidget(BreathingCircleWidget old) {
    super.didUpdateWidget(old);
    if (old.phase != widget.phase || old.isRunning != widget.isRunning) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (!widget.isRunning) {
      _controller.stop();
      return;
    }
    final duration = Duration(seconds: widget.secondsRemaining);
    switch (widget.phase) {
      case BreathingPhase.inhaling:
        _controller.animateTo(1, duration: duration);
      case BreathingPhase.exhaling:
        _controller.animateBack(0, duration: duration);
      case BreathingPhase.holding:
        _controller.value = 1;
      case BreathingPhase.holdingAfterExhale:
        _controller.value = 0;
      default:
        _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.ambientColor.withValues(alpha: 0.08),
          ),
          child: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.ambientColor.withValues(alpha: 0.15),
                  border: Border.all(
                    color: widget.ambientColor.withValues(alpha: 0.6),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.ambientColor.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _phaseLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: widget.ambientColor,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.secondsRemaining}',
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: widget.ambientColor,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String get _phaseLabel {
    if (!widget.isRunning &&
        widget.phase != BreathingPhase.complete &&
        widget.phase != BreathingPhase.idle) {
      return 'En pausa';
    }
    switch (widget.phase) {
      case BreathingPhase.inhaling:
        return 'Inhala';
      case BreathingPhase.holding:
        return 'Mantén';
      case BreathingPhase.exhaling:
        return 'Exhala';
      case BreathingPhase.holdingAfterExhale:
        return 'Pausa';
      case BreathingPhase.complete:
        return '✓';
      default:
        return '●';
    }
  }
}
