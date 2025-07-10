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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withAlpha(10),
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Main Body
            Expanded(
              child: Center(
                child: Column(
                  spacing: 16,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StreamBuilder<PlayerState>(
                      stream: g.soundController.audioPlayer.onPlayerStateChanged,
                      builder: (context, snapshot) {
                        final isPlaying = snapshot.data == PlayerState.playing;
                        return Icon(
                          isPlaying ? Icons.music_note : Icons.music_off,
                          size: 80,
                          color: Theme.of(context).colorScheme.primary,
                        );
                      },
                    ),
                    Text(
                      'Current Sound:',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(200),
                      ),
                    ),
                    Container(
                      width: 300,
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: ListenableBuilder(
                          listenable: g.soundController,
                          builder: (context, child) {
                            return g.soundController.currentSound != null
                                ? Text(
                                    g.soundController.getDisplayName(
                                      g.soundController.currentSound,
                                    ),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : Text(
                                    'No Sound',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  );
                          },
                        ),
                      ),
                    ),
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
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.primaryContainer,
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
                                  if (isPlaying) {
                                    g.soundController.pauseAudio();
                                  } else {
                                    g.soundController.resumeAudio();
                                  }
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
            ),
          ],
        ),
      ),
    );
  }
}
