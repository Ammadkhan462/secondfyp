import 'package:get/get.dart';

import '../controllers/addhostel_controller.dart';

class AddhostelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddhostelController>(
      () => AddhostelController(),
    );
  }
}
