import 'package:flutter/material.dart';
import 'package:minimaltodo/focustimer/timer/timer_controller.dart';

class TimerControls extends StatelessWidget {
  final TimerController controller;

  const TimerControls({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          context,
          icon: controller.isRunning ? Icons.pause : Icons.play_arrow,
          onPressed: controller.isCompleted ? null : _handlePlayPause,
          isPrimary: true,
          scheme: scheme,
        ),
        _buildControlButton(
          context,
          icon: Icons.stop,
          onPressed: controller.isIdle ? null : controller.stopTimer,
          isPrimary: false,
          scheme: scheme,
        ),
        _buildControlButton(
          context,
          icon: Icons.refresh,
          onPressed: controller.resetTimer,
          isPrimary: false,
          scheme: scheme,
        ),
      ],
    );
  }

  Widget _buildControlButton(
      BuildContext context, {
        required IconData icon,
        required VoidCallback? onPressed,
        required bool isPrimary,
        required ColorScheme scheme,
      }) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Material(
        color: isPrimary ? scheme.primary : scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        elevation: isPrimary ? 4 : 0,
        shadowColor: scheme.shadow.withValues(alpha: 0.3),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Icon(
            icon,
            color: isPrimary ? scheme.onPrimary : scheme.onSurfaceVariant,
            size: 28,
          ),
        ),
      ),
    );
  }

  void _handlePlayPause() {
    if (controller.isRunning) {
      controller.pauseTimer();
    } else {
      controller.startTimer();
    }
  }
}