import 'package:secondfyp/app/modules/account/views/paymentscard_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AccountController extends GetxController {
  final RxBool isExpense = true.obs;
  final RxString category = 'Uncategorized'.obs;
  final RxString paymentMethod = 'Cash'.obs;
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final RxDouble totalExpenses = 0.0.obs;
  final RxDouble totalIncomes = 0.0.obs;
  final RxDouble totalFullOccupancyBill = 0.0.obs;
  final RxDouble totalCurrentOccupancyBill = 0.0.obs;
  final RxDouble calculatedTotalIncome = 0.0.obs;
  final RxString categoryType = 'Personal'.obs;
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final RxString selectedMonth =
      DateFormat('MMMM yyyy').format(DateTime.now()).obs;
  final RxList<String> categories =
      ['Uncategorized', 'Food', 'Utilities', 'Bills'].obs;
  final RxMap<String, double> hostelBills = <String, double>{}.obs;

  void deleteCategory(String category) {
    if (categories.contains(category)) {
      categories.remove(category);
      update();
    }
  }

  void changeMonth(String newMonth) {
    selectedMonth.value = newMonth;
    fetchTotals();
    calculateTotalRentForSelectedMonth();
  }

  void addCategory(String newCategory) {
    if (!categories.contains(newCategory)) {
      categories.add(newCategory);
      update();
    }
  }

  final List<String> months = List.generate(12, (index) {
    DateTime now = DateTime.now();
    DateTime month = DateTime(now.year, now.month - index, 1);
    return DateFormat('MMMM yyyy').format(month);
  });

  @override
  void onInit() {
    super.onInit();
    fetchTotals();
    calculateTotalRentForSelectedMonth();
  }

  Future<void> calculateTotalRentForSelectedMonth() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    DateTime selectedMonthDate =
        DateFormat('MMMM yyyy').parse(selectedMonth.value);
    DateTime startOfMonth =
        DateTime(selectedMonthDate.year, selectedMonthDate.month, 1);
    DateTime endOfMonth =
        DateTime(selectedMonthDate.year, selectedMonthDate.month + 1, 0);
    DateTime today = DateTime.now();

    if (today.isBefore(endOfMonth)) {
      endOfMonth = today;
    }

    try {
      
      QuerySnapshot hostelsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('hostels')
          .get();

      double fullOccupancyBill = 0.0;
      double currentOccupancyBill = 0.0;

      for (var hostelDoc in hostelsSnapshot.docs) {
        var hostelData = hostelDoc.data() as Map<String, dynamic>;
        String hostelName = hostelData['name'] ?? 'Unnamed Hostel';
        double hostelBill = 0.0;

        List<dynamic> rooms = hostelData['rooms'] ?? [];
        List<dynamic> prices = hostelData['prices'] ?? [];
        Map<String, dynamic> attributes = hostelData['attributes'] ?? {};

        for (var room in rooms) {
          int capacity = room['capacity'] ?? 0;
          int roomNumber = room['roomNumber'] ?? 0;
          double pricePerRoom = prices.isNotEmpty && roomNumber <= prices.length
              ? (prices[roomNumber - 1] as num).toDouble()
              : 0.0;

          double roomAttributePrice = 0.0;
          attributes.forEach((key, value) {
            if (key.startsWith('capacity_${capacity}_attribute_')) {
              roomAttributePrice += (value['price'] as num).toDouble();
            }
          });

          double fullOccupancyRoomBill =
              (pricePerRoom + roomAttributePrice) * daysInMonth(startOfMonth);

          fullOccupancyBill += fullOccupancyRoomBill;

          if (room['residentIds'] != null) {
            for (var residentId in room['residentIds']) {
              DocumentSnapshot residentSnapshot = await FirebaseFirestore
                  .instance
                  .collection('users')
                  .doc(userId)
                  .collection('residents')
                  .doc(residentId)
                  .get();

              if (residentSnapshot.exists) {
                var residentData =
                    residentSnapshot.data() as Map<String, dynamic>;

                Timestamp joinDate;
                if (residentData['selectedDate'] is Timestamp) {
                  joinDate = residentData['selectedDate'];
                } else if (residentData['selectedDate'] is String) {
                  joinDate = Timestamp.fromDate(
                      DateTime.parse(residentData['selectedDate']));
                } else {
                  joinDate = Timestamp.now();
                }

                DateTime joinDateTime = joinDate.toDate();
                DateTime effectiveEndDate = endOfMonth;

                if (joinDateTime.isBefore(effectiveEndDate)) {
                  DateTime effectiveStartDate =
                      joinDateTime.isAfter(startOfMonth)
                          ? joinDateTime
                          : startOfMonth;

                  int daysResidentStayed =
                      effectiveEndDate.difference(effectiveStartDate).inDays +
                          1;

                  if (daysResidentStayed > 0) {
                    double dailyRate = pricePerRoom + roomAttributePrice;
                    double currentRent = dailyRate * daysResidentStayed;

                    double discount = residentData['discount'] ?? 0.0;
                    currentRent -= discount;

                    hostelBill += currentRent;
                    currentOccupancyBill += currentRent;
                  }
                }
              }
            }
          }
        }
      }

      totalFullOccupancyBill.value = fullOccupancyBill;
      totalCurrentOccupancyBill.value = currentOccupancyBill;
      update();
    } catch (e) {
      print('Error calculating total rent for selected month: $e');
      Get.snackbar(
          'Error', 'Failed to calculate total rent for selected month: $e');
    }
  }

  void fetchTotals() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      print("User ID is not available.");
      return;
    }

    DateTime selectedMonthDate =
        DateFormat('MMMM yyyy').parse(selectedMonth.value);
    DateTime startOfMonth =
        DateTime(selectedMonthDate.year, selectedMonthDate.month, 1);
    DateTime endOfMonth =
        DateTime(selectedMonthDate.year, selectedMonthDate.month + 1, 0);

    double totalExpensesAmount = 0.0;
    double totalIncomesAmount = 0.0;

    List<String> categories = ['Hostel', 'Personal'];

    try {
      for (String category in categories) {
        QuerySnapshot expenseSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('expenses')
            .doc(category)
            .collection('data')
            .where('date',
                isGreaterThanOrEqualTo: startOfMonth,
                isLessThanOrEqualTo: endOfMonth)
            .get();

        for (QueryDocumentSnapshot doc in expenseSnapshot.docs) {
          double amount = (doc['amount'] as num).toDouble();
          totalExpensesAmount += amount;
        }

        QuerySnapshot incomeSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('incomes')
            .doc(category)
            .collection('data')
            .where('date',
                isGreaterThanOrEqualTo: startOfMonth,
                isLessThanOrEqualTo: endOfMonth)
            .get();

        for (QueryDocumentSnapshot doc in incomeSnapshot.docs) {
          double amount = (doc['amount'] as num).toDouble();
          totalIncomesAmount += amount;
        }
      }

      totalExpenses.value = totalExpensesAmount;
      totalIncomes.value = totalIncomesAmount;
      _calculateTotalIncome();
      update();
    } catch (e) {
      print("Error fetching totals: $e");
      Get.snackbar('Error', 'Failed to fetch totals: $e');
    }
  }

  void _calculateTotalIncome() {
    calculatedTotalIncome.value = totalIncomes.value -
        totalExpenses.value +
        totalCurrentOccupancyBill.value;
  }

  Future<void> deleteTransaction(String path, String docId) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(path)
        .doc(docId)
        .delete()
        .then(
            (_) => Get.snackbar('Success', 'Transaction deleted successfully'))
        .catchError(
            (e) => Get.snackbar('Error', 'Failed to delete transaction: $e'));
  }

  @override
  void onClose() {
    amountController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  void saveTransaction() async {
    if (amountController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter an amount');
      return;
    }

    double amount = double.tryParse(amountController.text) ?? 0;
    if (amount == 0) {
      Get.snackbar('Error', 'Invalid amount');
      return;
    }

    if (selectedDate.value == null) {
      Get.snackbar('Error', 'Please select a date');
      return;
    }

    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    String type = isExpense.value ? 'expenses' : 'incomes';
    String categoryTypeValue = categoryType.value;

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(type)
        .doc(categoryTypeValue)
        .collection('data')
        .add({
      'amount': amount,
      'category': category.value,
      'paymentMethod': paymentMethod.value,
      'description': descriptionController.text,
      'date': Timestamp.fromDate(selectedDate.value!),
    }).then((_) {
      Get.snackbar('Success', 'Transaction saved successfully');
      clearForm();
      Get.to(() => PaymentscardView());
    }).catchError((error) {
      Get.snackbar('Error', 'Failed to save transaction: $error');
    });
  }

  void clearForm() {
    amountController.clear();
    descriptionController.clear();
    category.value = 'Uncategorized';
    paymentMethod.value = 'Cash';
  }

  Future<Map<String, dynamic>> fetchResidentDetails(String residentId) async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      DocumentSnapshot residentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('residents')
          .doc(residentId)
          .get();
      if (residentSnapshot.exists) {
        return residentSnapshot.data() as Map<String, dynamic>;
      } else {
        throw Exception('Resident not found');
      }
    } catch (e) {
      throw Exception('Failed to fetch resident details: $e');
    }
  }

  int daysInMonth(DateTime date) {
    var firstDayThisMonth = DateTime(date.year, date.month, 1);
    var firstDayNextMonth = DateTime(date.year, date.month + 1, 1);
    return firstDayNextMonth.difference(firstDayThisMonth).inDays;
  }
}
