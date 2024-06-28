import 'package:get/get.dart';

class UserHeaderWithButtonsController extends GetxController {
  //TODO: Implement UserHeaderWithButtonsController

 var selectedIndex = 0.obs; // Observable for selected index

  void changeTabIndex(int index) {
    selectedIndex.value = index; // Function to change the selected index
  }  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

}
