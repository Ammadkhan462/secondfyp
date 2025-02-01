import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secondfyp/app/modules/profiledetails/controllers/profiledetails_controller.dart';
import 'package:secondfyp/app/routes/app_pages.dart';
import 'package:secondfyp/commonwidgets/creatraweritem.dart';

class DrawerView extends StatelessWidget {
  const DrawerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the ProfiledetailsController
    final profileController = Get.find<ProfiledetailsController>();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/hello.jpg'),
                fit: BoxFit.cover,
              ),
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade800,
                  Colors.blue.shade400,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: profileController
                              .profileImage.value.isNotEmpty
                          ? NetworkImage(profileController.profileImage.value)
                          : AssetImage('assets/ammadpic.png') as ImageProvider,
                      radius: 30,
                      backgroundColor: Colors.blue.shade100,
                    ),
                    SizedBox(height: 10),
                    // Use Obx to observe changes in the name and email
                    Obx(() {
                      final userData = profileController.userData.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userData['firstName'] ?? 'No Name Available',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            userData['email'] ?? 'No Email Available',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade100,
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          CreateDrawerItem(
            icon: Icons.account_circle,
            text: 'Profile',
            onTap: () => Get.toNamed(Routes.PROFILEDETAILS),
          ),
          CreateDrawerItem(
            icon: Icons.receipt,
            text: 'Complaint',
            onTap: () {
              Get.toNamed(Routes.COMPLAINS);
            },
          ),
        ],
      ),
    );
  }
}
