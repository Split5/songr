import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import '../../models/models.dart';
import 'v2_playback_controller.dart';

typedef ArtworkUriResolver = Uri? Function(Song song);

/// iOS lock-screen, Control Center, headset and basic CarPlay Now Playing
/// bridge. It mirrors the one V2 playback owner and never mutates a second
/// queue of its own.
class V2AudioHandler extends BaseAudioHandler {
  V2AudioHandler({required this.controller, this.artworkUriFor}) {
    controller.addListener(_sync);
    _sync();
  }

  final V2PlaybackController controller;
  final ArtworkUriResolver? artworkUriFor;
  String? _mediaSongId;

  void _sync() {
    final song = controller.currentSong;
    if (song != null && song.id != _mediaSongId) {
      _mediaSongId = song.id;
      mediaItem.add(
        MediaItem(
          id: song.id,
          title: song.title,
          artist: song.artist,
          album: song.album,
          duration: Duration(seconds: song.duration),
          artUri: artworkUriFor?.call(song),
        ),
      );
    } else if (controller.currentStation case final station?) {
      final stationId = 'radio:${station.id}';
      if (_mediaSongId != stationId) {
        _mediaSongId = stationId;
        mediaItem.add(
          MediaItem(
            id: stationId,
            title: station.name,
            artist: 'Radio',
            isLive: true,
          ),
        );
      }
    }
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          controller.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {MediaAction.seek},
        processingState: switch (controller.processingState) {
          ProcessingState.idle => AudioProcessingState.idle,
          ProcessingState.loading => AudioProcessingState.loading,
          ProcessingState.buffering => AudioProcessingState.buffering,
          ProcessingState.ready => AudioProcessingState.ready,
          ProcessingState.completed => AudioProcessingState.completed,
        },
        playing: controller.playing,
        updatePosition: controller.position,
        repeatMode: switch (controller.repeatMode) {
          V2RepeatMode.off => AudioServiceRepeatMode.none,
          V2RepeatMode.one => AudioServiceRepeatMode.one,
          V2RepeatMode.all => AudioServiceRepeatMode.all,
        },
      ),
    );
  }

  @override
  Future<void> play() => controller.coordinator.play();

  @override
  Future<void> pause() => controller.coordinator.pause();

  @override
  Future<void> skipToNext() => controller.next();

  @override
  Future<void> skipToPrevious() => controller.previous();

  @override
  Future<void> seek(Duration position) => controller.seek(position);

  @override
  Future<void> stop() => controller.coordinator.pause();

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) =>
      controller.setRepeatMode(switch (repeatMode) {
        AudioServiceRepeatMode.one => V2RepeatMode.one,
        AudioServiceRepeatMode.all ||
        AudioServiceRepeatMode.group => V2RepeatMode.all,
        _ => V2RepeatMode.off,
      });

  void detach() => controller.removeListener(_sync);
}
