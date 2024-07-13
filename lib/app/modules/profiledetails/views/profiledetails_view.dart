import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secondfyp/app/routes/app_pages.dart';
import '../controllers/profiledetails_controller.dart';

class ProfiledetailsView extends GetView<ProfiledetailsController> {
  const ProfiledetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Information'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Obx(() {
                  if (controller.isImageUploading.value) {
                    return CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.shade200,
                      child: CircularProgressIndicator(
                        color: Colors.grey.shade800,
                      ),
                    );
                  } else if (controller.userData['imageUrl'] != null &&
                      controller.userData['imageUrl'].isNotEmpty) {
                    return CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          NetworkImage(controller.userData['imageUrl']),
                    );
                  } else {
                    return GestureDetector(
                      onTap: () => controller.pickProfileImage(),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey.shade200,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    );
                  }
                }),
                title: Text(
                  '${controller.userData['firstName']} ${controller.userData['lastName']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Primary'),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    // Navigate to edit profile screen
                  },
                ),
              ),
              Divider(),
              _buildInfoItem('Email', controller.userData['email'] ?? '',
                  Icons.email, () {}),
              SizedBox(height: 20),
              _buildInfoItem('Expiration date', '21/09/2023'),
              _buildInfoItem('Last login', '28/06/2024 22:22:35'),
              _buildInfoItem('Created time', '06/09/2023 03:18:06'),
              _buildInfoItem('Resident Data', '', Icons.people, () {
                Get.toNamed(Routes.RESIDENTDATALIST);
              }),
              Spacer(),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await controller.logout();
                  },
                  icon: Icon(Icons.logout, color: Colors.white),
                  label: Text('Logout', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red, // Background color
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value,
      [IconData? icon, Function()? onTap]) {
    return Expanded(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: icon != null ? Icon(icon, color: Colors.grey) : null,
        title: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        subtitle: Text(value),
        trailing: onTap != null
            ? IconButton(
                icon: Icon(Icons.edit, color: Colors.grey), onPressed: onTap)
            : null,
      ),
    );
  }
}
