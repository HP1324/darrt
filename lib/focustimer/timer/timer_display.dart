// timer_controller.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:minimaltodo/focustimer/timer/timer_controller.dart';

import '../../helpers/globals.dart' as g show timerController;





class TimerDisplay extends StatelessWidget {

  const TimerDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            scheme.surface,
            scheme.surfaceContainer,
          ],
          stops: const [0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Progress ring
          CustomPaint(
            size: const Size(280, 280),
            painter: ProgressRingPainter(
              progress: g.timerController.progress,
              backgroundColor: scheme.outline.withValues(alpha: 0.2),
              progressColor: g.timerController.currentType == TimerType.focus
                  ? scheme.primary
                  : scheme.tertiary,
              strokeWidth: 8,
            ),
          ),
          // Timer content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  g.timerController.timerTypeLabel,
                  style: textTheme.titleMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  g.timerController.formattedTime,
                  style: textTheme.displayLarge?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w300,
                    fontSize: 48,
                  ),
                ),
                const SizedBox(height: 16),
                TimerStateIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  ProgressRingPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class TimerStateIndicator extends StatelessWidget {

  const TimerStateIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStateColor(scheme).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStateColor(scheme).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStateIcon(),
            size: 16,
            color: _getStateColor(scheme),
          ),
          const SizedBox(width: 6),
          Text(
            _getStateText(),
            style: textTheme.bodySmall?.copyWith(
              color: _getStateColor(scheme),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStateColor(ColorScheme scheme) {
    switch (g.timerController.state) {
      case TimerState.running:
        return scheme.primary;
      case TimerState.paused:
        return scheme.secondary;
      case TimerState.completed:
        return scheme.tertiary;
      case TimerState.idle:
        return scheme.outline;
    }
  }

  IconData _getStateIcon() {
    switch (g.timerController.state) {
      case TimerState.running:
        return Icons.play_arrow;
      case TimerState.paused:
        return Icons.pause;
      case TimerState.completed:
        return Icons.check_circle;
      case TimerState.idle:
        return Icons.timer;
    }
  }

  String _getStateText() {
    switch (g.timerController.state) {
      case TimerState.running:
        return 'Running';
      case TimerState.paused:
        return 'Paused';
      case TimerState.completed:
        return 'Completed';
      case TimerState.idle:
        return 'Ready';
    }
  }
}
