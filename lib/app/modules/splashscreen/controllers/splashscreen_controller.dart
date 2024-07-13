import 'package:get/get.dart';
import 'package:secondfyp/app/routes/app_pages.dart';

class SplashscreenController extends GetxController {
  //TODO: Implement SplashscreenController

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

 void onReady() {
    super.onReady();
    Future.delayed(Duration(seconds: 5), () {
      Get.offNamed(Routes.SIGNUP);  // Ensure you have the route '/signup' set up in your routes
    });
  }
  void _navigateToSignup() async {
    // Wait for a few seconds on the splash screen
    await Future.delayed(Duration(seconds: 3));
    // Navigate to the signup screen
    Get.offNamed(Routes.SIGNUP); // Ensure you have the route '/signup' set up in your GetX route management
  }
  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
