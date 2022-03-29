import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_jukebox/screens/river_audio/river_audio_screen_state.dart';
import 'package:flutter_jukebox/widgets/app_scaffold.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RiverAudioScreen extends StatelessWidget {
  const RiverAudioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(
      child: _RiverAudioScreen(),
    );
  }
}

class _RiverAudioScreen extends HookConsumerWidget {
  const _RiverAudioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      ref.read(riverAudioSceenState.notifier).init();
    }, []);
    debugPrint('widget rebuild');

    return AppScaffold(
      title: const Text('Riverpod Audio Sample'),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.indigo[600]!,
              Colors.indigo[400]!,
              Colors.indigo[200]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Spacer(),
              Consumer(
                builder: (BuildContext ctx, WidgetRef ref, _) {
                  final ProgressBarState state =
                      ref.watch(riverAudioSceenState).progressBarState;
                  debugPrint('progress bar rebuild');
                  return ProgressBar(
                    progress: state.current,
                    buffered: state.buffered,
                    total: state.total,
                    onSeek: (Duration position) =>
                        ref.read(riverAudioSceenState.notifier).seek(position),
                  );
                },
              ),
              Consumer(
                builder: (BuildContext ctx, WidgetRef ref, _) {
                  final AudioState state =
                      ref.watch(riverAudioSceenState).audioState;
                  final unListenState = ref.read(riverAudioSceenState.notifier);
                  debugPrint('button rebuild');
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
                        onPressed: () => unListenState.play(),
                        icon: const Icon(Icons.play_arrow),
                        iconSize: 32.0,
                      );
                    case AudioState.playing:
                      return IconButton(
                        onPressed: () => unListenState.pause(),
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
