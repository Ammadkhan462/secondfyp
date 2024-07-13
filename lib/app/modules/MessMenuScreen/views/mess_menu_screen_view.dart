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
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.8, // Adjust the opacity as needed
                    child: Image.asset(
                      // Adjust the opacity as needed
                      'assets/hell.png', // Replace with your image path
                      fit: BoxFit.cover, // Cover the screen with the image
                    ),
                  ),
                ),
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
                              color: Colors.white),
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
          );
        });
  }
}
