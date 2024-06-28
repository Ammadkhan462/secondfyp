import 'package:get/get.dart';

import '../controllers/i_d_generator_controller.dart';

class IDGeneratorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IDGeneratorController>(
      () => IDGeneratorController(),
    );
  }
}
