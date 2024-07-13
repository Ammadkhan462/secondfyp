import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:secondfyp/commonwidgets/common_text.dart';
import 'package:secondfyp/constants/constant.dart'; 


Widget commonTextField({
  String? label,
  required String hintText,
  required TextEditingController controller,
  IconData? icon,
  double width = 325,
  bool isPassword = false,
  String? Function(String?)? validator,
  bool isDate = false,
  required BuildContext context,
  TextInputType keyboardType = TextInputType.text,
  TextAlign textAlign = TextAlign.start,
}) {
  void _selectDate(BuildContext buildContext) async {
    final DateTime? picked = await showCustomDatePicker(context);
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  String displayedHintText = isPassword ? "••••••••" : hintText;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (label != null) ...[
        CustomText(text: label).marginOnly(left: 25),
        const SizedBox(height: 8),
      ],
      Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: width,
          child: TextFormField(
            onTap: isDate ? () => _selectDate(context) : null,
            validator: validator,
            controller: controller,
            obscureText: isPassword,
            style: const TextStyle(color: AppColors.darkGrey, fontSize: 14),
            keyboardType: isDate ? TextInputType.none : keyboardType,
            textAlign: textAlign,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              hintText: displayedHintText,
              hintStyle: const TextStyle(color: AppColors.grey, fontSize: 14),
              prefixIcon: icon != null
                  ? Icon(icon, color: AppColors.grey, size: 14)
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
                borderSide: const BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
                borderSide: const BorderSide(color: AppColors.grey),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

Future<DateTime?> showCustomDatePicker(BuildContext context) async {
  DateTime selectedDate = DateTime.now();
  int selectedDay = selectedDate.day;
  int selectedMonth = selectedDate.month;
  int selectedYear = selectedDate.year;

  return showDialog<DateTime>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Date of Birth',
          textAlign: TextAlign.center,
        ),
        content: Container(
          height: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  onSelectedItemChanged: (int index) {
                    selectedDay = index + 1;
                  },
                  children: List<Widget>.generate(31, (int index) {
                    return Center(child: Text('${index + 1}'));
                  }),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  onSelectedItemChanged: (int index) {
                    selectedMonth = index + 1;
                  },
                  children: List<Widget>.generate(12, (int index) {
                    return Center(
                      child: Text(
                        DateFormat('MMMM').format(DateTime(0, index + 1)),
                      ),
                    );
                  }),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  onSelectedItemChanged: (int index) {
                    selectedYear = 1990 + index;
                  },
                  children: List<Widget>.generate(50, (int index) {
                    return Center(child: Text('${1990 + index}'));
                  }),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              selectedDate = DateTime(selectedYear, selectedMonth, selectedDay);
              Navigator.of(context).pop(selectedDate);
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
