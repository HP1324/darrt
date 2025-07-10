import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';

class FocusTimerPage extends StatefulWidget {
  const FocusTimerPage({super.key});

  @override
  State<FocusTimerPage> createState() => _FocusTimerPageState();
}

class _FocusTimerPageState extends State<FocusTimerPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SoundPickerExample(),
    );
  }
}

class SoundPickerDialog extends StatefulWidget {
  final String? selectedSound;
  final Function(String?) onSoundSelected;
  final AudioPlayer? audioPlayer;

  const SoundPickerDialog({
    super.key,
    this.selectedSound,
    required this.onSoundSelected,
    this.audioPlayer,
  });

  @override
  State<SoundPickerDialog> createState() => _SoundPickerDialogState();
}

class _SoundPickerDialogState extends State<SoundPickerDialog> {
  late AudioPlayer _audioPlayer;
  String? _selectedSound;
  String? _customSoundName;

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
  };

  @override
  void initState() {
    super.initState();
    _audioPlayer = widget.audioPlayer ?? AudioPlayer();
    _selectedSound = widget.selectedSound;

    // Set loop mode for continuous playback
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  @override
  void dispose() {
    if (widget.audioPlayer == null) {
      _audioPlayer.dispose();
    }
    super.dispose();
  }

  Future<void> _playSound(String? soundPath) async {
    try {
      await _audioPlayer.stop();

      if (soundPath == null) {
        return; // No sound selected
      }

      if (soundPath.startsWith('assets/')) {
        await _audioPlayer.play(AssetSource(soundPath.replaceFirst('assets/', '')));
      } else {
        await _audioPlayer.play(DeviceFileSource(soundPath));
      }
    } catch (e) {
      print('Error playing sound: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing sound: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickCustomSound() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        String customSoundPath = result.files.single.path!;
        String customSoundName = result.files.single.name;

        setState(() {
          _selectedSound = customSoundPath;
          _customSoundName = customSoundName;
        });

        await _playSound(customSoundPath);
      }
    } catch (e) {
      print('Error picking custom sound: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error selecting custom sound'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getDisplayName(String? soundPath) {
    if (soundPath == null) return 'No Sound';

    if (_builtInSounds.containsKey(soundPath)) {
      return _builtInSounds[soundPath]!;
    }

    // For custom sounds, return the stored name or extract from path
    return _customSoundName ?? soundPath.split('/').last.split('.').first;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withValues(alpha:0.9),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                color: theme.colorScheme.primary.withValues(alpha:0.1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.music_note,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Choose Sound',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // No Sound option
                    _buildSoundTile(
                      title: 'No Sound',
                      subtitle: 'Silent mode',
                      icon: Icons.volume_off,
                      value: null,
                      isSelected: _selectedSound == null,
                    ),

                    const SizedBox(height: 8),

                    // Built-in sounds
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _builtInSounds.length,
                        itemBuilder: (context, index) {
                          String soundPath = _builtInSounds.keys.elementAt(index);
                          String displayName = _builtInSounds[soundPath]!;

                          return _buildSoundTile(
                            title: displayName,
                            subtitle: 'Built-in sound',
                            icon: _getSoundIcon(soundPath),
                            value: soundPath,
                            isSelected: _selectedSound == soundPath,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Custom sound option
                    Card(
                      elevation: 2,
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
                                  color: theme.colorScheme.secondary.withValues(alpha:0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.folder_open,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Choose Custom Sound',
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

                    // Show custom sound if selected
                    if (_selectedSound != null && !_builtInSounds.containsKey(_selectedSound))
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _buildSoundTile(
                          title: _getDisplayName(_selectedSound),
                          subtitle: 'Custom sound',
                          icon: Icons.audiotrack,
                          value: _selectedSound!,
                          isSelected: true,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor.withValues(alpha:0.3),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      widget.onSoundSelected(_selectedSound);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            ),
          ],
        ),
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
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        )
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          setState(() {
            _selectedSound = value;
          });
          await _playSound(value);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withValues(alpha:0.1)
                      : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                    const SizedBox(height: 2),
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
                  color: Theme.of(context).colorScheme.primary,
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
    return Icons.music_note;
  }
}

// Example usage in your main widget
class SoundPickerExample extends StatefulWidget {
  const SoundPickerExample({super.key});

  @override
  State<SoundPickerExample> createState() => _SoundPickerExampleState();
}

class _SoundPickerExampleState extends State<SoundPickerExample> {
  String? _selectedSound;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _showSoundPicker() {
    showDialog(
      context: context,
      builder: (context) => SoundPickerDialog(
        selectedSound: _selectedSound,
        audioPlayer: _audioPlayer,
        onSoundSelected: (sound) {
          setState(() {
            _selectedSound = sound;
          });
        },
      ),
    );
  }

  String _getSoundDisplayName(String? soundPath) {
    if (soundPath == null) return 'No Sound';

    final Map<String, String> soundNames = {
      'assets/sounds/brown_noise.mp3': 'Brown Noise',
      'assets/sounds/clock_ticking.mp3': 'Clock Ticking',
      'assets/sounds/fire.mp3': 'Crackling Fire',
      'assets/sounds/forest_1.mp3': 'Forest Ambience',
      'assets/sounds/forest_2.mp3': 'Deep Forest',
      'assets/sounds/mountain_winds.mp3': 'Mountain Winds',
      'assets/sounds/rain.mp3': 'Rain Sounds',
      'assets/sounds/silent_room.mp3': 'Silent Room',
      'assets/sounds/waterfall.mp3': 'Waterfall',
    };

    if (soundNames.containsKey(soundPath)) {
      return soundNames[soundPath]!;
    }

    // For custom sounds, show just the filename
    return soundPath.split('/').last.split('.').first;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sound Picker Demo'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(alpha:0.1),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.music_note,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Current Sound:',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha:0.8),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  _getSoundDisplayName(_selectedSound),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
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
    );
  }
}
