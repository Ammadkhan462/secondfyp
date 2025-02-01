// import 'package:flutter/material.dart';

// import 'package:get/get.dart';
// import 'package:secondfyp/app/modules/MessMenuScreen/controllers/mess_menu_screen_controller.dart';

// void showEditMealDialog(BuildContext context, Map<String, dynamic>? dayData,
//     String mealName, List<String>? mealItems) {
//   // Use TextEditingController to capture and update meal names
//   TextEditingController textEditingController =
//       TextEditingController(text: mealItems?.first);
//   TextEditingController texttEditingController = TextEditingController(
//       text: mealItems != null && mealItems.length > 1 ? mealItems[1] : "");
//   final controller = Get.find<MessMenuScreenController>();

//   // Show dialog
//   Get.defaultDialog(
//     title: 'Edit Meal',
//     content: Column(
//       children: [
//         TextFormField(
//           controller: textEditingController,
//           decoration: const InputDecoration(
//             labelText: 'First Meal',
//             hintText: 'Enter first meal name',
//             border: OutlineInputBorder(),
//             prefixIcon: Icon(Icons.fastfood),
//           ),
//         ),
//         const SizedBox(height: 10),
//         TextFormField(
//           controller: texttEditingController,
//           decoration: const InputDecoration(
//             labelText: 'Second Meal',
//             hintText: 'Enter second meal name',
//             border: OutlineInputBorder(),
//             prefixIcon: Icon(Icons.fastfood),
//           ),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             // Validate inputs if necessary and then update Firestore
//             String firstMeal = textEditingController.text.isNotEmpty
//                 ? textEditingController.text
//                 : "Default First Meal";
//             String secondMeal = texttEditingController.text.isNotEmpty
//                 ? texttEditingController.text
//                 : "Default Second Meal";

//             if (dayData != null && mealName.isNotEmpty) {
//               controller.updateMealInFirestore(
//                   dayData, mealName, firstMeal, secondMeal);
//               Get.back(); // Close the dialog
//             } else {
//               // Handle null or empty cases, maybe show a warning message
//               Get.snackbar("Error", "Missing data for meal update.",
//                   snackPosition: SnackPosition.BOTTOM);
//             }
//           },
//           child: const Text('Submit'),
//         )
//       ],
//     ),
//   );
// }
