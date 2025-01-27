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
                              Map<String, dynamic> dayData = _.weekMeals
                                  .firstWhere((meal) => meal['day'] == day);

                              List<dynamic> dynamicMealItems =
                                  dayData['meals'][mealName] ?? [];
                              List<String> mealItems =
                                  dynamicMealItems.cast<String>();

                              showEditMealDialog(
                                  context, dayData, mealName, mealItems);
                            }),
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
}
