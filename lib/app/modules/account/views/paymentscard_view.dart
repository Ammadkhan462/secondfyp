import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/account_controller.dart';

class PaymentscardView extends StatelessWidget {
  const PaymentscardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AccountController controller = Get.put(AccountController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Overview'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.fetchTotals();
              controller.calculateTotalRentForSelectedMonth();
            },
          ),
        ],
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSummaryCard(
                title: 'Total Full Occupancy Bill for Selected Month',
                value: controller.totalFullOccupancyBill.value,
                color: Colors.blueAccent,
              ),
              _buildSummaryCard(
                title: 'Total Current Occupancy Bill for Selected Month',
                value: controller.totalCurrentOccupancyBill.value,
                color: Colors.greenAccent,
              ),
              _buildMonthSelector(controller),
              _buildHostelBillsList(controller),
              _buildSummaryCard(
                title: 'Total Expenses',
                value: controller.totalExpenses.value,
                color: Colors.redAccent,
              ),
              _buildSummaryCard(
                title: 'Total Incomes',
                value: controller.totalIncomes.value,
                color: Colors.orangeAccent,
              ),
              _buildSummaryCard(
                title: 'Calculated Total Income',
                value: controller.calculatedTotalIncome.value,
                color: Colors.purpleAccent,
              ),
              ElevatedButton(
                onPressed: () {
                  Get.to(() => const CategoriesOverviewView());
                },
                child: const Text('View Categories'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                  textStyle: const TextStyle(fontSize: 18.0),
                ),
              ),
              _buildTransactionSection(context, 'Expenses', 'expenses'),
              _buildTransactionSection(context, 'Incomes', 'incomes'),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCard(
      {required String title, required double value, required Color color}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing: Text(
          '\Rs${value.toStringAsFixed(2)}',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: color),
        ),
      ),
    );
  }

  Widget _buildMonthSelector(AccountController controller) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: const Text(
          'Select Month',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing: DropdownButton<String>(
          value: controller.selectedMonth.value,
          onChanged: (String? newValue) {
            if (newValue != null) {
              controller.changeMonth(newValue);
            }
          },
          items:
              controller.months.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHostelBillsList(AccountController controller) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: controller.hostelBills.entries
          .map((entry) => Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(
                    '${entry.key} Rent for ${controller.selectedMonth.value}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  trailing: Text(
                    '\Rs${entry.value.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildTransactionSection(
      BuildContext context, String title, String type) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      children: [
        _buildTransactionCategory(context, type, 'Personal'),
        _buildTransactionCategory(context, type, 'Hostel'),
      ],
    );
  }

  Widget _buildTransactionCategory(
      BuildContext context, String type, String categoryType) {
    return ExpansionTile(
      title: Text(
        '$categoryType $type',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      children: [
        Obx(() {
          DateTime selectedMonthDate = DateFormat('MMMM yyyy')
              .parse(Get.find<AccountController>().selectedMonth.value);
          DateTime startOfMonth =
              DateTime(selectedMonthDate.year, selectedMonthDate.month, 1);
          DateTime endOfMonth =
              DateTime(selectedMonthDate.year, selectedMonthDate.month + 1, 0);

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid ?? '')
                .collection(type)
                .doc(categoryType)
                .collection('data')
                .where('date',
                    isGreaterThanOrEqualTo: startOfMonth,
                    isLessThanOrEqualTo: endOfMonth)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Card(
                  child: ListTile(
                    title: Text(
                        'No $type for $categoryType in ${Get.find<AccountController>().selectedMonth.value}'),
                  ),
                );
              }
              return Column(
                children: snapshot.data!.docs.map((doc) {
                  DateTime date = (doc['date'] as Timestamp).toDate();
                  String formattedDate = DateFormat('dd MMM yyyy').format(date);
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        '$type: \Rs${doc['amount']}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        '${doc['category']} - ${doc['description']} - $formattedDate',
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _showDeleteDialog(
                            context,
                            Get.find<AccountController>(),
                            '$type/$categoryType/data',
                            doc.id),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          );
        }),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, AccountController controller,
      String path, String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
              const Text('Are you sure you want to delete this transaction?'),
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
                controller.deleteTransaction(path, docId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class CategoriesOverviewView extends GetView<AccountController> {
  const CategoriesOverviewView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories Overview'),
      ),
      body: GetBuilder<AccountController>(
        init: AccountController(),
        builder: (controller) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: ['Hostel', 'Personal'].map((categoryType) {
                  return ExpansionTile(
                    title: Text(
                      categoryType,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    children: controller.categories.map((category) {
                      return ExpansionTile(
                        title: Text(
                          category,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        children: [
                          _buildCategoryTotals(
                              controller, categoryType, category),
                          _buildCategoryTransactions(
                              controller, categoryType, category),
                        ],
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryTotals(
      AccountController controller, String categoryType, String category) {
    print(
        'Fetching totals for categoryType: $categoryType, category: $category'); // Debug statement

    Future<double> _fetchTotal(String type) async {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid ?? '')
          .collection(type)
          .doc(categoryType)
          .collection('data')
          .where('category', isEqualTo: category)
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        total += (doc['amount'] as num).toDouble();
      }
      return total;
    }

    return FutureBuilder(
      future: Future.wait([_fetchTotal('expenses'), _fetchTotal('incomes')]),
      builder: (context, AsyncSnapshot<List<double>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!snapshot.hasData) {
          return const ListTile(
            title: Text('No transactions found'),
          );
        }
        double totalExpenses = snapshot.data![0];
        double totalIncomes = snapshot.data![1];

        return ListTile(
          title: Text(
            'Totals for $category',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Expenses: \Rs$totalExpenses',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'Total Incomes: \Rs$totalIncomes',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryTransactions(
      AccountController controller, String categoryType, String category) {
    print(
        'Fetching transactions for categoryType: $categoryType, category: $category'); // Debug statement
    DateTime selectedMonthDate =
        DateFormat('MMMM yyyy').parse(controller.selectedMonth.value);
    DateTime startOfMonth =
        DateTime(selectedMonthDate.year, selectedMonthDate.month, 1);
    DateTime endOfMonth =
        DateTime(selectedMonthDate.year, selectedMonthDate.month + 1, 0);

    return Column(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid ?? '')
              .collection('expenses')
              .doc(categoryType)
              .collection('data')
              .where('category', isEqualTo: category)
              .where('date', isGreaterThanOrEqualTo: startOfMonth)
              .where('date', isLessThanOrEqualTo: endOfMonth)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Card(
                child: ListTile(
                  title: Text(
                      'No expenses for $category in ${controller.selectedMonth.value}'),
                ),
              );
            }
            return Column(
              children: snapshot.data!.docs.map((doc) {
                DateTime date = (doc['date'] as Timestamp).toDate();
                String formattedDate = DateFormat('dd MMM yyyy').format(date);
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      '${doc['amount']} - $formattedDate',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      '${doc['description']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteDialog(context, controller,
                          'expenses/${categoryType}/data', doc.id),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid ?? '')
              .collection('incomes')
              .doc(categoryType)
              .collection('data')
              .where('category', isEqualTo: category)
              .where('date', isGreaterThanOrEqualTo: startOfMonth)
              .where('date', isLessThanOrEqualTo: endOfMonth)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Card(
                child: ListTile(
                  title: Text(
                      'No incomes for $category in ${controller.selectedMonth.value}'),
                ),
              );
            }
            return Column(
              children: snapshot.data!.docs.map((doc) {
                DateTime date = (doc['date'] as Timestamp).toDate();
                String formattedDate = DateFormat('dd MMM yyyy').format(date);
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      '${doc['amount']} - $formattedDate',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      '${doc['description']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteDialog(context, controller,
                          'incomes/${categoryType}/data', doc.id),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, AccountController controller,
      String path, String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
              const Text('Are you sure you want to delete this transaction?'),
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
                controller.deleteTransaction(path, docId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
