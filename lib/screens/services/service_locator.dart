import 'package:flutter_jukebox/screens/background_audio/audio_handler.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

Future<void> initServiceLocator() async {
  getIt.registerSingleton<AudioServiceHandler>(await initeAudioService());
}
