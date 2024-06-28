
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:secondfyp/app/modules/IDGenerator/views/i_d_generator_view.dart';
import 'package:secondfyp/app/modules/MessMenuScreen/views/mess_menu_screen_view.dart';
import 'package:secondfyp/app/modules/home/views/home_view.dart';

class DashBoardController extends GetxController {
  //TODO: Implement DashBoardController

  var selectedIndex = 0.obs; // Make it observable

  void onItemTapped(int index) {
    selectedIndex.value = index; // Update observable value
  }

  final List<Widget> widgetOptions = [
    HomeView(), // Home screen widget
    IDGeneratorView(), // Add screen widget
    MessMenuScreenView(), // Mess Menu screen widget
    // Add other widgets for navigation items here
  ];
  final List<String> appBarTitles = [
    'Dashboard',
    'Add New',
    'Mess Menu',
  ];

  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
