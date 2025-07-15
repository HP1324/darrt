import 'package:flutter/material.dart';
import 'package:darrt/focustimer/sound/sound_picker_dialog.dart';

import '../../helpers/globals.dart' as g show audioController;

class SoundPage extends StatefulWidget {
  const SoundPage({super.key});

  @override
  State<SoundPage> createState() => _SoundPageState();
}

class _SoundPageState extends State<SoundPage> {
  void _showSoundPicker() {
    showDialog(
      context: context,
      builder: (context) => SoundPickerDialog(),
    );
  }

  void _playNextSound() {
    final currentSound = g.audioController.currentSound;
    final allSounds = _getAllSounds();

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
    final allSounds = _getAllSounds();

    if (allSounds.isEmpty) return;

    int currentIndex = -1;
    if (currentSound != null) {
      currentIndex = allSounds.indexWhere((sound) => sound['path'] == currentSound);
    }

    // Get previous sound (loop to end if at beginning)
    int previousIndex = currentIndex <= 0 ? allSounds.length - 1 : currentIndex - 1;
    g.audioController.playAudio(allSounds[previousIndex]['path']);
  }

  List<Map<String, String>> _getAllSounds() {
    // Built-in sounds
    final builtInSounds = [
      {'path': 'assets/sounds/brown_noise.mp3', 'name': 'Brown Noise'},
      {'path': 'assets/sounds/clock_ticking.mp3', 'name': 'Clock Ticking'},
      {'path': 'assets/sounds/fire.mp3', 'name': 'Crackling Fire'},
      {'path': 'assets/sounds/forest_1.mp3', 'name': 'Forest Ambience'},
      {'path': 'assets/sounds/forest_2.mp3', 'name': 'Deep Forest'},
      {'path': 'assets/sounds/mountain_winds.mp3', 'name': 'Mountain Winds'},
      {'path': 'assets/sounds/rain.mp3', 'name': 'Rain Sounds'},
      {'path': 'assets/sounds/silent_room.mp3', 'name': 'Silent Room'},
      {'path': 'assets/sounds/waterfall.mp3', 'name': 'Waterfall'},
      {'path': 'assets/sounds/birds_near_river.mp3', 'name': 'Birds + River'},
    ];

    // Combine with custom sounds
    return [...builtInSounds, ...g.audioController.customSounds];
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
          // Player Controller Bar - Sticks to top
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: scheme.outline.withAlpha(50),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
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
                            final allSounds = _getAllSounds();
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

                // Stop Button
                // ListenableBuilder(
                //   listenable: g.audioController,
                //   builder: (context, child) {
                //     final isPlaying = g.audioController.isPlaying;
                //     final isPaused = g.audioController.isPaused;
                //
                //     return IconButton(
                //       onPressed: (isPlaying || isPaused)
                //           ? () => g.audioController.stopAudio()
                //           : null,
                //       icon: const Icon(Icons.stop),
                //       iconSize: 25,
                //       color: (isPlaying || isPaused) ? scheme.error : scheme.outline,
                //       style: IconButton.styleFrom(
                //         backgroundColor: (isPlaying || isPaused)
                //             ? scheme.error.withAlpha(20)
                //             : scheme.outline.withAlpha(10),
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(12),
                //         ),
                //       ),
                //     );
                //   },
                // ),

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
          ),
          ListenableBuilder(
           listenable:  g.audioController,
            builder: (context,child) {
              return Slider(
                min: 0.0,
                max: g.audioController.duration.inMilliseconds.toDouble(),
                value: g.audioController.position.inMilliseconds.clamp(0, g.audioController.duration.inMilliseconds).toDouble(),
                onChanged: (value) { g.audioController.setPosition(value);},
                onChangeEnd: (value){g.audioController.seek(Duration(milliseconds: value.toInt()));},
              );
            }
          ),
          // Rest of the content - Centered
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
        ],
      ),
    );
  }
}
