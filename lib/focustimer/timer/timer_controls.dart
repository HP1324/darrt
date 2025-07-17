import 'package:darrt/app/services/mini_box.dart';
import 'package:darrt/helpers/consts.dart';
import 'package:darrt/helpers/mini_logger.dart';
import 'package:flutter/material.dart';

import '../../helpers/globals.dart' as g show timerController, audioController;

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
          onPressed: g.timerController.isCompleted
              ? null
              : () async {
                  await _handleTimerPlayPause();

                },
          isPrimary: true,
          scheme: scheme,
        ),
        _buildControlButton(
          context,
          icon: Icons.stop,
          onPressed: g.timerController.isIdle
              ? null
              : () async {
                  await _handleStop();
                },
          isPrimary: false,
          scheme: scheme,
        ),
        _buildControlButton(
          context,
          icon: Icons.refresh,
          onPressed: () async {
            g.timerController.resetTimer();
            await g.audioController.pauseAudio();
          },
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

  Future<void> _handleTimerPlayPause()async{
    final handleSound = MiniBox().read(mPauseResumeSoundWithTimer);
    if (g.timerController.isRunning) {
      g.timerController.pauseTimer();
      if (handleSound && g.audioController.isPlaying) {
        await g.audioController.pauseAudio();
      }
    }else{
      g.timerController.startTimer();
      if(handleSound && !g.audioController.isPlaying){
        await g.audioController.resumeAudio();
      }
    }
  }

  Future<void> _handleSoundPlayPause()async{
    if (g.audioController.isPlaying && g.timerController.isPaused) {
      g.audioController.pauseAudio();
    }else{
      if (g.audioController.currentSound != null && !g.audioController.isPlaying) {
        MiniLogger.dp('Resuming audio');
        await g.audioController.resumeAudio();
      } else if (g.audioController.currentSound != null && g.audioController.isStopped) {
        await g.audioController.playAudio(g.audioController.currentSound);
      }
    }
  }
  Future<void> _handlePlayPause() async {
    if (g.timerController.isRunning) {
      g.timerController.pauseTimer();
      if (g.audioController.isPlaying) {
        await g.audioController.pauseAudio();
      }
    } else {
      g.timerController.startTimer();
      MiniLogger.dp("Timer has started");

      // Check if audio was previously playing (not stopped completely)
      if (g.audioController.currentSound != null && !g.audioController.isPlaying) {
        MiniLogger.dp('Resuming audio');
        await g.audioController.resumeAudio();
      } else if (g.audioController.currentSound != null && g.audioController.isStopped) {
        await g.audioController.playAudio(g.audioController.currentSound);
      }
    }
  }

  Future<void> _handleStop() async {
    if (g.timerController.isRunning || g.timerController.isPaused) {
      g.timerController.stopTimer();
      if (g.audioController.isPlaying) {
        g.audioController.pauseAudio();
      }
    }
  }
}
