import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:secondfyp/app/modules/MessMenuScreen/controllers/mess_menu_screen_controller.dart';
import 'package:secondfyp/app/modules/MessMenuScreen/views/showeditmealdialog_view.dart';

class MealcardView extends GetView<MessMenuScreenController> {
  final String day; 
  final String mealName;
  final List<String> meals;
  final String startTime;
  final String endTime;

  MealcardView({
    required this.day, 
    required this.mealName,
    required this.meals,
    required this.startTime,
    required this.endTime,
  }) : assert(
            meals is List<String>); 

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessMenuScreenController>(
        init: MessMenuScreenController(),
        builder: (_) {
          return Card(
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade300, Colors.blue.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          mealName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      IconButton(
  icon: const Icon(Icons.edit, color: Colors.white70),
  onPressed: () {
    Map<String, dynamic> dayData = _.weekMeals.firstWhere((meal) => meal['day'] == day);
    List<dynamic> dynamicMealItems = dayData['meals'][mealName] ?? [];
    List<String> mealItems = dynamicMealItems.cast<String>();

    String startTime = dayData['startTime'] ?? 'Start Time Not Set';  // Fetch start time
    String endTime = dayData['endTime'] ?? 'End Time Not Set';  // Fetch end time

    showEditMealDialog(context, dayData, mealName, mealItems, startTime, endTime);
  }
),

                      ],
                    ),
                    Text(
                      '$startTime - $endTime',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    ...meals
                        .map((meal) => Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                meal,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ))
                        .toList(),
                  ],
                ),
              ),
            ),
          );
        });
  }
  void showEditMealDialog(BuildContext context, Map<String, dynamic> dayData,
    String mealName, List<String> mealItems, String startTime, String endTime) {
  TextEditingController textEditingController = TextEditingController(text: mealItems.isNotEmpty ? mealItems.join(", ") : "");
  TextEditingController startTimeController = TextEditingController(text: startTime);
  TextEditingController endTimeController = TextEditingController(text: endTime);

  Get.defaultDialog(
    title: 'Edit Meal',
    content: SingleChildScrollView(
      child: Column(
        children: [
          TextFormField(
            controller: textEditingController,
            decoration: const InputDecoration(
              labelText: 'Meal Items',
              hintText: 'Enter meal items separated by commas',
            ),
          ),
          TextFormField(
            controller: startTimeController,
            decoration: const InputDecoration(
              labelText: 'Start Time',
              hintText: 'Enter start time',
            ),
          ),
          TextFormField(
            controller: endTimeController,
            decoration: const InputDecoration(
              labelText: 'End Time',
              hintText: 'Enter end time',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Validate inputs if necessary
              List<String> updatedMealItems = textEditingController.text.split(',').map((item) => item.trim()).toList();
              String updatedStartTime = startTimeController.text.trim();
              String updatedEndTime = endTimeController.text.trim();

              controller.updateMealInFirestore(
                  dayData, mealName, updatedMealItems, updatedStartTime, updatedEndTime);
              Get.back(); // Close the dialog
            },
            child: const Text('Update'),
          )
        ],
      ),
    ),
  );
}

}
