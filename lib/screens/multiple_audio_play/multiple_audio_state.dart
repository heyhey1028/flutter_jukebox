import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jukebox/screens/background_audio/audio_handler.dart';
import 'package:flutter_jukebox/screens/services/service_locator.dart';
import 'package:rxdart/rxdart.dart';

class MultipleAudioState extends ChangeNotifier {
  ProgressBarState progressBarState = ProgressBarState(
    current: Duration.zero,
    buffered: Duration.zero,
    total: Duration.zero,
  );
  AudioState audioState = AudioState.paused;
  late AnimationController volumeControl;
  late StreamSubscription _playbackSubscription;
  late StreamSubscription _progressBarSubscription;
  late StreamSubscription _volumeSubscription;
  double volumeFactor = 1;

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

  static const _item1 = MediaItem(
    id: 'https://firebasestorage.googleapis.com/v0/b/flutter-toybox.appspot.com/o/audios%2Fsuzu_mushi.mp3?alt=media',
    album: "Science Friday",
    title: "A Salute To Head-Scratching Science",
    artist: "Science Friday and WNYC Studios",
  );

  static const _item2 = MediaItem(
    id: 'https://firebasestorage.googleapis.com/v0/b/flutter-toybox.appspot.com/o/audios%2Fwave.mp3?alt=media',
    album: "Science Friday",
    title: "A Salute To Head-Scratching Science",
    artist: "Science Friday and WNYC Studios",
  );

  /* --- INITIALIZE --- */
  Future<void> init(TickerProvider provider) async {
    _handler.initPlayer(_item);
    _listenToPlaybackState();
    _listenForProgressBarState();
    await _listenToVolumeControl(provider);
    _listenVolume();
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

  void _listenVolume() {
    _volumeSubscription = _handler.player.volumeStream.listen((double p0) {
      volumeFactor = p0;
      _handler.setVolume1(sliderValue1 * p0);
      _handler.setVolume2(sliderValue2 * p0);
    });
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
    _volumeSubscription.cancel();
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

  /* --- SUB AUDIO CONTROL --- */
  void setSubAudio1() {
    _handler.setAudioSource1(_item1);
  }

  void setSubAudio2() {
    _handler.setAudioSource2(_item2);
  }

  double sliderValue1 = 1;
  double sliderValue2 = 1;

  void setVolume1(double value) {
    sliderValue1 = value;
    _handler.setVolume1(value * volumeFactor);
    notifyListeners();
  }

  void setVolume2(double value) {
    sliderValue2 = value;
    _handler.setVolume2(value * volumeFactor);
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
