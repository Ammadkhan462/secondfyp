import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:secondfyp/app/routes/app_pages.dart';
import 'package:secondfyp/app/modules/profiledetails/controllers/profiledetails_controller.dart';

class UserheaderView extends StatelessWidget {
  const UserheaderView({Key? key}) : super(key: key);
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProfiledetailsController controller =
        Get.put(ProfiledetailsController());

    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.PROFILEDETAILS);
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade500],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple[200]!,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                Stack(
                  children: [
                    Obx(() {
                      if (controller.isLoading.value) {
                        return CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey.shade200,
                          child: CircularProgressIndicator(),
                        );
                      }
                      return CircleAvatar(
                        radius: 30,
                        backgroundImage: controller.userData['imageUrl'] != null
                            ? NetworkImage(controller.userData['imageUrl'])
                            : AssetImage('assets/ammadpic.png')
                                as ImageProvider,
                        child: controller.isImageUploading.value
                            ? CircularProgressIndicator(color: Colors.white)
                            : null,
                      );
                    }),
                  ],
                ),
                SizedBox(width: 20),
                Obx(() {
                  if (controller.isLoading.value) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          // Dynamic greeting
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Loading...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(), // Dynamic greeting
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        controller.userData['firstName'] ?? 'User',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white70),
              onPressed: () {
                // Action for the button
              },
            ),
          ],
        ),
      ),
    );
  }
}
