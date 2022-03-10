import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:just_audio/just_audio.dart';

class JustAudioScreenState extends ChangeNotifier {
  late AudioPlayer _audioPlayer;
  ProgressBarState progressBarState = ProgressBarState(
    current: Duration.zero,
    buffered: Duration.zero,
    total: Duration.zero,
  );
  AudioState audioState = AudioState.paused;
  late StreamSubscription _playbackSubscription;
  late StreamSubscription _progressBarSubscription;

  static const _url =
      'https://firebasestorage.googleapis.com/v0/b/flutter-toybox.appspot.com/o/audios%2Fmusic_box.mp3?alt=media&token=cf88a17e-bbe9-46de-95a8-e855a23fbb3b';

  /* --- INITIALIZE --- */
  void init() {
    _audioPlayer = AudioPlayer()..setUrl(_url);
    _listenToPlaybackState();
    _listenForProgressBarState();
  }

  /* --- SUBSCRIBE --- */

  void _listenToPlaybackState() {
    _playbackSubscription =
        _audioPlayer.playerStateStream.listen((PlayerState state) {
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
      _audioPlayer.positionStream,
      _audioPlayer.bufferedPositionStream,
      _audioPlayer.durationStream,
      (Duration current, Duration buffer, Duration? total) => ProgressBarState(
        current: current,
        buffered: buffer,
        total: total ?? Duration.zero,
      ),
    ).listen((ProgressBarState state) => setProgressBarState(state));
  }

  /* --- UTILITY METHODS --- */
  bool isLoadingState(PlayerState state) {
    return state.processingState == ProcessingState.loading ||
        state.processingState == ProcessingState.buffering;
  }

  bool isAudioReady(PlayerState state) {
    return state.processingState == ProcessingState.ready && !state.playing;
  }

  bool isAudioPlaying(PlayerState state) {
    return state.playing && !hasCompleted(state);
  }

  bool isAudioPaused(PlayerState state) {
    return !state.playing && !isLoadingState(state);
  }

  bool hasCompleted(PlayerState state) {
    return state.processingState == ProcessingState.completed;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
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
  void play() => _audioPlayer.play();

  void pause() => _audioPlayer.pause();

  void seek(Duration position) => _audioPlayer.seek(position);

  void stop() => _audioPlayer.stop();
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
