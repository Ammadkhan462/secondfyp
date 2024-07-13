import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:secondfyp/app/routes/app_pages.dart';
import 'package:secondfyp/commonwidgets/creatraweritem.dart';

import '../controllers/drawer_controller.dart' as drawer;

class DrawerView extends GetView<drawer.DrawerController> {
  const DrawerView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade800,
                  Colors.blue.shade400
                ], // Shades of blue
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.6, // Adjust the opacity as needed
                    child: Image.asset(
                      'assets/hell.png', // Replace with your image path
                      fit: BoxFit.cover, // Cover the screen with the image
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/ammadpic.png'),
                      radius: 30,
                      backgroundColor:
                          Colors.blue.shade100, // Light shade for contrast
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Ammad Khan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors
                            .white, // White for contrast against the dark background
                      ),
                    ),
                    Text(
                      'ammadkhan@example.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors
                            .blue.shade100, // Light blue for a subtle contrast
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          CreateDrawerItem(
              icon: Icons.message,
              text: 'Messages',
              onTap: () => Navigator.pop(context)),
          CreateDrawerItem(
              icon: Icons.account_circle,
              text: 'Profile',
              onTap: () => Get.toNamed(Routes.PROFILEDETAILS)),
          CreateDrawerItem(
              icon: Icons.receipt,
              text: 'Complaint',
              onTap: () {
                Get.toNamed(Routes.COMPLAINS);

                // Navigator.of(context).push(
                //     MaterialPageRoute(builder: (ctx) => ComplaintsScreen()));
              }),
          CreateDrawerItem(
              icon: Icons.settings,
              text: 'Settings',
              onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}
