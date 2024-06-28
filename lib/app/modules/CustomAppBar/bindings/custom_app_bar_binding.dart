import 'package:get/get.dart';

import '../controllers/custom_app_bar_controller.dart';

class CustomAppBarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomAppBarController>(
      () => CustomAppBarController(),
    );
  }
}
