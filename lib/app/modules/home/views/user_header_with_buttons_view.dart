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
        // Header Container
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade300,
                Color.fromARGB(255, 101, 141, 174)
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple[200]!,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            "Your Hostels",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        // Buttons Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              ...List.generate(
                controller.hostels.length,
                (index) =>
                    _buildHostelButtonWithDelete(context, controller, index),
              ),
              const SizedBox(width: 8), // Spacing between buttons
              AddHostelButtonView(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHostelButtonWithDelete(
      BuildContext context, HomeController controller, int index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildGradientButton(context, controller, index),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _showDeleteHostelDialog(context, controller, index),
        ),
      ],
    );
  }

  Widget _buildGradientButton(
      BuildContext context, HomeController controller, int index) {
    return Obx(() {
      bool isSelected = controller.selectedButtonIndex.value == index;
      return GestureDetector(
        onTap: () => controller.changeTabIndex(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      Colors.blue.shade500,
                      Color.fromARGB(255, 69, 127, 193)
                    ],
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
                      color: Colors.blue.shade300.withOpacity(0.6),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Icon(
                Icons.apartment,
                color: isSelected ? Colors.white : Colors.grey.shade800,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                controller.hostels[index].name,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade800,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showDeleteHostelDialog(
      BuildContext context, HomeController controller, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
              'Are you sure you want to delete this hostel? This action cannot be undone.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the confirmation dialog
                controller.deleteHostel(index);
              },
            ),
          ],
        );
      },
    );
  }
}
