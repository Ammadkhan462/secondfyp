import 'package:get/get.dart';

import '../controllers/verificationsignin_controller.dart';

class VerificationsigninBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VerificationsigninController>(
      () => VerificationsigninController(),
    );
  }
}
