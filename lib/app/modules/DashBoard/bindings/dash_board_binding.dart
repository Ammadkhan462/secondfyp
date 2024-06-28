import 'package:get/get.dart';
import 'package:secondfyp/app/modules/IDGenerator/controllers/i_d_generator_controller.dart';

import '../controllers/dash_board_controller.dart';

class DashBoardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DashBoardController());
    // Initialize other required controllers here
    Get.put(IDGeneratorController());
  }
}
