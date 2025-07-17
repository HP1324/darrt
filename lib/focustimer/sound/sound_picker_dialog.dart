import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:darrt/app/services/mini_box.dart';
import 'package:darrt/helpers/mini_logger.dart';

import '../../helpers/globals.dart' as g show audioController, adsController;

class SoundPickerDialog extends StatefulWidget {
  const SoundPickerDialog({super.key});

  @override
  State<SoundPickerDialog> createState() => _SoundPickerDialogState();
}

class _SoundPickerDialogState extends State<SoundPickerDialog> {
  // Map of sound files to their display names
  final Map<String, String> _builtInSounds = {
    'assets/sounds/brown_noise.mp3': 'Brown Noise',
    'assets/sounds/clock_ticking.mp3': 'Clock Ticking',
    'assets/sounds/fire.mp3': 'Crackling Fire',
    'assets/sounds/forest_1.mp3': 'Forest Ambience',
    'assets/sounds/forest_2.mp3': 'Deep Forest',
    'assets/sounds/mountain_winds.mp3': 'Mountain Winds',
    'assets/sounds/rain.mp3': 'Rain Sounds',
    'assets/sounds/silent_room.mp3': 'Silent Room',
    'assets/sounds/waterfall.mp3': 'Waterfall',
    'assets/sounds/birds_near_river.mp3': 'Birds + River',
  };

  @override
  void initState() {
    super.initState();
    g.audioController.initializeDialog();
    g.adsController.initializeFullPageAdOnCustomSoundPick();
  }

  Future<void> showFullPageAd()async{
    final pickCount = MiniBox().read('sound_pick_count') ?? 1;
    if(pickCount % 3 == 0){
      if(g.adsController.isFullPageOnCustomSoundPickAdLoaded){
        g.adsController.fullPageOnCustomSoundPickAd.show();
      }
    }
    MiniBox().write('sound_pick_count', pickCount + 1);
  }
  Future<void> _pickCustomSound() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      await showFullPageAd();
      if (result != null && result.files.single.path != null) {
        String customSoundPath = result.files.single.path!;
        String customSoundName = result.files.single.name.split('.').first;

        // Add to custom sounds list
        g.audioController.addCustomSound(customSoundPath, customSoundName);

        g.audioController.setSelectedSoundInDialog(customSoundPath);

        await g.audioController.playAudio(customSoundPath);
      }
    } catch (e) {
      MiniLogger.dp('Error picking custom sound: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error selecting custom sound'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.music_note,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(
            'Choose Sound',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      content: ListenableBuilder(
        listenable: g.audioController,
        builder: (context, child) {
          return ValueListenableBuilder<String?>(
            valueListenable: g.audioController.selectedSoundInDialog,
            builder: (context, selectedSound, child) {
              return SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    _buildSoundTile(
                      title: 'No Sound',
                      subtitle: 'Silent mode',
                      icon: Icons.volume_off,
                      value: null,
                      isSelected: selectedSound == null,
                    ),
                    const SizedBox(height: 8),
                    ..._builtInSounds.entries.map(
                          (entry) => _buildSoundTile(
                        title: entry.value,
                        subtitle: 'Built-in sound',
                        icon: _getSoundIcon(entry.key),
                        value: entry.key,
                        isSelected: selectedSound == entry.key,
                      ),
                    ),
                    ...g.audioController.customSounds.map(
                          (sound) => _buildSoundTile(
                        title: sound['name']!,
                        subtitle: 'Custom sound',
                        icon: Icons.audiotrack,
                        value: sound['path']!,
                        isSelected: selectedSound == sound['path'],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _pickCustomSound,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.secondary.withValues(alpha:0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Add Custom Sound',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Browse your device',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSoundTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String? value,
    required bool isSelected,
  }) {
    final scheme = ColorScheme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(
          color: scheme.primary,
          width: 2,
        )
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          g.audioController.setSelectedSoundInDialog(value);
          // Preview the sound but don't set it as current until Apply is pressed
          if (value != null) {
            await g.audioController.playAudio(value);
          } else {
            await g.audioController.stopAudio();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? scheme.primary.withValues(alpha: 0.1)
                      : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? scheme.primary
                      : scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: isSelected ? scheme.primary : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: scheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSoundIcon(String soundPath) {
    if (soundPath.contains('rain')) return Icons.water_drop;
    if (soundPath.contains('fire')) return Icons.local_fire_department;
    if (soundPath.contains('forest')) return Icons.forest;
    if (soundPath.contains('clock')) return Icons.access_time;
    if (soundPath.contains('wind')) return Icons.air;
    if (soundPath.contains('waterfall')) return Icons.water;
    if (soundPath.contains('noise')) return Icons.graphic_eq;
    if (soundPath.contains('birds')) return Icons.flutter_dash;
    return Icons.music_note;
  }
}