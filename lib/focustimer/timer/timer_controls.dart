import 'package:flutter/material.dart';

import '../../helpers/globals.dart' as g show timerController,soundController;

class TimerControls extends StatelessWidget {

  const TimerControls({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          context,
          icon: g.timerController.isRunning ? Icons.pause : Icons.play_arrow,
          onPressed: g.timerController.isCompleted ? null : _handlePlayPause,
          isPrimary: true,
          scheme: scheme,
        ),
        _buildControlButton(
          context,
          icon: Icons.stop,
          onPressed: g.timerController.isIdle ? null : g.timerController.stopTimer,
          isPrimary: false,
          scheme: scheme,
        ),
        _buildControlButton(
          context,
          icon: Icons.refresh,
          onPressed: g.timerController.resetTimer,
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
    if (g.timerController.isRunning) {
      g.timerController.pauseTimer();
      if (g.soundController.isPlaying) {
        g.soundController.pauseAudio();
      }
    } else {
      g.timerController.startTimer();
      if (g.soundController.isPaused) {
        g.soundController.resumeAudio();
      } else if (g.soundController.isStopped) {
        g.soundController.playSound(g.soundController.currentSound);
      }
    }
  }
}
