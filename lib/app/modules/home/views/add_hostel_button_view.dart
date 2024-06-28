import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:secondfyp/app/routes/app_pages.dart';

class AddHostelButtonView extends GetView {
  const AddHostelButtonView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        side: BorderSide(color: Colors.blue),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      onPressed: () {
        Get.toNamed(Routes.ADDHOSTEL);
      },
      child: Row(
        children: [
          Icon(Icons.add, color: Colors.blue),
          SizedBox(width: 8),
          Text(
            'Add Hostel',
            style: TextStyle(color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
