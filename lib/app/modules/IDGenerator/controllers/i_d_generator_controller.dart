import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class IDGeneratorController extends GetxController {
  var name = ''.obs;
  var phoneNumber = ''.obs;
  var cnic = ''.obs;
  var roomType = ''.obs;
  var hasAC = false.obs;
  var selectedDate = Rxn<DateTime>();
  var imageUrl = ''.obs;
  var isLoading = false.obs; // Add isLoading observable

  void toggleAC(bool value) {
    hasAC.value = value;
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
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

  void processFormData(GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      // Process the form data, e.g., save to Firestore
    }
  }
}
