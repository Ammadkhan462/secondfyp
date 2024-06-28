import 'package:flutter/material.dart';

class CreateDrawerItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  const CreateDrawerItem({required this.icon,required this.onTap,required this.text});

  @override
  Widget build(BuildContext context) {
    return ListTile(
    leading: Icon(icon, color: Colors.blue.shade800), // Icon color
    title:
        Text(text, style: TextStyle(color: Colors.blue.shade800)), // Text color
    onTap: onTap,
  );
  
  }
}

// @override
// Widget _createDrawerItem(
//     {required IconData icon,
//     required String text,
//     required VoidCallback onTap}) {
//   return ListTile(
//     leading: Icon(icon, color: Colors.blue.shade800), // Icon color
//     title:
//         Text(text, style: TextStyle(color: Colors.blue.shade800)), // Text color
//     onTap: onTap,
//   );
// }
