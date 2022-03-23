import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jukebox/screens/background_audio/background_audio_screen_controller.dart';
import 'package:flutter_jukebox/widgets/app_scaffold.dart';
import 'package:provider/provider.dart';

class BackgroundAudioScreen extends StatelessWidget {
  const BackgroundAudioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BackgroundAudioState()..init(),
      child: const _BackgroundPlayScreen(),
    );
  }
}

class _BackgroundPlayScreen extends StatelessWidget {
  const _BackgroundPlayScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: const Text('Background Audio Sample'),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.orange[600]!,
              Colors.orange[400]!,
              Colors.orange[200]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Spacer(),
              Selector(
                selector: (BuildContext ctx, BackgroundAudioState controller) =>
                    controller.progressBarState,
                builder: (BuildContext ctx, ProgressBarState state, _) =>
                    ProgressBar(
                  progress: state.current,
                  buffered: state.buffered,
                  total: state.total,
                  onSeek: (Duration position) =>
                      context.read<BackgroundAudioState>().seek(position),
                ),
              ),
              Selector(
                selector: (BuildContext ctx, BackgroundAudioState controller) =>
                    controller.audioState,
                builder: (BuildContext ctx, AudioState state, _) {
                  switch (state) {
                    case AudioState.loading:
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 32,
                          width: 32,
                          child: CircularProgressIndicator(),
                        ),
                      );
                    case AudioState.ready:
                    case AudioState.paused:
                      return IconButton(
                        onPressed: () =>
                            context.read<BackgroundAudioState>().play(),
                        icon: const Icon(Icons.play_arrow),
                        iconSize: 32.0,
                      );
                    case AudioState.playing:
                      return IconButton(
                        onPressed: () =>
                            context.read<BackgroundAudioState>().pause(),
                        icon: const Icon(Icons.pause),
                        iconSize: 32.0,
                      );
                    default:
                      return const SizedBox(height: 32, width: 32);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}