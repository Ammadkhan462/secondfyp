import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secondfyp/app/modules/signup/controllers/signup_controller.dart';
import 'package:secondfyp/app/routes/app_pages.dart';

class SignupView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final SignupController authController = Get.put(SignupController());

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/ammad.jpeg', // Replace with your background image path
              fit: BoxFit.cover,
            ),
          ),
          // Black Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // "Sign Up" Title Fixed at Top
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0, left: 20.0),
              child: GestureDetector(
                onTap: () => Navigator.pop(context), // Back navigation
                child: Row(
                  children: [
                    Icon(Icons.arrow_back, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Scrollable Form Content
          Padding(
            padding:
                const EdgeInsets.only(top: 100), // Add padding to avoid overlap
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: authController.formKey,
                child: Column(
                  children: [
                    _buildTextField(authController.firstNameController,
                        'First Name', Icons.person),
                    _buildTextField(authController.lastNameController,
                        'Last Name', Icons.person_outline),
                    _buildTextField(
                        authController.emailController, 'Email', Icons.email,
                        keyboardType: TextInputType.emailAddress),
                    _buildTextField(authController.mobileNumberController,
                        'Mobile Number', Icons.phone_android,
                        keyboardType: TextInputType.phone),
                    _buildTextField(authController.passwordController,
                        'Password', Icons.lock_outline,
                        isPassword: true),
                    _buildTextField(authController.dateOfBirthController,
                        'Date of Birth', Icons.calendar_today,
                        keyboardType: TextInputType.datetime),
                    _buildTermsAndConditions(authController),
                    _buildSignUpButton(authController),
                    _buildSignInButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isPassword = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white),
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.deepOrange),
          ),
          fillColor: Colors.white.withOpacity(0.3),
          filled: true,
        ),
        style: TextStyle(color: Colors.white),
        obscureText: isPassword,
        keyboardType: keyboardType,
        validator: (value) => value!.isEmpty ? 'Enter your $label' : null,
      ),
    );
  }

  Widget _buildTermsAndConditions(SignupController authController) {
    return Row(
      children: [
        Obx(() => Checkbox(
              value: authController.isChecked.value,
              onChanged: (value) => authController.toggleCheckbox(),
              checkColor: Colors.blue,
              activeColor: Colors.white,
            )),
        Expanded(
          child: Text(
            'I accept the terms and conditions',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton(SignupController authController) {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.deepOrange, // Active button color
              disabledBackgroundColor:
                  Colors.deepOrange.withOpacity(0.5), // Disabled color
              disabledForegroundColor:
                  Colors.white.withOpacity(0.5), // Disabled text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: authController.isFieldsFilled.value
                ? () {
                    if (authController.formKey.currentState!.validate()) {
                      authController.createAccount(
                        authController.emailController.text.trim(),
                        authController.passwordController.text.trim(),
                      );
                    }
                  }
                : null, // Ensure the button is disabled only when necessary
            child: authController.isLoading.value
                ? CircularProgressIndicator(color: Colors.white)
                : Text('Sign Up'),
          )),
    );
  }

  Widget _buildSignInButton() {
    return TextButton(
      onPressed: () {
        Get.offAllNamed(Routes.SIGNIN);
      },
      child: Text(
        'Already have an account? Sign In',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
