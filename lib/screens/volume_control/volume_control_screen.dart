import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jukebox/screens/volume_control/volume_control_state.dart';
import 'package:flutter_jukebox/widgets/app_scaffold.dart';
import 'package:provider/provider.dart';

class VolumeControlScreen extends StatelessWidget {
  const VolumeControlScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VolumeControlState(),
      child: const _VolumeControlScreen(),
    );
  }
}

class _VolumeControlScreen extends StatefulWidget {
  const _VolumeControlScreen({Key? key}) : super(key: key);

  @override
  State<_VolumeControlScreen> createState() => _VolumeControlScreenState();
}

class _VolumeControlScreenState extends State<_VolumeControlScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    context.read<VolumeControlState>().init(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: const Text('Volume Control Sample'),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.green[600]!,
              Colors.green[400]!,
              Colors.green[200]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Spacer(),
              Selector(
                selector: (BuildContext ctx, VolumeControlState controller) =>
                    controller.progressBarState,
                builder: (BuildContext ctx, ProgressBarState state, _) =>
                    ProgressBar(
                  progress: state.current,
                  buffered: state.buffered,
                  total: state.total,
                  onSeek: (Duration position) =>
                      context.read<VolumeControlState>().seek(position),
                ),
              ),
              Selector(
                selector: (BuildContext ctx, VolumeControlState controller) =>
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
                            context.read<VolumeControlState>().play(),
                        icon: const Icon(Icons.play_arrow),
                        iconSize: 32.0,
                      );
                    case AudioState.playing:
                      return IconButton(
                        onPressed: () =>
                            context.read<VolumeControlState>().pause(),
                        icon: const Icon(Icons.pause),
                        iconSize: 32.0,
                      );
                    default:
                      return const SizedBox(
                        height: 32,
                        width: 32,
                      );
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
