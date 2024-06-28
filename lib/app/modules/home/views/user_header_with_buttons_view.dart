import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secondfyp/app/modules/home/controllers/home_controller.dart';
import 'package:secondfyp/app/modules/home/views/add_hostel_button_view.dart';

class UserHeaderWithButtonsView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    HomeController controller = Get.find<HomeController>();
    return Column(
      children: [
        Container(padding: EdgeInsets.all(16), color: Colors.white),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              ...List.generate(controller.hostels.length,
                  (index) => _buildGradientButton(controller, index)),
              SizedBox(width: 8), // Spacing between buttons
              AddHostelButtonView(), // Ensure this is correctly implemented
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton(HomeController controller, int index) {
    return Obx(() {
      bool isSelected = controller.selectedButtonIndex.value == index;
      return GestureDetector(
        onTap: () => controller.changeTabIndex(index),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          margin: EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [Colors.grey.shade300, Colors.grey.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: Colors.blue.shade200,
                        blurRadius: 10,
                        offset: Offset(0, 5)),
                  ]
                : [],
          ),
          child: Text(
            'Hostel ${index + 1}',
            style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade800,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ),
      );
    });
  }
}
