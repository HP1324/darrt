import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:minimaltodo/app/services/mini_box.dart';

class SoundController extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentSound;
  List<Map<String, String>> _customSounds = [];
  bool _isPlaying = false;
  bool _isStopped = false;
  bool _isPaused = false;
  bool _isDisposed = false;
  // ValueNotifier for dialog-specific state
  final ValueNotifier<String?> _selectedSoundInDialog = ValueNotifier<String?>(null);

  // Getters
  String? get currentSound => _currentSound;
  List<Map<String, String>> get customSounds => _customSounds;
  AudioPlayer get audioPlayer => _audioPlayer!;
  ValueNotifier<String?> get selectedSoundInDialog => _selectedSoundInDialog;
  bool get isPlaying => _isPlaying;
  bool get isStopped => _isStopped;
  bool get isPaused => _isPaused;
  bool get isDisposed => _isDisposed;

  // Initialize the service
  void initialize() async {
    _audioPlayer.setReleaseMode(ReleaseMode.loop);

    // Setting audio config like this is necessary to play simultaneous audio files at the same time,
    // before setting this AudioContextConfig, one audioplayer instance would stop another audioplayer instance
    final audioContext = AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build();
    await AudioPlayer.global.setAudioContext(audioContext);

    // Listen to player state changes to keep UI in sync
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      _isPlaying = state == PlayerState.playing;
      _isStopped = state == PlayerState.stopped;
      _isPaused = state == PlayerState.paused;
      _isDisposed = state == PlayerState.disposed;
      notifyListeners();
    });

    // Listen to player completion to reset state
    _audioPlayer.onPlayerComplete.listen((event) {
      _isPlaying = false;
      notifyListeners();
    });

    _loadCustomSounds();
  }

  // Load custom sounds from SharedPreferences
  void _loadCustomSounds() {
    final soundsJson = MiniBox().read('custom_sounds') ?? '[]';
    final List<dynamic> soundsList = jsonDecode(soundsJson);
    _customSounds = soundsList.map((sound) => Map<String, String>.from(sound)).toList();
    notifyListeners();
  }

  // Save custom sounds to SharedPreferences
  void _saveCustomSounds() {
    final soundsJson = jsonEncode(_customSounds);
    MiniBox().write('custom_sounds', soundsJson);
  }

  // Add custom sound to the list
  void addCustomSound(String path, String name) {
    // Check if sound already exists
    bool exists = _customSounds.any((sound) => sound['path'] == path);
    if (!exists) {
      _customSounds.add({'path': path, 'name': name});
      _saveCustomSounds();
      notifyListeners();
    }
  }

  // Play sound - Fixed version
  Future<void> playSound(String? soundPath) async {
    try {
      // Always stop current audio first
      await _audioPlayer.stop();

      if (soundPath == null) {
        // If null is passed, we want to stop and clear current sound
        _currentSound = null;
        _isPlaying = false;
        notifyListeners();
        return;
      }

      // Set current sound and play
      _currentSound = soundPath;

      if (soundPath.startsWith('assets/')) {
        await _audioPlayer.play(AssetSource(soundPath.replaceFirst('assets/', '')));
      } else {
        await _audioPlayer.play(DeviceFileSource(soundPath));
      }

      // Note: _isPlaying will be updated by the state listener
      notifyListeners();
    } catch (e) {
      print('Error playing sound: $e');
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> playSoundOnly(String assetPath) async {
    AudioPlayer player = AudioPlayer();
    await player.setReleaseMode(ReleaseMode.stop);
    assert(assetPath.startsWith('assets/'), 'Only asset paths are supported');
    final trimmed = assetPath.replaceFirst('assets/', '');
    await player.play(AssetSource(trimmed),mode: PlayerMode.lowLatency);
  }

  // Toggle sound - New method for better UX
  Future<void> toggleSound(String? soundPath) async {
    if (_currentSound == soundPath && _isPlaying) {
      // If the same sound is playing, stop it
      await stopAudio();
    } else {
      // Play the new sound or restart current sound
      await playSound(soundPath);
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

  // Stop audio - Enhanced version
  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      _currentSound = null;
      _isPlaying = false;
      notifyListeners();
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  // Check if a specific sound is currently playing
  bool isSoundPlaying(String? soundPath) {
    return _currentSound == soundPath && _isPlaying;
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
      'assets/sounds/birds_near_river.mp3': 'Birds + River',
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
