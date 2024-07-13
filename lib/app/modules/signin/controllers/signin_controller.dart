import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:secondfyp/app/modules/verification/controllers/verification_controller.dart';
import 'package:secondfyp/app/modules/verification/views/verification_view.dart';
import 'package:secondfyp/app/routes/app_pages.dart';

class SignInController extends GetxController {
  RxString currentOTP = ''.obs;
  RxBool otpSent = false.obs;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> sendOTP(String email) async {
    String username = 'ammadkhanniaziammadkhan@gmail.com';
    String password = 'cjhz vnfn qmkd agan';
    final smtpServer = gmail(username, password);

    // Generate OTP
    String otp = generateOTP();

    final message = Message()
      ..from = Address(username, 'Flutter Mailer')
      ..recipients.add(email)
      ..subject = 'Your OTP for Login'
      ..text = 'Your One Time Password for login is: $otp';

    try {
      await send(message, smtpServer);
      currentOTP.value = otp; // Store the OTP for later verification
      print('OTP sent: ' + otp);
      Get.to(() => VerificationView(mode: VerificationMode.signIn), arguments: {'otp': otp});
    } catch (e) {
      print('OTP not sent.');
      throw Exception('Failed to send OTP');
    }
  }

  String generateOTP() {
    var rng = Random();
    return (rng.nextInt(9000) + 1000).toString(); // Generates a 4-digit code
  }

  RxBool isFieldsFilled = false.obs;
  RxBool isLoading = false.obs;

  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    _addListeners();
  }

  void _addListeners() {
    emailController.addListener(_updateButtonState);
    passwordController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    isFieldsFilled.value = _areFieldsFilled();
  }

  bool _areFieldsFilled() {
    return emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
  }

  Future<void> signIn(String email, String password) async {
    isLoading(true);
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? loggedInUser = userCredential.user;
      if (loggedInUser != null && !loggedInUser.emailVerified) {
        await sendOTP(email); // Send an OTP after successful password verification
        otpSent(true);
        isLoading(false);
        Get.put(VerificationController(mode: VerificationMode.signIn), permanent: true);
      } else {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(loggedInUser?.uid)
            .get();
        Get.offAllNamed(Routes.DASH_BOARD, arguments: userData.data());
      }
    } catch (e) {
      isLoading(false);
      Get.snackbar('Error', e.toString());
    }
  }
}
