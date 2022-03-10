import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jukebox/screens/multiple_audio_play/multiple_audio_state.dart';
import 'package:flutter_jukebox/widgets/app_scaffold.dart';
import 'package:provider/provider.dart';

class MultipleAudioScreen extends StatelessWidget {
  const MultipleAudioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MultipleAudioState(),
      child: const _MultipleAudioScreen(),
    );
  }
}

class _MultipleAudioScreen extends StatefulWidget {
  const _MultipleAudioScreen({Key? key}) : super(key: key);

  @override
  State<_MultipleAudioScreen> createState() => _MultipleAudioScreenState();
}

class _MultipleAudioScreenState extends State<_MultipleAudioScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    context.read<MultipleAudioState>().init(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: const Text('Multiple Audio Sample'),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.purple[600]!,
              Colors.purple[400]!,
              Colors.purple[200]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 250),
              Selector(
                selector: (BuildContext ctx, MultipleAudioState controller) =>
                    controller.progressBarState,
                builder: (BuildContext ctx, ProgressBarState state, _) =>
                    ProgressBar(
                  progress: state.current,
                  buffered: state.buffered,
                  total: state.total,
                  onSeek: (Duration position) =>
                      context.read<MultipleAudioState>().seek(position),
                ),
              ),
              Row(
                children: <Widget>[
                  Selector(
                      selector:
                          (BuildContext ctx, MultipleAudioState controller) =>
                              controller.sliderValue1,
                      builder: (BuildContext ctx, double sliderValue, _) =>
                          Expanded(
                            child: Slider(
                                value: sliderValue,
                                onChanged: (double value) => context
                                    .read<MultipleAudioState>()
                                    .setVolume1(value)),
                          )),
                  IconButton(
                      onPressed: () =>
                          context.read<MultipleAudioState>().setSubAudio1(),
                      icon: const Icon(Icons.add_circle_outline)),
                ],
              ),
              Row(
                children: <Widget>[
                  Selector(
                      selector:
                          (BuildContext ctx, MultipleAudioState controller) =>
                              controller.sliderValue2,
                      builder: (BuildContext ctx, double sliderValue, _) =>
                          Expanded(
                            child: Slider(
                                value: sliderValue,
                                onChanged: (double value) => context
                                    .read<MultipleAudioState>()
                                    .setVolume2(value)),
                          )),
                  IconButton(
                      onPressed: () =>
                          context.read<MultipleAudioState>().setSubAudio2(),
                      icon: const Icon(Icons.add_circle_outline)),
                ],
              ),
              const Spacer(),
              Selector(
                selector: (BuildContext ctx, MultipleAudioState controller) =>
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
                            context.read<MultipleAudioState>().play(),
                        icon: const Icon(Icons.play_arrow),
                        iconSize: 32.0,
                      );
                    case AudioState.playing:
                      return IconButton(
                        onPressed: () =>
                            context.read<MultipleAudioState>().pause(),
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
