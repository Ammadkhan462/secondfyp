import 'package:get/get.dart';

import '../controllers/idconfirm_controller.dart';

class IdconfirmBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IdconfirmController>(
      () => IdconfirmController(),
    );
  }
}
