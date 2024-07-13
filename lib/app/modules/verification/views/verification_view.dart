import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/verification_controller.dart';

class VerificationView extends StatelessWidget {
  final VerificationMode mode;

  VerificationView({Key? key, this.mode = VerificationMode.signUp})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final VerificationController verificationController =
        Get.put(VerificationController(mode: mode));

    // This list will hold the focus nodes for the text fields
    List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

    return Scaffold(
      appBar: AppBar(
          title: Text(mode == VerificationMode.signUp
              ? 'Verify Email'
              : 'Verify Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Enter the verification code sent to your email'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                  verificationController.codeControllers.length, (index) {
                return SizedBox(
                  width: 50,
                  child: TextField(
                    controller: verificationController.codeControllers[index],
                    focusNode: _focusNodes[index],
                    decoration: InputDecoration(counterText: ""),
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      if (value.length == 1 && index < _focusNodes.length - 1) {
                        FocusScope.of(context)
                            .requestFocus(_focusNodes[index + 1]);
                      }
                      if (value.isEmpty && index > 0) {
                        FocusScope.of(context)
                            .requestFocus(_focusNodes[index - 1]);
                      }
                    },
                  ),
                );
              }),
            ),
            SizedBox(height: 20),
            Obx(() => ElevatedButton(
                  onPressed: verificationController.isButtonActive.value
                      ? () {
                          String inputCode = verificationController
                              .codeControllers
                              .map((controller) => controller.text)
                              .join();
                          verificationController.verifyCode(inputCode);
                        }
                      : null,
                  child: Text('Verify'),
                )),
          ],
        ),
      ),
    );
  }
}
