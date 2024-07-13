import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:secondfyp/app/modules/DashBoard/controllers/dash_board_controller.dart';
import 'package:secondfyp/app/routes/app_pages.dart';

import '../controllers/custom_app_bar_controller.dart';

class CustomAppBarView extends GetView<DashBoardController>
    implements PreferredSizeWidget {
  final String screenTitle;

  CustomAppBarView({Key? key, required this.screenTitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashBoardController>(
        init: DashBoardController(),
        builder: (_) {
          return AppBar(
            title: Obx(() => Text(_.appBarTitles[_.selectedIndex.value])),
            flexibleSpace: Image.asset(
              'assets/ammad.jpeg',
              fit: BoxFit.cover,
            ),
            backgroundColor: Colors.transparent,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.notification_important),
                onPressed: () {
                  Get.toNamed(Routes.NOTIFICATION);
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                margin: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(150),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 48.0);
}
