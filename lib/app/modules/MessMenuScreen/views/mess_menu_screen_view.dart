import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secondfyp/app/modules/MessMenuScreen/views/mealcard_view.dart';

import '../controllers/mess_menu_screen_controller.dart';

class MessMenuScreenView extends GetView<MessMenuScreenController> {
  const MessMenuScreenView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessMenuScreenController>(
        init: MessMenuScreenController(),
        builder: (_) {
          return Scaffold(
            body: SafeArea(
              child: Stack(children: <Widget>[
                Obx(
                  () => ListView.builder(
                    itemCount: _.weekMeals.length,
                    itemBuilder: (context, index) {
                      final dayMeal = _.weekMeals[index];
                      return ExpansionTile(
                        title: Text(
                          dayMeal['day'] as String,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                        children: <Widget>[
                          MealcardView(
                            day: dayMeal['day'] as String,
                            mealName: 'Breakfast',
                            meals:
                                (dayMeal['meals']['Breakfast'] as List<dynamic>)
                                    .cast<String>(),
                            startTime: '7:00 AM',
                            endTime: '10:00 AM',
                          ),
                          MealcardView(
                            mealName: 'Lunch',
                            day: dayMeal['day'] as String,
                            meals: (dayMeal['meals']['Lunch'] as List<dynamic>)
                                .cast<String>(),
                            startTime: '12:00 PM',
                            endTime: '2:00 PM',
                          ),
                          MealcardView(
                            day: dayMeal['day'] as String,
                            mealName: 'Dinner',
                            meals: (dayMeal['meals']['Dinner'] as List<dynamic>)
                                .cast<String>(),
                            startTime: '6:00 PM',
                            endTime: '9:00 PM',
                          ),
                        ],
                      );
                    },
                  ),
                )
              ]),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => showCreateMealDialog(context),
              child: Icon(Icons.add),
              backgroundColor: Colors.blue,
            ),
          );
        });
  }

  void showCreateMealDialog(BuildContext context) {
    TextEditingController breakfastController = TextEditingController();
    TextEditingController lunchController = TextEditingController();
    TextEditingController dinnerController = TextEditingController();
    String selectedDay = 'Monday';
    List<String> days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    Get.defaultDialog(
      title: 'Create New Meal',
      content: Column(
        children: [
          DropdownButton<String>(
            value: selectedDay,
            onChanged: (String? newValue) {
              selectedDay = newValue!;
            },
            items: days.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          TextFormField(
            controller: breakfastController,
            decoration: const InputDecoration(
              labelText: 'Breakfast',
              hintText: 'Enter breakfast items',
            ),
          ),
          TextFormField(
            controller: lunchController,
            decoration: const InputDecoration(
              labelText: 'Lunch',
              hintText: 'Enter lunch items',
            ),
          ),
          TextFormField(
            controller: dinnerController,
            decoration: const InputDecoration(
              labelText: 'Dinner',
              hintText: 'Enter dinner items',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Map<String, List<String>> meals = {
                'Breakfast': breakfastController.text
                    .split(',')
                    .map((s) => s.trim())
                    .toList(),
                'Lunch': lunchController.text
                    .split(',')
                    .map((s) => s.trim())
                    .toList(),
                'Dinner': dinnerController.text
                    .split(',')
                    .map((s) => s.trim())
                    .toList(),
              };
              controller.createWeekMeal(selectedDay, meals);
              Get.back(); // Close the dialog
            },
            child: const Text('Submit'),
          )
        ],
      ),
    );
  }
}
