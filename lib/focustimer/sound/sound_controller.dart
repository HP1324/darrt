import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:darrt/app/services/mini_box.dart';
import 'package:darrt/focustimer/sound/my_audio_handler.dart';
import 'package:darrt/helpers/consts.dart';
import 'package:darrt/helpers/mini_logger.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class SoundController extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioHandler? _audioHandler;

  // Audio sources list instead of ConcatenatingAudioSource
  List<AudioSource> _audioSources = [];

  List<Map<String, String>> _customSounds = [];
  bool _isPlaying = false;
  bool _isStopped = false;
  bool _isPaused = false;
  bool _isDisposed = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  LoopMode _loopMode = MiniBox().read(mSoundLoopMode) == null ? LoopMode.one : LoopMode.all;
  int? _currentIndex;

  // ValueNotifier for dialog-specific state
  final ValueNotifier<String?> _selectedSoundInDialog = ValueNotifier<String?>(null);

  // Built-in sounds mapping (single source of truth)
  static const Map<String, String> _builtInSounds = {
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

  // Getters
  String? get currentSound => _currentIndex != null ? _getSoundPathByIndex(_currentIndex!) : null;
  List<Map<String, String>> get customSounds => _customSounds;
  AudioPlayer get audioPlayer => _audioPlayer;
  ValueNotifier<String?> get selectedSoundInDialog => _selectedSoundInDialog;
  bool get isPlaying => _isPlaying;
  bool get isStopped => _isStopped;
  bool get isPaused => _isPaused;
  bool get isDisposed => _isDisposed;
  Duration get duration => _duration;
  Duration get position => _position;
  LoopMode get loopMode => _loopMode;
  int? get currentIndex => _currentIndex;

  // Initialize the service
  void initialize() async {
    // Initialize audio service
    _audioHandler = await AudioService.init(
      builder: () => MyAudioHandler(_audioPlayer, this),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.stellarmotion.darrt.audio',
        androidNotificationChannelName: 'Audio Service',
      ),
    );

    // Load custom sounds first
    await _loadCustomSounds();

    // Set up the audio sources with both built-in and custom sounds
    await _setupAudioSources();

    // Set initial loop mode
    await _audioPlayer.setLoopMode(_loopMode);

    // Listen to player state changes
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

    // Listen to current index changes
    _audioPlayer.currentIndexStream.listen((index) {
      _currentIndex = index;
      _updateMediaItem();
      notifyListeners();
    });

    // Listen to position changes
    _audioPlayer.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    // Listen to duration changes
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _duration = duration;
        notifyListeners();
      }
    });

    // Listen to loop mode changes
    _audioPlayer.loopModeStream.listen((mode) {
      _loopMode = mode;
      notifyListeners();
    });
  }

  // Setup audio sources with built-in and custom sounds
  Future<void> _setupAudioSources() async {
    try {
      // Create audio sources list with built-in sounds
      _audioSources = [
        AudioSource.asset('assets/sounds/brown_noise.mp3'),
        AudioSource.asset('assets/sounds/clock_ticking.mp3'),
        AudioSource.asset('assets/sounds/fire.mp3'),
        AudioSource.asset('assets/sounds/forest_1.mp3'),
        AudioSource.asset('assets/sounds/forest_2.mp3'),
        AudioSource.asset('assets/sounds/mountain_winds.mp3'),
        AudioSource.asset('assets/sounds/rain.mp3'),
        AudioSource.asset('assets/sounds/silent_room.mp3'),
        AudioSource.asset('assets/sounds/waterfall.mp3'),
        AudioSource.asset('assets/sounds/birds_near_river.mp3'),
      ];

      // Add custom sounds to audio sources
      for (final customSound in _customSounds) {
        _audioSources.add(AudioSource.file(customSound['path']!));
      }

      // Set the audio sources to the player
      await _audioPlayer.setAudioSources(
        _audioSources,
        initialIndex: 1,
      );
    } catch (e) {
      MiniLogger.dp('Error setting up audio sources: $e');
    }
  }

  // Load custom sounds from SharedPreferences
  Future<void> _loadCustomSounds() async {
    try {
      final soundsJson = MiniBox().read('custom_sounds') ?? '[]';
      final List<dynamic> soundsList = jsonDecode(soundsJson);
      _customSounds = soundsList.map((sound) => Map<String, String>.from(sound)).toList();
      notifyListeners();
    } catch (e) {
      MiniLogger.dp('Error loading custom sounds: $e');
    }
  }

  // Save custom sounds to SharedPreferences
  void _saveCustomSounds() {
    try {
      final soundsJson = jsonEncode(_customSounds);
      MiniBox().write('custom_sounds', soundsJson);
    } catch (e) {
      MiniLogger.dp('Error saving custom sounds: $e');
    }
  }

  // Add custom sound to the audio sources
  Future<void> addCustomSound(String path, String name) async {
    try {
      // Check if sound already exists
      bool exists = _customSounds.any((sound) => sound['path'] == path);
      if (!exists) {
        _customSounds.add({'path': path, 'name': name});
        _saveCustomSounds();

        // Add to audio sources and refresh
        _audioSources.add(AudioSource.file(path));
        // await _audioPlayer.setAudioSources(_audioSources);
        //Use [addAudioSources] method instead of [setAudioSources] so that the player does not start playing from start when a new custom sound is selected.
        await _audioPlayer.addAudioSource(AudioSource.file(path));
        notifyListeners();
      }
    } catch (e) {
      MiniLogger.dp('Error adding custom sound: $e');
    }
  }

  // Play audio by sound path
  Future<void> playAudio(String? soundPath) async {
    // if (!isPlaying) {
      try {
        if (soundPath == null) {
          if(isPlaying) {
            await stopAudio();
          }
          return;
        }

        final index = _getIndexBySoundPath(soundPath);
        if (index != null) {
          await _audioPlayer.seek(Duration.zero, index: index);
          await _audioPlayer.play();
          await _audioHandler?.play();
        }
      } catch (e) {
        MiniLogger.dp('Error playing sound: $e');
        _isPlaying = false;
        notifyListeners();
      }
    // }
  }
  // Play sound by index
  Future<void> playByIndex(int index) async {
    try {
      if (index >= 0 && index < _audioSources.length) {
        await _audioPlayer.seek(Duration.zero, index: index);
        await _audioPlayer.play();
        await _audioHandler?.play();
      }
    } catch (e) {
      MiniLogger.dp('Error playing sound by index: $e');
    }
  }

  // Play sound only (one-time play without affecting main playlist)
  Future<void> playSoundOnly(String assetPath) async {
    AudioPlayer player = AudioPlayer();
    try {
      assert(assetPath.startsWith('assets/'), 'Only asset paths are supported');

      final audioSource = AudioSource.asset(assetPath);
      await player.setAudioSource(audioSource);
      await player.play();

      // Dispose player
      player.dispose();
    } catch (e) {
      MiniLogger.dp('Error playing sound only: $e');
      player.dispose();
    }
  }

  // Toggle sound
  Future<void> toggleSound(String? soundPath) async {
    if (currentSound == soundPath && _isPlaying) {
      await stopAudio();
    } else {
      await playAudio(soundPath);
    }
  }

  // Pause audio
  Future<void> pauseAudio() async {
    if (isPlaying) {
      await _audioPlayer.pause();
      await _audioHandler?.pause();
    }
  }

  // Resume audio
  Future<void> resumeAudio() async {
    if (isPaused) {
      await _audioPlayer.play();
      await _audioHandler?.play();
    }
  }
  // Stop audio
  Future<void> stopAudio() async {
    if (isPlaying) {
      try {
        await _audioPlayer.stop();
        await _audioHandler?.stop();
        _currentIndex = null;
        _isPlaying = false;
        notifyListeners();
      } catch (e) {
        MiniLogger.dp('Error stopping audio: $e');
      }
    }
  }

  // Seek to next sound (built-in functionality)
  Future<void> seekToNext() async {
    try {
      await _audioPlayer.seekToNext();
    } catch (e) {
      MiniLogger.dp('Error seeking to next: $e');
    }
  }

  // Seek to previous sound (built-in functionality)
  Future<void> seekToPrevious() async {
    try {
      await _audioPlayer.seekToPrevious();
    } catch (e) {
      MiniLogger.dp('Error seeking to previous: $e');
    }
  }

  // Set loop mode
  Future<void> setLoopMode(LoopMode mode) async {
    try {
      await _audioPlayer.setLoopMode(mode);
    } catch (e) {
      MiniLogger.dp('Error setting loop mode: $e');
    }
  }

  // Set shuffle mode
  Future<void> setShuffleModeEnabled(bool enabled) async {
    try {
      await _audioPlayer.setShuffleModeEnabled(enabled);
    } catch (e) {
      MiniLogger.dp('Error setting shuffle mode: $e');
    }
  }

  // Seek to position
  Future<void> seek(Duration seekDuration) async {
    try {
      await _audioPlayer.seek(seekDuration);
    } catch (e) {
      MiniLogger.dp('Error seeking: $e');
    }
  }

  // Set position (for UI updates)
  void setPosition(double value) {
    _position = Duration(milliseconds: value.toInt());
    notifyListeners();
  }

  // Check if a specific sound is currently playing
  bool isSoundPlaying(String? soundPath) {
    return currentSound == soundPath && _isPlaying;
  }

  // Set selected sound in dialog
  void setSelectedSoundInDialog(String? sound) {
    _selectedSoundInDialog.value = sound;
  }

  // Initialize dialog with current sound
  void initializeDialog() {
    _selectedSoundInDialog.value = currentSound;
  }

  // Get display name for a sound
  String getDisplayName(String? soundPath) {
    if (soundPath == null) return 'No Sound';

    // Check built-in sounds
    if (_builtInSounds.containsKey(soundPath)) {
      return _builtInSounds[soundPath]!;
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

  // Get all sounds (single source of truth)
  List<Map<String, String>> getAllSounds() {
    final List<Map<String, String>> allSounds = [];

    // Add built-in sounds
    _builtInSounds.forEach((path, name) {
      allSounds.add({'path': path, 'name': name});
    });

    // Add custom sounds
    allSounds.addAll(_customSounds);

    return allSounds;
  }

  // Helper methods
  int? _getIndexBySoundPath(String soundPath) {
    final allSounds = getAllSounds();
    for (int i = 0; i < allSounds.length; i++) {
      if (allSounds[i]['path'] == soundPath) {
        return i;
      }
    }
    return null;
  }

  String? _getSoundPathByIndex(int index) {
    final allSounds = getAllSounds();
    if (index >= 0 && index < allSounds.length) {
      return allSounds[index]['path'];
    }
    return null;
  }

  void _updateMediaItem() {
    if (_currentIndex != null && _audioHandler != null) {
      final soundPath = _getSoundPathByIndex(_currentIndex!);
      if (soundPath != null) {
        final displayName = getDisplayName(soundPath);
        _audioHandler?.updateMediaItem(
          MediaItem(
            id: soundPath,
            title: displayName,
            artist: 'Darrt',
            duration: _duration,
          ),
        );
      }
    }
  }

  // Legacy methods for backward compatibility
  void playNextSound() => seekToNext();
  void playPreviousSound() => seekToPrevious();

  Future<void> stopAudioService()async{
    await _audioHandler?.stop();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _selectedSoundInDialog.dispose();
    super.dispose();
  }
}