import 'package:secondfyp/app/modules/profiledetails/views/profiledetails_view.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:secondfyp/app/modules/MessMenuScreen/views/mess_menu_screen_view.dart';
import 'package:secondfyp/app/modules/account/views/account_view.dart';
import 'package:secondfyp/app/modules/home/views/home_view.dart';

class DashBoardController extends GetxController {
  var selectedIndex = 0.obs; // Observable for tab selection
  var showIDGenerator = false.obs; // New observable to toggle IDGeneratorView

  void onItemTapped(int index) {
    selectedIndex.value = index;
    showIDGenerator.value =
        false; // Reset ID generator when navigating between tabs
  }

  void toggleIDGenerator() {
    showIDGenerator.value =
        !showIDGenerator.value; // Toggle the ID generator view
  }

  final List<Widget> widgetOptions = [
    HomeView(), // Home screen widget

    MessMenuScreenView(), // Mess Menu screen widget
    AccountView(), // Expense Manager screen widget
    ProfiledetailsView(), // Profile screen widget
  ];

  final List<String> appBarTitles = [
    'Dashboard',
    'Mess Menu',
    'Expense Manager',
    'Profile',
  ];

  @override
  void onInit() {
    super.onInit();
  }
}
