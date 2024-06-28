import 'package:get/get.dart';

import '../controllers/accupancyalloc_controller.dart';

class AccupancyallocBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccupancyallocController>(
      () => AccupancyallocController(),
    );
  }
}
