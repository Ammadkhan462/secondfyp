import 'package:get/get.dart';

import '../controllers/profiledetails_controller.dart';

class ProfiledetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfiledetailsController>(
      () => ProfiledetailsController(),
    );
  }
}
