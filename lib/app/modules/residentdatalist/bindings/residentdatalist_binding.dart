import 'package:get/get.dart';

import '../controllers/residentdatalist_controller.dart';

class ResidentdatalistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResidentdatalistController>(
      () => ResidentdatalistController(),
    );
  }
}
