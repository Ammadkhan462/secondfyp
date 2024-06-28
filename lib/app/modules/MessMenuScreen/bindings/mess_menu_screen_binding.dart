import 'package:get/get.dart';

import '../controllers/mess_menu_screen_controller.dart';

class MessMenuScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MessMenuScreenController>(
      () => MessMenuScreenController(),
    );
  }
}
