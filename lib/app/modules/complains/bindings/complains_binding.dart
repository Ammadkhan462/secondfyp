import 'package:get/get.dart';

import '../controllers/complains_controller.dart';

class ComplainsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ComplainsController>(
      () => ComplainsController(),
    );
  }
}
