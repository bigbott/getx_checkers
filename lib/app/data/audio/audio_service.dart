import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:getx_checkers/app/data/audio/audio_service_interface.dart';

class AudioService  extends GetxService implements AudioServiceInterface {
  final AudioPlayer _audioPlayer = AudioPlayer();
  @override
  void playMoveSound() async {
    await _audioPlayer.play(AssetSource('sounds/move.mp3'));
  }

  @override
  void playCaptureSound() async {
    await _audioPlayer.play(AssetSource('sounds/capture.mp3'));
  }

  @override
  void playWinSound() async {
    await _audioPlayer.play(AssetSource('sounds/win.mp3'));
  }

   @override
  void playDefeatSound() async {
    await _audioPlayer.play(AssetSource('sounds/defeat.mp3'));
  }
}
