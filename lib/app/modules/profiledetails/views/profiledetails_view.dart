import 'package:secondfyp/commonwidgets/cachednetworkimage.dart';
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
                    return GestureDetector(
                      onTap: () => controller.pickProfileImage(),
                      child: ClipOval(
                        child: CircleAvatar(
                          radius: 30,
                          child: CachedImageWidget(
                            imageUrl: controller.userData['imageUrl'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            placeholder: Icon(Icons.person, size: 30),
                            errorWidget: Icon(Icons.error),
                          ),
                        ),
                      ),
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
                subtitle: Text('backgroundColor'),
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

              // _buildInfoItem('Expiration date', '21/09/2023'),
              // _buildInfoItem('Last login', '28/06/2024 22:22:35'),
              // _buildInfoItem('Created time', '06/09/2023 03:18:06'),
              _buildInfoItem('Resident Data',
                  'All of your Hostels resident data', Icons.people, () {
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
                    backgroundColor: Colors.red, // Background color
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

  Widget _buildInfoItem(String label, String? value,
      [IconData? icon, Function()? onTap]) {
    if (value == null) {
      // Use a Container when the subtitle is not available
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, color: Colors.grey),
            if (icon != null) SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    } else {
      // Use ListTile when the subtitle is available
      return Container(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: icon != null ? Icon(icon, color: Colors.grey) : null,
          title: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          subtitle: Text(value),
          trailing: onTap != null
              ? IconButton(
                  icon: Icon(Icons.edit, color: Colors.grey),
                  onPressed: onTap,
                )
              : null,
        ),
      );
    }
  }
}
