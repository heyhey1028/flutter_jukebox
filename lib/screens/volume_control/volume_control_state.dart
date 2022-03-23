import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jukebox/screens/background_audio/audio_handler.dart';
import 'package:flutter_jukebox/screens/services/service_locator.dart';
import 'package:rxdart/rxdart.dart';

class VolumeControlState extends ChangeNotifier {
  ProgressBarState progressBarState = ProgressBarState(
    current: Duration.zero,
    buffered: Duration.zero,
    total: Duration.zero,
  );
  AudioState audioState = AudioState.paused;
  late AnimationController volumeControl;

  final AudioServiceHandler _handler = getIt<AudioServiceHandler>();
  late StreamSubscription _playbackSubscription;
  late StreamSubscription _progressBarSubscription;

  // for test
  static final _item = MediaItem(
    id: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    album: "Science Friday",
    title: "A Salute To Head-Scratching Science",
    artist: "Science Friday and WNYC Studios",
    duration: const Duration(milliseconds: 5739820),
    artUri: Uri.parse(
        'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg'),
  );

  /* --- INITIALIZE --- */
  Future<void> init(TickerProvider provider) async {
    _handler.initPlayer(_item);
    _listenToPlaybackState();
    _listenForProgressBarState();
    await _listenToVolumeControl(provider);
  }

  /* --- SUBSCRIBE --- */

  void _listenToPlaybackState() {
    _playbackSubscription =
        _handler.playbackState.listen((PlaybackState state) {
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
      // _handler.mediaItem
      // (Duration current, PlaybackState state, MediaItem mediaItem) =>
      _handler.player.durationStream,
      (Duration current, PlaybackState state, Duration? total) =>
          ProgressBarState(
        current: current,
        buffered: state.bufferedPosition,
        // total: mediaItem?.duraion ?? Duration.zero
        total: total ?? Duration.zero,
      ),
    ).listen((ProgressBarState state) => setProgressBarState(state));
  }

  Future<void> _listenToVolumeControl(TickerProvider provider) async {
    final Duration? duration = await _handler.player.durationStream.first;
    volumeControl = AnimationController(vsync: provider, duration: duration)
      ..addListener(() => _handler.setVolume(1 - volumeControl.value));
    notifyListeners();
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
    volumeControl.dispose();
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
  void play() {
    _handler.play();
    volumeControl.forward();
  }

  void pause() {
    _handler.pause();
    volumeControl.stop();
  }

  void seek(Duration position) {
    _handler.seek(position);
    final double current =
        position.inMicroseconds / progressBarState.total.inMicroseconds;
    volumeControl.value = current;
    notifyListeners();
  }

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
