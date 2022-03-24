import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jukebox/screens/background_audio/audio_handler.dart';
import 'package:flutter_jukebox/screens/services/service_locator.dart';
import 'package:rxdart/rxdart.dart';

class BackgroundAudioScreenState extends ChangeNotifier {
  ProgressBarState progressBarState = ProgressBarState(
    current: Duration.zero,
    buffered: Duration.zero,
    total: Duration.zero,
  );
  AudioState audioState = AudioState.paused;
  late StreamSubscription _playbackSubscription;
  late StreamSubscription _progressBarSubscription;

  final AudioServiceHandler _handler = getIt<AudioServiceHandler>();

  // for test
  static final _item = MediaItem(
    id: 'https://firebasestorage.googleapis.com/v0/b/flutter-toybox.appspot.com/o/audios%2Fcreative_commons_piano.mp3?alt=media',
    album: "THE CREATIVE COMMONS",
    title: "Beautiful Piano",
    artist: "Creative commons of Soundclound",
    artUri: Uri.parse(
        'https://firebasestorage.googleapis.com/v0/b/flutter-toybox.appspot.com/o/audios%2Fartwork%2Fcreative_commons_piano_artwork.png?alt=media'),
  );

  /* --- INITIALIZE --- */
  void init() {
    _handler.initPlayer(_item);
    _listenToPlaybackState();
    _listenForProgressBarState();
  }

  /* --- SUBSCRIBE --- */

  void _listenToPlaybackState() {
    _playbackSubscription =
        _handler.playbackState.listen((PlaybackState state) {
      debugPrint('current state:${state.processingState}');
      debugPrint('playing:${state.playing}');

      if (isLoadingState(state)) {
        setAudioState(AudioState.loading);
      } else if (isAudioReady(state)) {
        setAudioState(AudioState.ready);
      } else if (isAudioPlaying(state)) {
        setAudioState(AudioState.playing);
      } else if (isAudioPaused(state)) {
        setAudioState(AudioState.paused);
      } else if (hasCompleted(state)) {
        setAudioState(AudioState.paused);
      }
    });
  }

  void _listenForProgressBarState() {
    _progressBarSubscription = CombineLatestStream.combine3(
      AudioService.position,
      _handler.playbackState,
      _handler.mediaItem,
      (Duration current, PlaybackState state, MediaItem? mediaItem) =>
          ProgressBarState(
        current: current,
        buffered: state.bufferedPosition,
        total: mediaItem?.duration ?? Duration.zero,
      ),
    ).listen((ProgressBarState state) => setProgressBarState(state));
  }

  /* --- UTILITY METHODS --- */
  bool isLoadingState(PlaybackState state) {
    return state.processingState == AudioProcessingState.loading ||
        state.processingState == AudioProcessingState.buffering;
  }

  bool isAudioReady(PlaybackState state) {
    return state.processingState == AudioProcessingState.ready &&
        !state.playing;
  }

  bool isAudioPlaying(PlaybackState state) {
    return state.playing && !hasCompleted(state);
  }

  bool isAudioPaused(PlaybackState state) {
    return !state.playing && !isLoadingState(state);
  }

  bool hasCompleted(PlaybackState state) {
    return state.processingState == AudioProcessingState.completed;
  }

  @override
  void dispose() {
    _handler.stop();
    _playbackSubscription.cancel();
    _progressBarSubscription.cancel();
    super.dispose();
  }

  /* --- STATE CONTROL --- */

  void setAudioState(AudioState state) {
    audioState = state;
    notifyListeners();
  }

  void setProgressBarState(ProgressBarState state) {
    progressBarState = state;
    notifyListeners();
  }

  /* --- PLAYER CONTROL  --- */
  void play() => _handler.play();

  void pause() => _handler.pause();

  void seek(Duration position) => _handler.seek(position);

  void stop() => _handler.stop();
}

class ProgressBarState {
  ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });

  final Duration current;
  final Duration buffered;
  final Duration total;
}

enum AudioState {
  ready,
  paused,
  playing,
  loading,
}
