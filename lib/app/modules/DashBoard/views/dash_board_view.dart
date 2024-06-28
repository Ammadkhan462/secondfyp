import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:secondfyp/app/modules/CustomAppBar/views/custom_app_bar_view.dart';
import 'package:secondfyp/app/modules/Drawer/views/drawer_view.dart';

import '../controllers/dash_board_controller.dart';

class DashBoardView extends GetView<DashBoardController> {
  const DashBoardView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashBoardController>(
        init: DashBoardController(),
        builder: (_) {
          return Scaffold(
              appBar: CustomAppBarView(
                screenTitle: _.appBarTitles[_.selectedIndex.value],
              ),
              drawer: DrawerView(),
              body: Obx(() => IndexedStack(
                    index: _.selectedIndex.value,
                    children: _.widgetOptions,
                  )),
              bottomNavigationBar: Obx(
                () => BottomNavigationBar(
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.add),
                      label: 'Add',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.restaurant_menu),
                      label: 'Mess Menu',
                    ),
                  ],
                  currentIndex: _.selectedIndex.value,
                  selectedItemColor: Colors.blue,
                  onTap: controller.onItemTapped,
                ),
              ));
        });
  }
}
