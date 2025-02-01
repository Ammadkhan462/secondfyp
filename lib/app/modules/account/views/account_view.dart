import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secondfyp/app/modules/account/views/paymentscard_view.dart';
import '../controllers/account_controller.dart';

class AccountView extends GetView<AccountController> {
  const AccountView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final newCategoryController = TextEditingController();

    return GetBuilder<AccountController>(
      init: AccountController(), // initialize your controller here
      builder: (controller) {
        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Account Management",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.to(() => PaymentscardView());
                      },
                      child: const Text('Payments'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Transaction Type",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ToggleButtons(
                      borderColor: Colors.grey,
                      fillColor: Colors.blueAccent,
                      borderWidth: 2,
                      selectedBorderColor: Colors.blueAccent,
                      selectedColor: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text("Expense"),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text("Income"),
                        ),
                      ],
                      isSelected: [
                        controller.isExpense.value,
                        !controller.isExpense.value
                      ],
                      onPressed: (int index) {
                        controller.isExpense.value = index == 0;
                        controller.update(); // Trigger a UI update
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                const Text(
                  "Add New Category",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: newCategoryController,
                  decoration: const InputDecoration(
                    labelText: 'New Category',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (newCategoryController.text.isNotEmpty) {
                      controller.addCategory(newCategoryController.text);
                      newCategoryController.clear();
                    }
                  },
                  child: const Text('Add Category'),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                const Text(
                  "Transaction Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller.amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calculate),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                GetBuilder<AccountController>(
                  builder: (_) => DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    value: controller.category.value,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.category.value = newValue;
                        controller.update(); // Update to reflect change
                      }
                    },
                    items: controller.categories
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(value),
                            if (value !=
                                'Uncategorized') // Cannot delete default category
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  controller.deleteCategory(value);
                                },
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                GetBuilder<AccountController>(
                  builder: (_) => DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                      border: OutlineInputBorder(),
                    ),
                    value: controller.paymentMethod.value,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.paymentMethod.value = newValue;
                        controller.update(); // Update to reflect change
                      }
                    },
                    items: <String>['Cash', 'Online']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                GetBuilder<AccountController>(
                  builder: (_) => DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    value: controller.categoryType.value,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.categoryType.value = newValue;
                        controller.update(); // Update to reflect change
                      }
                    },
                    items: <String>['Personal', 'Hostel']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate:
                          controller.selectedDate.value ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );

                    if (pickedDate != null &&
                        pickedDate != controller.selectedDate.value) {
                      controller.selectedDate.value = pickedDate;
                      controller.update(); // Update to reflect change
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(
                        text: controller.selectedDate.value == null
                            ? ''
                            : controller.selectedDate.value!
                                .toLocal()
                                .toString()
                                .split(' ')[0],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller.descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: controller.saveTransaction,
                  child: const Text('Save Transaction'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
