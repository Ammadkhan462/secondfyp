import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secondfyp/app/modules/verification/views/verification_view.dart';
import 'package:secondfyp/app/routes/app_pages.dart';
import 'package:secondfyp/app/modules/verification/controllers/verification_controller.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class SignupController extends GetxController {
  // Existing code...

  Future<void> sendEmail(String email, String code) async {
    String username = 'ammadkhanniaziammadkhan@gmail.com';
    String password = 'cjhz vnfn qmkd agan';

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Flutter Mailer')
      ..recipients.add(email)
      ..subject = 'verify to get login into your account'
      ..text = 'Your verification code is $code';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent. \n${e.toString()}');
    }
  }

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dateOfBirthController = TextEditingController();

  RxBool isChecked = false.obs;
  RxBool isFieldsFilled = false.obs;
  RxBool isLoading = false.obs;

  FirebaseAuth _auth = FirebaseAuth.instance;
  Rx<User?> user = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
    ever(user, _initialScreen);
    _addListeners();
  }

  void _addListeners() {
    firstNameController.addListener(_updateButtonState);
    lastNameController.addListener(_updateButtonState);
    emailController.addListener(_updateButtonState);
    mobileNumberController.addListener(_updateButtonState);
    passwordController.addListener(_updateButtonState);
    dateOfBirthController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    isFieldsFilled.value = _areFieldsFilled();
  }

  bool _areFieldsFilled() {
    return formKey.currentState?.validate() ?? false;
  }

  void toggleCheckbox() {
    isChecked.value = !isChecked.value;
  }

  void _initialScreen(User? user) {
    if (user == null) {
      if (Get.currentRoute != Routes.SIGNUP) {
        Get.offAllNamed(Routes.SIGNUP);
      }
    } else {
      if (!user.emailVerified) {
        // Get.to(() => VerificationView(mode: VerificationMode.signUp));
      } else {
        Get.offAllNamed(Routes.HOME);
      }
    }
  }

  Future<void> createAccount(String email, String password) async {
    if (!GetUtils.isEmail(email)) {
      Get.snackbar("Error", "Please enter a valid email");
      return;
    }
    isLoading(true);
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? newUser = userCredential.user;
      if (newUser != null) {
        await createUserProfile(newUser.uid, email);
        final verificationCode = generateVerificationCode();
        await sendVerificationCode(email, verificationCode);
        Get.snackbar("Success", "Verification email has been sent");
        Get.toNamed(Routes.VERIFICATION, arguments: {'otp': verificationCode});
      } else {
        Get.snackbar("Error", "User creation failed");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> createUserProfile(String uid, String email) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'firstName': firstNameController.text.trim(),
      'lastName': lastNameController.text.trim(),
      'email': email,
      'mobileNumber': mobileNumberController.text.trim(),
      'dateOfBirth': dateOfBirthController.text.trim(),
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> sendVerificationCode(String email, String verificationCode) async {
    final verificationController = Get.put(VerificationController());
    verificationController.setVerificationCode(verificationCode);
    await sendEmail(email, verificationCode);
  }

  String generateVerificationCode() {
    var rng = Random();
    return (rng.nextInt(9000) + 1000).toString(); // Generates a 4-digit code
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    mobileNumberController.dispose();
    passwordController.dispose();
    dateOfBirthController.dispose();
    super.onClose();
  }
}
