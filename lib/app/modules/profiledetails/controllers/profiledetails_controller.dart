import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:secondfyp/app/modules/profiledetails/views/residentdata.dart';

class ProfiledetailsController extends GetxController {
  var residentData = [].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchResidentData();
  }

  Future<void> fetchResidentData() async {
    isLoading.value = true;
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('residents').get();
      residentData.value = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching resident data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToResidentData() {
    Get.lazyPut(() => ProfiledetailsController());
    Get.to(() => ResidentDataListView());
  }
}
