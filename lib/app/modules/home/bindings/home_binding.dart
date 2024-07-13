import 'package:get/get.dart';
import 'package:secondfyp/app/modules/home/controllers/user_header_with_buttons_controller.dart';
import 'package:secondfyp/app/modules/profiledetails/controllers/profiledetails_controller.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserController>(
      () => UserController(),
    );
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.lazyPut<ProfiledetailsController>(
      () => ProfiledetailsController(),
    );
  }
}
