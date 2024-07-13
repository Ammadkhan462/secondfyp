import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secondfyp/app/modules/signin/controllers/signin_controller.dart';
import 'package:secondfyp/app/routes/app_pages.dart';
import 'package:secondfyp/constants/constant.dart';


class SignInView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    Get.lazyPut(() => SignInController(), fenix: true);
    final SignInController authController = Get.find();
    // Gradient background similar to SignUp screen
    final gradientBackground = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Colors.blue.shade200, Colors.blue.shade600],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        
        title: Text('Sign In', style: TextStyle(color: Colors.white)),
        backgroundColor:
            Colors.blue.shade600, // Ensuring AppBar matches the gradient
      ),
      body: Container(
        decoration: gradientBackground,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: authController.formKey,
              child: Column(
                children: [
                  _buildTextField(authController.emailController, 'Email',
                      Icons.email, TextInputType.emailAddress),
                  _buildTextField(authController.passwordController, 'Password',
                      Icons.lock_outline, TextInputType.text,
                      isPassword: true),
                  SizedBox(height: 20),
                  _buildSignInButton(authController),
                  _buildSignUpButton(context),
                ],
              ),
            ),
          ),
        ),
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

  Widget _buildSignInButton(SignInController authController) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.deepOrange, // Button color
          onPrimary: Colors.white, // Text color
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

  Widget _buildSignUpButton(BuildContext context) {
    return TextButton(
      onPressed: () => Get.toNamed(Routes.SIGNUP),
      child: Text(
        'Don\'t have an account? Sign Up',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}