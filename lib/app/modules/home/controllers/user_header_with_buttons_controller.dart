import 'dart:io';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class UserController extends GetxController {
  var isLoading = true.obs;
  var isImageUploading = false.obs;
  var userData = {}.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
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
        } else {
          userData.value = {};
        }
      } else {
        print('No user logged in');
        userData.value = {};
      }
    } catch (e) {
      userData.value = {};
      print('Error fetching user data: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> uploadProfileImage(File imageFile) async {
    try {
      isImageUploading(true);
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child(currentUser.uid + '.jpg');
        await storageRef.putFile(imageFile);
        String downloadUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({'profileImage': downloadUrl});

        userData.value = {'profileImage': downloadUrl};
      }
    } catch (e) {
      print('Error uploading profile image: $e');
    } finally {
      isImageUploading(false);
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      await uploadProfileImage(file);
    }
  }
}
