import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:secondfyp/app/modules/IDGenerator/idconfirm/views/idconfirm_view.dart';

class IDGeneratorController extends GetxController {
  var name = ''.obs;
  var phoneNumber = ''.obs;
  var cnic = ''.obs;
  var roomType = ''.obs;
  var hasAC = false.obs;
  var selectedDate = Rxn<DateTime>();
  var imageUrl = ''.obs;
  var isLoading = false.obs;

  void toggleAC(bool value) {
    hasAC.value = value;
  }

  void resetFields() {
    name.value = '';
    phoneNumber.value = '+92 ';
    cnic.value = '';
    roomType.value = '';
    hasAC.value = false;
    selectedDate.value = null;
    imageUrl.value = '';
    isLoading.value = false;
  }

  @override
  void onReady() {
    super.onReady();
    resetFields(); // Reset fields whenever the controller is initialized or re-initialized
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      isLoading.value = true; // Show loading indicator
      File file = File(pickedFile.path);
      try {
        // Upload to Firebase Storage
        final ref = FirebaseStorage.instance
            .ref()
            .child('residents')
            .child(DateTime.now().toIso8601String() + '.jpg');
        await ref.putFile(file);
        final url = await ref.getDownloadURL();
        imageUrl.value = url;
      } catch (e) {
        print('Failed to upload image: $e');
      } finally {
        isLoading.value = false; // Hide loading indicator
      }
    }
  }

  void processFormData(GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      // Show loading indicator
      isLoading.value = true;

      // Get the current user's ID
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      // Save data to Firestore
      try {
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('residents')
            .add({
          'name': name.value,
          'phoneNumber': phoneNumber.value,
          'cnic': cnic.value,
          'roomType': roomType.value,
          'hasAC': hasAC.value,
          'selectedDate': selectedDate.value,
          'imageUrl': imageUrl.value,
        });

        // Navigate to confirmation screen
        Get.to(() => IdconfirmView(documentId: docRef.id));
      } catch (e) {
        print('Failed to add resident: $e');
        Get.snackbar('Error', 'Failed to add resident');
      } finally {
        isLoading.value = false;
      }
    }
  }
}
