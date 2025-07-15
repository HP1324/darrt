import 'package:flutter/material.dart';
import 'package:darrt/focustimer/sound/sound_picker_dialog.dart';

import '../../helpers/globals.dart' as g show audioController;

class SoundTab extends StatefulWidget {
  const SoundTab({super.key});

  @override
  State<SoundTab> createState() => _SoundTabState();
}

class _SoundTabState extends State<SoundTab> {
  void _showSoundPicker() {
    showDialog(
      context: context,
      builder: (context) => SoundPickerDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            scheme.primary.withAlpha(5),
            scheme.surface,
          ],
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ListenableBuilder(
                    listenable: g.audioController,
                    builder: (context, snapshot) {
                      final isPlaying = g.audioController.isPlaying;
                      return Icon(
                        isPlaying ? Icons.music_note : Icons.music_off,
                        size: 80,
                        color: scheme.primary,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Current Sound:',
                    style: textTheme.titleLarge?.copyWith(
                      color: scheme.onSurface.withAlpha(200),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 300,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: ListenableBuilder(
                        listenable: g.audioController,
                        builder: (context, child) {
                          final current = g.audioController.currentSound;
                          return Text(
                            current != null
                                ? g.audioController.getDisplayName(current)
                                : 'No Sound',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: scheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ),
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
          ),
          AudioControls(),
        ],
      ),
    );
  }
}

class AudioControls extends StatefulWidget {
  const AudioControls({super.key});

  @override
  State<AudioControls> createState() => _AudioControlsState();
}

class _AudioControlsState extends State<AudioControls> {
  void _playNextSound() {
    final currentSound = g.audioController.currentSound;
    final allSounds = g.audioController.getAllSounds();

    if (allSounds.isEmpty) return;

    int currentIndex = -1;
    if (currentSound != null) {
      currentIndex = allSounds.indexWhere((sound) => sound['path'] == currentSound);
    }

    // Get next sound (loop to beginning if at end)
    int nextIndex = (currentIndex + 1) % allSounds.length;
    g.audioController.playAudio(allSounds[nextIndex]['path']);
  }

  void _playPreviousSound() {
    // Get current sound index
    final currentSound = g.audioController.currentSound;
    final allSounds = g.audioController.getAllSounds();

    if (allSounds.isEmpty) return;

    int currentIndex = -1;
    if (currentSound != null) {
      currentIndex = allSounds.indexWhere((sound) => sound['path'] == currentSound);
    }

    // Get previous sound (loop to end if at beginning)
    int previousIndex = currentIndex <= 0 ? allSounds.length - 1 : currentIndex - 1;
    g.audioController.playAudio(allSounds[previousIndex]['path']);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      child: Column(
        children: [
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Previous Button
              IconButton(
                onPressed: _playPreviousSound,
                icon: const Icon(Icons.skip_previous),
                iconSize: 20,
                color: scheme.primary,
                style: IconButton.styleFrom(
                  backgroundColor: scheme.primary.withAlpha(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              // Play/Pause Button
              ListenableBuilder(
                listenable: g.audioController,
                builder: (context, child) {
                  final isPlaying = g.audioController.isPlaying;
                  final isPaused = g.audioController.isPaused;

                  return IconButton(
                    onPressed: () {
                      if (isPlaying) {
                        g.audioController.pauseAudio();
                      } else if (isPaused) {
                        g.audioController.resumeAudio();
                      } else {
                        // If stopped, play the current sound or first available
                        final currentSound = g.audioController.currentSound;
                        if (currentSound != null) {
                          g.audioController.playAudio(currentSound);
                        } else {
                          final allSounds = g.audioController.getAllSounds();
                          if (allSounds.isNotEmpty) {
                            g.audioController.playAudio(allSounds[0]['path']);
                          }
                        }
                      }
                    },
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    iconSize: 25,
                    color: scheme.onPrimary,
                    style: IconButton.styleFrom(
                      backgroundColor: scheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),

              // Next Button
              IconButton(
                onPressed: _playNextSound,
                icon: const Icon(Icons.skip_next),
                iconSize: 20,
                color: scheme.primary,
                style: IconButton.styleFrom(
                  backgroundColor: scheme.primary.withAlpha(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),

          // Audio progress slider
          ListenableBuilder(
            listenable: g.audioController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: scheme.outline.withAlpha(50),
                      width: 0.5,
                    ),
                  ),
                ),
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3.0,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
                    activeTrackColor: scheme.primary,
                    inactiveTrackColor: scheme.primary.withAlpha(76),
                    thumbColor: scheme.primary,
                    overlayColor: scheme.primary.withAlpha(51),
                  ),
                  child: Slider(
                    min: 0.0,
                    max: g.audioController.duration.inMilliseconds.toDouble(),
                    value: g.audioController.position.inMilliseconds
                        .clamp(0, g.audioController.duration.inMilliseconds)
                        .toDouble(),
                    onChanged: (value) {
                      g.audioController.setPosition(value);
                    },
                    onChangeEnd: (value) {
                      g.audioController.seek(Duration(milliseconds: value.toInt()));
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
