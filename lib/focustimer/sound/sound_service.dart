import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:minimaltodo/app/services/mini_box.dart';
import 'package:minimaltodo/app/services/object_box.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  late AudioPlayer _audioPlayer;
  String? _currentSound;
  List<Map<String, String>> _customSounds = [];

  // Getters
  String? get currentSound => _currentSound;
  List<Map<String, String>> get customSounds => _customSounds;
  AudioPlayer get audioPlayer => _audioPlayer;

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
    }
  }

  // Play sound
  Future<void> playSound(String? soundPath) async {
    try {
      await _audioPlayer.stop();
      _currentSound = soundPath;

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
  void dispose() {
    _audioPlayer.dispose();
  }
}