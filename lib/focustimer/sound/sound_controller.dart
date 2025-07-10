import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:minimaltodo/app/services/mini_box.dart';

class SoundController extends ChangeNotifier {
  late AudioPlayer _audioPlayer;
  String? _currentSound;
  List<Map<String, String>> _customSounds = [];

  // ValueNotifier for dialog-specific state
  final ValueNotifier<String?> _selectedSoundInDialog = ValueNotifier<String?>(null);

  // Getters
  String? get currentSound => _currentSound;
  List<Map<String, String>> get customSounds => _customSounds;
  AudioPlayer get audioPlayer => _audioPlayer;
  ValueNotifier<String?> get selectedSoundInDialog => _selectedSoundInDialog;

  // Initialize the service
  Future<void> initialize() async {
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _loadCustomSounds();
  }

  // Load custom sounds from SharedPreferences
  Future<void> _loadCustomSounds() async {
    final soundsJson = MiniBox().read('custom_sounds') ?? '[]';
    final List<dynamic> soundsList = jsonDecode(soundsJson);
    _customSounds = soundsList.map((sound) => Map<String, String>.from(sound)).toList();
    notifyListeners();
  }

  // Save custom sounds to SharedPreferences
  Future<void> _saveCustomSounds() async {
    final soundsJson = jsonEncode(_customSounds);
    MiniBox().write('custom_sounds', soundsJson);
  }

  // Add custom sound to the list
  Future<void> addCustomSound(String path, String name) async {
    // Check if sound already exists
    bool exists = _customSounds.any((sound) => sound['path'] == path);
    if (!exists) {
      _customSounds.add({'path': path, 'name': name});
      await _saveCustomSounds();
      notifyListeners();
    }
  }

  // Play sound
  Future<void> playSound(String? soundPath) async {
    try {
      await _audioPlayer.stop();
      _currentSound = soundPath;
      notifyListeners();

      if (soundPath == null) {
        return;
      }

      if (soundPath.startsWith('assets/')) {
        await _audioPlayer.play(AssetSource(soundPath.replaceFirst('assets/', '')));
      } else {
        await _audioPlayer.play(DeviceFileSource(soundPath));
      }
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  // Pause audio
  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
  }

  // Resume audio
  Future<void> resumeAudio() async {
    await _audioPlayer.resume();
  }

  // Stop audio
  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    _currentSound = null;
    notifyListeners();
  }

  // Set selected sound in dialog
  void setSelectedSoundInDialog(String? sound) {
    _selectedSoundInDialog.value = sound;
  }

  // Initialize dialog with current sound
  void initializeDialog() {
    _selectedSoundInDialog.value = _currentSound;
  }

  // Get display name for a sound
  String getDisplayName(String? soundPath) {
    if (soundPath == null) return 'No Sound';

    final Map<String, String> builtInSounds = {
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

    if (builtInSounds.containsKey(soundPath)) {
      return builtInSounds[soundPath]!;
    }

    // Check custom sounds
    final customSound = _customSounds.firstWhere(
          (sound) => sound['path'] == soundPath,
      orElse: () => {},
    );

    if (customSound.isNotEmpty) {
      return customSound['name']!;
    }

    // Fallback to filename
    return soundPath.split('/').last.split('.').first;
  }

  // Dispose resources
  @override
  void dispose() {
    _audioPlayer.dispose();
    _selectedSoundInDialog.dispose();
    super.dispose();
  }
}