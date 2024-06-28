import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
  
class MessMenuScreenController extends GetxController {
  var selectedIndex = 0.obs;
  var weekMeals = <Map<String, dynamic>>[].obs; // This line is crucial

  @override
  void onInit() {
    super.onInit();
    fetchWeekMeals();
  }

  void fetchWeekMeals() async {
    FirebaseFirestore.instance.collection('weekMeals').snapshots().listen(
      (snapshot) {
        weekMeals.value = snapshot.docs.map((doc) {
          // Include the document ID in the data map
          return {
            'id': doc.id, // Capture and include the document ID
            ...doc.data() as Map<String, dynamic>,
          };
        }).toList();
      },
      onError: (error) => print("Failed to fetch week meals: $error"),
    );
  }

  void onItemTapped(int index) {
    selectedIndex.value = index; // Update observable value
  }

  final count = 0.obs;
  @override
  @override
  void onReady() {
    super.onReady();
  }

  void updateMealInFirestore(Map<String, dynamic> dayData, String mealName,
      String firstMeal, String secondMeal) {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    // Ensure 'id' exists and is not null
    String? docId = dayData['id'];
    if (docId == null) {
      print("Document ID is null");
      Get.snackbar("Update Failed", "Document ID is missing.",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    Map<String, dynamic> updatedMeals = {
      'meals': {
        ...dayData['meals'],
        mealName: [firstMeal, secondMeal]
      }
    };

    db.collection('weekMeals').doc(docId).update(updatedMeals).then((_) {
      print('Meal updated successfully');
      Get.snackbar("Update Success", "Meal updated successfully.",
          snackPosition: SnackPosition.BOTTOM);
    }).catchError((error) {
      print('Error updating meal: $error');
      Get.snackbar("Update Failed", "Error updating meal: $error",
          snackPosition: SnackPosition.BOTTOM);
    });
  }

  Future<void> uploadWeekMeals() async {
    final db = FirebaseFirestore.instance;
    try {
      final predefinedWeekMeals = [
        {
          'day': 'Monday',
          'meals': {
            'Breakfast': ['Aloo Paratha', 'Lassi'],
            'Lunch': ['Chicken Biryani', 'Raita'],
            'Dinner': ['Beef Karahi', 'Naan'],
          },
        },
        {
          'day': 'Tuesday',
          'meals': {
            'Breakfast': ['Channa Chaat', 'Tea'],
            'Lunch': ['Daal Chawal', 'Salad'],
            'Dinner': ['Mutton Korma', 'Roti'],
          },
        },
        {
          'day': 'Wednesday',
          'meals': {
            'Breakfast': ['Nihari', 'Naan'],
            'Lunch': ['Aloo Gosht', 'Rice'],
            'Dinner': ['Mix Vegetable', 'Chapati'],
          },
        },
        {
          'day': 'Thursday',
          'meals': {
            'Breakfast': ['Halwa Puri', 'Cholay'],
            'Lunch': ['Chicken Handi', 'Rice'],
            'Dinner': ['Fish Curry', 'Lemon Rice'],
          },
        },
        {
          'day': 'Friday',
          'meals': {
            'Breakfast': ['Fried Eggs', 'Paratha'],
            'Lunch': ['Chicken Karahi', 'Naan'],
            'Dinner': ['Haleem', 'Naan'],
          },
        },
        {
          'day': 'Saturday',
          'meals': {
            'Breakfast': ['Siri Paye', 'Naan'],
            'Lunch': ['Seekh Kebabs', 'Naan'],
            'Dinner': ['Shahi Paneer', 'Basmati Rice'],
          },
        },
        {
          'day': 'Sunday',
          'meals': {
            'Breakfast': ['Murgh Cholay', 'Naan'],
            'Lunch': ['Saag', 'Makki di Roti'],
            'Dinner': ['Biryani', 'Kachumber Salad'],
          },
        },
        // Add the rest of the days...
      ];

      for (var dayMeal in predefinedWeekMeals) {
        await db.collection('weekMeals').add(dayMeal);
      }
      print("Week meals uploaded successfully.");
    } catch (e) {
      print("Error uploading week meals: $e");
    }
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
