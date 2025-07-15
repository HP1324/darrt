import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:minimaltodo/app/services/mini_box.dart';
import 'package:minimaltodo/focustimer/sound/my_audio_handler.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';

class SoundController extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioHandler? _audioHandler;
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
  AudioPlayer get audioPlayer => _audioPlayer;
  ValueNotifier<String?> get selectedSoundInDialog => _selectedSoundInDialog;
  bool get isPlaying => _isPlaying;
  bool get isStopped => _isStopped;
  bool get isPaused => _isPaused;
  bool get isDisposed => _isDisposed;

  // Initialize the service
  void initialize() async {
    // Initialize audio service
    _audioHandler = await AudioService.init(
      builder: () => MyAudioHandler(_audioPlayer, this),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.stellarmotion.darrt.audio',
        androidNotificationChannelName: 'Audio Service',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );

    // Set loop mode for continuous playback
    _audioPlayer.setLoopMode(LoopMode.one);

    // Listen to player state changes to keep UI in sync
    _audioPlayer.playerStateStream.listen((PlayerState state) {
      _isPlaying = state.playing;
      _isStopped = !state.playing && state.processingState == ProcessingState.idle;
      _isPaused = !state.playing && state.processingState != ProcessingState.idle;
      notifyListeners();
    });

    // Listen to processing state changes
    _audioPlayer.processingStateStream.listen((ProcessingState state) {
      _isDisposed = state == ProcessingState.idle;
      notifyListeners();
    });

    // Listen to player completion to reset state
    _audioPlayer.playerStateStream.listen((PlayerState state) {
      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
        notifyListeners();
      }
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

  Future<void> playAudio(String? soundPath) async {
    try {
      // Always stop current audio first
      await _audioPlayer.stop();

      if (soundPath == null) {
        // If null is passed, we want to stop and clear current sound
        _currentSound = null;
        _isPlaying = false;
        await _audioHandler?.stop();
        notifyListeners();
        return;
      }

      // Set current sound and play
      _currentSound = soundPath;

      AudioSource audioSource;
      if (soundPath.startsWith('assets/')) {
        audioSource = AudioSource.asset(soundPath);
      } else {
        audioSource = AudioSource.file(soundPath);
      }

      await _audioPlayer.setAudioSource(audioSource);

      // Update media item for audio service
      final displayName = getDisplayName(soundPath);
      await _audioHandler?.updateMediaItem(MediaItem(
        id: soundPath,
        title: displayName,
        artist: 'Minimal Todo',
        duration: const Duration(hours: 24), // Set a very long duration for ambient sounds
        artUri: Uri.parse('android.resource://com.minimaltodo/drawable/ic_notification'),
      ));

      await _audioPlayer.play();
      await _audioHandler?.play();

      // Note: _isPlaying will be updated by the state listener
      notifyListeners();
    } catch (e) {
      MiniLogger.dp('Error playing sound: $e');
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> playSoundOnly(String assetPath) async {
    AudioPlayer player = AudioPlayer();
    try {
      assert(assetPath.startsWith('assets/'), 'Only asset paths are supported');

      final audioSource = AudioSource.asset(assetPath);
      await player.setAudioSource(audioSource);
      await player.play();

      // Listen for completion to dispose the player
      player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          player.dispose();
        }
      });
    } catch (e) {
      MiniLogger.dp('Error playing sound only: $e');
      player.dispose();
    }
  }

  // Toggle sound - New method for better UX
  Future<void> toggleSound(String? soundPath) async {
    if (_currentSound == soundPath && _isPlaying) {
      // If the same sound is playing, stop it
      await stopAudio();
    } else {
      // Play the new sound or restart current sound
      await playAudio(soundPath);
    }
  }

  // Pause audio
  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
    await _audioHandler?.pause();
  }

  // Resume audio
  Future<void> resumeAudio() async {
    await _audioPlayer.play();
    await _audioHandler?.play();
  }

  // Stop audio - Enhanced version
  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      await _audioHandler?.stop();
      _currentSound = null;
      _isPlaying = false;
      notifyListeners();
    } catch (e) {
      MiniLogger.dp('Error stopping audio: $e');
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