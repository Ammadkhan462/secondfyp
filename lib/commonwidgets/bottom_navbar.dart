import 'package:flutter/material.dart';

Widget Common_ButtonBar({
  required Icon Iconss,
  required String names,
  VoidCallback? onTap,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        icon: Iconss,
        onPressed: onTap,
      ),
      Text(names, style: TextStyle(fontSize: 12)), // Adjust text size as needed
    ],
  );
}
