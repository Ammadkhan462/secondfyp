import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secondfyp/commonwidgets/common_text.dart';

class CommonButton extends StatelessWidget {
  final String? text;
  final Rx<IconData?>? selectedIconData;
  final bool? isborder;
  final Color? bordercolors;
  final double? Width;
  final double? borderradius;

  final double? iconSize; // New parameter to control icon size

  final double? fontsizee;
  final VoidCallback? action;
  final Color? primary;
  final double? height;
  final Color? textColor;
  final Color? shadowColor;
  final String? iconAssetPath;
  final IconData? iconData;
  final Color? iconColor;
  final double? borderside;

  CommonButton({
    this.Width,
    this.height,
    this.selectedIconData,
    this.text,
    this.action,
    this.borderradius,
    this.isborder = false,
    this.bordercolors,
    this.iconSize = 24.0, // Default icon size

    this.fontsizee,
    this.iconData,
    this.primary = Colors.transparent,
    this.textColor = Colors.white,
    this.shadowColor = Colors.transparent,
    this.iconAssetPath,
    this.iconColor,
    this.borderside,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> buttonChildren = [];

    // Add icon if it is provided
    if (iconData != null) {
      buttonChildren.add(Icon(iconData, color: iconColor ?? textColor, size: 30)
          .marginOnly(right: text != null && text!.isNotEmpty ? 8 : 0));
    }

    // Add image if it is provided
    if (iconAssetPath != null) {
      buttonChildren.add(Image.asset(
        iconAssetPath!, width: iconSize, // Use the iconSize for width
        height: iconSize,
      ).marginOnly(right: text != null && text!.isNotEmpty ? 8 : 0));
    }

    // Add text only if it is not null and not empty
    if (text != null && text!.isNotEmpty) {
      buttonChildren.add(
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: CustomText(
              text: text!,
              color: textColor ?? Colors.white,
              fontSize: fontsizee ?? 20,
            ).marginAll(5),
          ),
        ),
      );
    }

    return SizedBox(
      height: height ?? 50,
      width: Width ?? 320,
      child: ElevatedButton(
        onPressed: action,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderradius ?? 10),
            side: isborder ?? false
                ? BorderSide.none
                : BorderSide(
                    color: bordercolors ?? Colors.transparent,
                    width: borderside ?? 0),
          ),
          backgroundColor: primary,
          foregroundColor: textColor,
          shadowColor: shadowColor,
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: buttonChildren,
        ),
      ),
    );
  }
}
