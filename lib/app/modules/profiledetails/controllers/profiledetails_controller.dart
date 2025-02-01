import 'dart:io';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:secondfyp/app/routes/app_pages.dart';

class ProfiledetailsController extends GetxController {
  var profileImage = ''.obs;
  var name = ''.obs;
  var isLoading = true.obs;
  var isImageUploading = false.obs;
  var residentData = <Map<String, dynamic>>[].obs;
  var userData = {}.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    fetchResidentData();
    fetchUserData();
  }

  void fetchResidentData() async {
    try {
      isLoading(true);
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('residents')
            .get();

        if (snapshot.docs.isNotEmpty) {
          residentData.value = snapshot.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Add the resident ID to the data map
            return data;
          }).toList();
        } else {
          residentData.value = [];
        }
      } else {
        print('No user logged in');
        residentData.value = [];
      }
    } catch (e) {
      residentData.value = [];
      print('Error fetching resident data: $e');
    } finally {
      isLoading(false);
    }
  }

  void fetchUserData() async {
    try {
      isLoading(true);
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (snapshot.exists) {
          userData.value = snapshot.data() as Map<String, dynamic>;
          profileImage.value = userData['imageUrl'] ?? '';
          name.value = userData['name'] ?? '';
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      isImageUploading(true);
      File file = File(pickedFile.path);
      try {
        User? currentUser = _auth.currentUser;
        if (currentUser != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('users')
              .child(currentUser.uid)
              .child('profile.jpg');
          await ref.putFile(file);
          final url = await ref.getDownloadURL();

          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .update({'imageUrl': url});

          userData['imageUrl'] = url;
          update();
        }
      } catch (e) {
        print('Failed to upload image: $e');
      } finally {
        isImageUploading(false);
      }
    }
  }

  Future<void> deleteResident(String residentId) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('No user is logged in.');
        return;
      }

      // Reference to the resident document
      DocumentReference residentRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('residents')
          .doc(residentId);

      // Fetch the resident document to check its existence
      DocumentSnapshot residentSnapshot = await residentRef.get();
      if (!residentSnapshot.exists) {
        print('Resident document does not exist.');
        return;
      }

      // Get roomNumber from resident data if available
      var residentData = residentSnapshot.data() as Map<String, dynamic>;
      String? roomNumber = residentData['roomNumber'];

      // Delete the resident document
      await residentRef.delete();
      print('Resident document deleted successfully.');

      // Update room occupancy if roomNumber exists
      if (roomNumber != null) {
        QuerySnapshot hostelSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('hostels')
            .get();

        if (hostelSnapshot.docs.isNotEmpty) {
          DocumentSnapshot hostelDoc = hostelSnapshot.docs.first;
          Map<String, dynamic> hostelData =
              hostelDoc.data() as Map<String, dynamic>;
          List<dynamic> rooms = hostelData['rooms'];

          for (var room in rooms) {
            if (room['roomNumber'].toString() == roomNumber) {
              room['currentOccupancy'] = room['currentOccupancy'] - 1;
              room['residentIds'].remove(residentId);
              break;
            }
          }

          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .collection('hostels')
              .doc(hostelDoc.id)
              .update({'rooms': rooms});
          print('Room occupancy updated successfully.');
        }
      } else {
        print('roomNumber not found in resident data.');
      }

      // Refresh the resident data
      fetchResidentData();
    } catch (e) {
      print('Error deleting resident: $e');
    }
  }

  Future<void> refreshData() async {
    fetchResidentData();
  }

  Future<void> logout() async {
    await _auth.signOut();
    Get.offAllNamed(Routes.SIGNUP);
  }
}
