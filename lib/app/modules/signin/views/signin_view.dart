import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secondfyp/app/modules/signin/controllers/signin_controller.dart';
import 'package:secondfyp/app/routes/app_pages.dart';

class SignInView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => SignInController(), fenix: true);
    final SignInController authController = Get.find();

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
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // "Login" Title at Top-Left Corner
          Positioned(
            top: 50, // Adjust the vertical position
            left: 20, // Adjust the horizontal position
            child: GestureDetector(
              onTap: () => Navigator.pop(context), // Back navigation
              child: Row(
                children: [
                  Icon(Icons.arrow_back, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Login',
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
          // Login Form
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: authController.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Email TextField
                    _buildTextField(
                      authController.emailController,
                      'Email',
                      Icons.email,
                      TextInputType.emailAddress,
                    ),
                    // Password TextField
                    _buildTextField(
                      authController.passwordController,
                      'Password',
                      Icons.lock_outline,
                      TextInputType.text,
                      isPassword: true,
                    ),
                    SizedBox(height: 20),
                    // Sign In Button
                    _buildSignInButton(authController),
                    // Sign Up Button
                    _buildSignUpButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, TextInputType keyboardType,
      {bool isPassword = false}) {
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
            borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.deepOrange),
          ),
          fillColor: Colors.white.withOpacity(0.2),
          filled: true,
        ),
        style: TextStyle(color: Colors.white),
        obscureText: isPassword,
        keyboardType: keyboardType,
        validator: (value) => value!.isEmpty ? 'Enter your $label' : null,
      ),
    );
  }

  Widget _buildSignInButton(SignInController authController) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.deepOrange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () {
          if (authController.formKey.currentState!.validate()) {
            print("Attempting to sign in");
            authController.signIn(
              authController.emailController.text.trim(),
              authController.passwordController.text.trim(),
            );
          } else {
            print("Form is not valid");
          }
        },
        child: Text('Sign In'),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return TextButton(
      onPressed: () => Get.toNamed(Routes.SIGNUP),
      child: Text(
        'Don\'t have an account? Sign Up',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
