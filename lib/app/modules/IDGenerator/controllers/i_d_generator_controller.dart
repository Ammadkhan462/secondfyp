import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:secondfyp/app/modules/IDGenerator/idconfirm/views/idconfirm_view.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class IDGeneratorController extends GetxController {
  var name = ''.obs;
  var phoneNumber = ''.obs;
  var cnic = ''.obs;
  var roomType = ''.obs;
  var hasAC = false.obs;
  var selectedDate = Rxn<DateTime>();
  var imageUrl = ''.obs;
  var isLoading = false.obs;
  var hasVehicle = false.obs;
  var hasadvance = false.obs;
  var hassecurity = false.obs;
  var vehicleNumber = ''.obs;
  var vehicleType = ''.obs;
  var advancepayment = 0.0.obs; // Changed to double
  var cnicBackImageUrl = ''.obs;
  var securitypayment = 0.0.obs; // Changed to double
  var cnicFrontImageUrl = ''.obs;
  var vehicleImageUrl = ''.obs;

  var tempResidentImage = Rx<File?>(null);
  var tempCnicFrontImage = Rx<File?>(null);
  var tempCnicBackImage = Rx<File?>(null);
  var tempVehicleImage = Rx<File?>(null);

  // Existing observables

  // Add observables for upload loading states
  var isUploadingResidentImage = false.obs;
  var isUploadingCnicFront = false.obs;
  var isUploadingCnicBack = false.obs;
  var isUploadingVehicleImage = false.obs;

  void setAvancepayment(String number) {
    advancepayment.value = double.tryParse(number) ?? 0.0;
  }

  void toggleadvance(bool value) {
    hasadvance.value = value;
  }

  void togglesecurity(bool value) {
    hassecurity.value = value;
  }

  void setsecuritypayment(String number) {
    securitypayment.value = double.tryParse(number) ?? 0.0;
  }

  void setVehicleNumber(String number) {
    vehicleNumber.value = number;
  }

  void setVehicleType(String type) {
    vehicleType.value = type;
  }

  void toggleVehicle(bool value) {
    hasVehicle.value = value;
  }

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

  Future<void> pickImage(String imageType, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      print("Picked image for $imageType");

      switch (imageType) {
        case 'residentImage':
          tempResidentImage.value = file;
          break;
        case 'cnicFrontImage':
          tempCnicFrontImage.value = file;
          break;
        case 'cnicBackImage':
          tempCnicBackImage.value = file;
          break;
        case 'vehicleImage':
          tempVehicleImage.value = file;
          break;
      }

      uploadImage(file, imageType);
    } else {
      print("No image selected for $imageType");
    }
  }

  Future<void> uploadImage(File file, String imageType) async {
    String path = determinePath(imageType);
    final ref = FirebaseStorage.instance
        .ref()
        .child(path + DateTime.now().toIso8601String() + '.jpg');

    print("Uploading $imageType");
    try {
      await ref.putFile(file);
      String url = await ref.getDownloadURL();
      print("$imageType uploaded: $url");

      switch (imageType) {
        case 'residentImage':
          imageUrl.value = url;
          break;
        case 'cnicFrontImage':
          cnicFrontImageUrl.value = url;
          break;
        case 'cnicBackImage':
          cnicBackImageUrl.value = url;
          break;
        case 'vehicleImage':
          vehicleImageUrl.value = url;
          break;
      }
    } catch (e) {
      print("Failed to upload $imageType: $e");
      Get.snackbar('Upload Error', 'Failed to upload $imageType: $e');
    }
  }

  String determinePath(String imageType) {
    switch (imageType) {
      case 'residentImage':
        return 'residents/resident_images/';
      case 'cnicFrontImage':
        return 'residents/cnic_front/';
      case 'cnicBackImage':
        return 'residents/cnic_back/';
      case 'vehicleImage':
        return 'residents/vehicle_images/';
      default:
        return 'residents/general/';
    }
  }

  void processFormData(GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!
          .save(); // Save all the data from the form to the respective controllers

      isLoading.value = true; // Show loading indicator

      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      // Aggregate all data into a single map before sending to Firestore
      var formData = {
        'name': name.value,
        'phoneNumber': phoneNumber.value,
        'cnic': cnic.value,
        'roomType': roomType.value,
        'hasAC': hasAC.value,
        'selectedDate': selectedDate.value != null
            ? Timestamp.fromDate(selectedDate.value!)
            : null,
        'imageUrl': imageUrl.value,
        'cnicFrontImageUrl': cnicFrontImageUrl.value,
        'cnicBackImageUrl': cnicBackImageUrl.value,
        'vehicleNumber': vehicleNumber.value,
        'vehicleType': vehicleType.value,
        'hasVehicle': hasVehicle.value,
        'vehicleImageUrl': vehicleImageUrl.value,
        'hasPaidAdvance': hasadvance.value,
        'advancePayment': advancepayment.value,
        'hasPaidSecurity': hassecurity.value,
        'securityPayment': securitypayment.value,
      };

      try {
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('residents')
            .add(formData);

        // Update the resident's rent with the advance payment
        if (hasadvance.value && advancepayment.value != 0.0) {
          await updateResidentRentWithAdvance(
              userId, docRef.id, advancepayment.value);
        }

        // Navigate to confirmation screen
        Get.to(() => IdconfirmView(documentId: docRef.id),
            transition: Transition.rightToLeft);
        Get.snackbar('Success', 'Resident added successfully');
      } catch (e) {
        print('Failed to add resident: $e');
        Get.snackbar('Error', 'Failed to add resident: $e');
      } finally {
        isLoading.value = false; // Hide loading indicator
      }
    }
  }

  Future<void> updateResidentRentWithAdvance(
      String userId, String residentId, double advancePayment) async {
    DocumentSnapshot residentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('residents')
        .doc(residentId)
        .get();

    if (residentSnapshot.exists) {
      var residentData = residentSnapshot.data() as Map<String, dynamic>;
      double currentRent = residentData['totalRent'] ?? 0.0;
      double updatedRent = currentRent - advancePayment;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('residents')
          .doc(residentId)
          .update({'totalRent': updatedRent});
    }
  }
}
