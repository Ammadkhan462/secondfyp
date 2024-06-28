import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:secondfyp/app/modules/accupancyalloc/controllers/accupancyalloc_controller.dart';

class CustomAppBarController extends GetxController {
  //TODO: Implement CustomAppBarController
  var hostelDetails = HostelAttributes(name: '', rooms: []).obs;

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    
  }

  void fetchHostelDetails(String hostelId) async {
    try {
      var hostelData = await FirebaseFirestore.instance
          .collection('hostels')
          .doc(hostelId)
          .get();

      if (hostelData.exists) {
        Map<String, dynamic> data = hostelData.data()!;
        List<RoomAttributes> roomsAttributes = (data['rooms'] as List)
            .map((room) => RoomAttributes.fromMap(room as Map<String, dynamic>))
            .toList();

        hostelDetails.value = HostelAttributes(
          name: data['name'] ?? '',
          rooms: roomsAttributes,
        );
      } else {
        Get.snackbar('Error', 'Hostel not found!');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
