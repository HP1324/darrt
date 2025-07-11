import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:minimaltodo/focustimer/sound/sound_picker_dialog.dart';

import '../../helpers/globals.dart' as g show soundController;

class SoundPage extends StatefulWidget {
  const SoundPage({super.key});

  @override
  State<SoundPage> createState() => _SoundPageState();
}

class _SoundPageState extends State<SoundPage> {
  @override
  void initState() {
    super.initState();
    g.soundController.initialize();
  }

  void _showSoundPicker() {
    showDialog(
      context: context,
      builder: (context) => SoundPickerDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withAlpha(5),
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<PlayerState>(
              stream: g.soundController.audioPlayer.onPlayerStateChanged,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data == PlayerState.playing;
                return Icon(
                  isPlaying ? Icons.music_note : Icons.music_off,
                  size: 80,
                  color: theme.colorScheme.primary,
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Current Sound:',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(200),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 300,
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: ListenableBuilder(
                  listenable: g.soundController,
                  builder: (context, child) {
                    final current = g.soundController.currentSound;
                    return Text(
                      current != null
                          ? g.soundController.getDisplayName(current)
                          : 'No Sound',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            StreamBuilder<PlayerState>(
              stream: g.soundController.audioPlayer.onPlayerStateChanged,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data == PlayerState.playing;
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(40),
                      onTap: () {
                        if (g.soundController.currentSound != null) {
                          isPlaying
                              ? g.soundController.pauseAudio()
                              : g.soundController.resumeAudio();
                        }
                      },
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            key: ValueKey(isPlaying),
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _showSoundPicker,
              icon: const Icon(Icons.library_music),
              label: const Text('Choose Sound'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
