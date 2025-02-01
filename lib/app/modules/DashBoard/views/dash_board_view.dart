import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secondfyp/app/modules/CustomAppBar/views/custom_app_bar_view.dart';
import 'package:secondfyp/app/modules/Drawer/views/drawer_view.dart';
import 'package:secondfyp/app/modules/IDGenerator/views/i_d_generator_view.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
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
            screenTitle: _.showIDGenerator.value
                ? "ID Generator"
                : _.appBarTitles[_.selectedIndex.value],
          ),
          drawer: DrawerView(),
          body: Obx(() => _.showIDGenerator.value
              ? IDGeneratorView()
              : IndexedStack(
                  index: _.selectedIndex.value,
                  children: _.widgetOptions,
                )),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _.toggleIDGenerator();
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.deepOrange,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: Obx(() => AnimatedBottomNavigationBar(
                icons: [
                  Icons.home,
                  Icons.restaurant_menu,
                  Icons.money_off,
                  Icons.account_circle_outlined,
                ],
                activeIndex: _.selectedIndex.value,
                gapLocation: GapLocation.center,
                notchSmoothness: NotchSmoothness.verySmoothEdge,
                leftCornerRadius: 30,
                rightCornerRadius: 30,
                onTap: (index) => _.onItemTapped(index),
                backgroundColor: Colors.blue.shade500,
                activeColor: Colors.white, // Active icon color
                inactiveColor: Colors.white70, // Inactive icon color
              )),
        );
      },
    );
  }
}
