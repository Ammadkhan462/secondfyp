import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secondfyp/app/routes/app_pages.dart';

enum VerificationMode { signUp, signIn }

class VerificationController extends GetxController {
  final codeControllers = List.generate(4, (_) => TextEditingController());
  final FirebaseAuth _auth = FirebaseAuth.instance;
  VerificationMode mode;

  RxBool isButtonActive = false.obs;
  RxString verificationCode = ''.obs;

  VerificationController({this.mode = VerificationMode.signUp});

  @override
  void onInit() {
    super.onInit();
    _addListeners();
    if (Get.arguments != null && Get.arguments['otp'] != null) {
      verificationCode.value = Get.arguments['otp'];
    }
  }

  void _addListeners() {
    for (var controller in codeControllers) {
      controller.addListener(_updateVerificationButtonState);
    }
  }

  void _updateVerificationButtonState() {
    isButtonActive.value = _areCodeFieldsFilled();
  }

  bool _areCodeFieldsFilled() {
    return codeControllers.every((controller) => controller.text.isNotEmpty);
  }

  void setVerificationCode(String code) {
    verificationCode.value = code;
  }

  void verifyCode(String inputCode) async {
    print("Expected OTP: ${verificationCode.value}");  // Debug: print expected OTP
    print("Received OTP: $inputCode");                 // Debug: print received OTP

    if (inputCode == verificationCode.value) {
      if (mode == VerificationMode.signIn) {
        // Handle sign-in logic here
        Get.snackbar("Success", "Login successful");
        Get.offAllNamed(Routes.DASH_BOARD); // Navigate to the home screen
      } else {
        // Sign-up logic
        User? currentUser = _auth.currentUser;
        if (currentUser != null) {
          await currentUser.reload();
          await currentUser.sendEmailVerification();
          await _auth.signOut();
          Get.snackbar("Success", "Verification successful, please sign in.");
          Get.offAllNamed(Routes.SIGNIN); // Navigate to the Sign-In screen
        } else {
          Get.snackbar("Error", "User not found");
        }
      }
    } else {
      Get.snackbar("Error", "Invalid verification code");
    }
  }

  @override
  void onClose() {
    codeControllers.forEach((controller) => controller.dispose());
    super.onClose();
  }
}
