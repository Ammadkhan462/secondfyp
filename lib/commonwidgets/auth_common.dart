import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secondfyp/commonwidgets/common_button.dart';
import 'package:secondfyp/commonwidgets/common_text.dart';


class AuthOptionsWidget extends StatelessWidget {
  final String continueText;
  final String accountQuestionText;
  final String loginText;
  final Color colors;
  final Color colors2;
  final VoidCallback onApplePressed;
  final VoidCallback onGooglePressed;
  final VoidCallback onLoginPressed;
  final double iconSize; 

  const AuthOptionsWidget({
    Key? key,
    required this.colors2,
    required this.colors,
    required this.continueText,
    required this.accountQuestionText,
    required this.loginText,
    required this.onApplePressed,
    required this.onGooglePressed,
    required this.onLoginPressed,
    this.iconSize = 48, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = 
    MediaQuery.of(context).size.width;
    double buttonWidth = screenWidth / 2 -
        10; 

    return Column(
      children: [
        CustomText(
          text: continueText,
          color: colors,
          fontSize: 14,
        ).marginOnly(top: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CommonButton(
              iconAssetPath: 'assets/logos/apples.png',
              action: onApplePressed,
              Width: buttonWidth, 
              iconSize: 60, 
            ),
            CommonButton(
              iconAssetPath: 'assets/logos/googles.png',
              action: onGooglePressed,
              Width: buttonWidth, 
              iconSize: 60, 
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText(
              text: accountQuestionText,
              color: colors,
              fontSize: 14,
            ),
            GestureDetector(
              onTap: onLoginPressed,
              child: CustomText(
                text: loginText,
                color: colors2,
                fontSize: 14,
              ),
            ),
          ],
        )
      ],
    );
  }
}
