import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:minimaltodo/focustimer/sound/sound_controller.dart';

class MyAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player;
  final SoundController _soundController;

  MyAudioHandler(this._player, this._soundController) {
    // Listen to player state changes and update playback state
    _player.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
        playbackState.add(playbackState.value.copyWith(
          controls: [MediaControl.stop],
          systemActions: const {MediaAction.stop},
          processingState: AudioProcessingState.loading,
        ));
      } else if (!isPlaying) {
        playbackState.add(playbackState.value.copyWith(
          controls: [MediaControl.play, MediaControl.stop],
          systemActions: const {MediaAction.play, MediaAction.stop},
          processingState: AudioProcessingState.ready,
          playing: false,
        ));
      } else {
        playbackState.add(playbackState.value.copyWith(
          controls: [MediaControl.pause, MediaControl.stop],
          systemActions: const {MediaAction.pause, MediaAction.stop},
          processingState: AudioProcessingState.ready,
          playing: true,
        ));
      }
    });

    // Set initial playback state
    playbackState.add(PlaybackState(
      controls: [MediaControl.play, MediaControl.stop],
      systemActions: const {MediaAction.play, MediaAction.stop},
      processingState: AudioProcessingState.idle,
    ));
  }

  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await _soundController.stopAudio();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  // Handle media button events (like headset buttons)
  @override
  Future<void> click([MediaButton button = MediaButton.media]) async {
    switch (button) {
      case MediaButton.media:
        if (_player.playing) {
          await pause();
        } else {
          await play();
        }
        break;
      case MediaButton.next:
      // Could implement next sound functionality here
        break;
      case MediaButton.previous:
      // Could implement previous sound functionality here
        break;
    }
  }

  // Update the current media item
  Future<void> updateMediaItem(MediaItem mediaItem) async {
    this.mediaItem.add(mediaItem);
  }
}