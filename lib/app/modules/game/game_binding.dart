import 'package:get/get.dart';
import 'package:getx_checkers/app/data/audio/audio_service.dart';
import 'package:getx_checkers/app/modules/common/dialog_manager.dart';


import 'game_controller.dart';

class GameBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GameController>(
      () => GameController(audioService: AudioService(),
      dialogManager:  DialogManager()),
    );
  }
}
