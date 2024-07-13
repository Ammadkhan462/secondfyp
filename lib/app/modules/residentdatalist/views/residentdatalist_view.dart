import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secondfyp/app/modules/profiledetails/controllers/profiledetails_controller.dart';
class ResidentdatalistView extends GetView<ProfiledetailsController> {
  const ResidentdatalistView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resident Data'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              controller.refreshData();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.residentData.isEmpty) {
          return const Center(child: Text('No resident data available'));
        } else {
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: controller.residentData.length,
            itemBuilder: (context, index) {
              final resident = controller.residentData[index];
              return resident != null && resident.isNotEmpty
                  ? _buildResidentCard(resident)
                  : Container();
            },
          );
        }
      }),
    );
  }

  Widget _buildResidentCard(Map<String, dynamic> resident) {
    String? residentId = resident['id'] as String?;
    String? name = resident['name'] as String?;
    String? cnic = resident['cnic'] as String?;
    String? status = resident['status'] as String?;
    String? imageUrl = resident['imageUrl'] as String?;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blueAccent,
          backgroundImage: imageUrl != null && imageUrl.isNotEmpty
              ? NetworkImage(imageUrl)
              : null,
          child: imageUrl == null || imageUrl.isEmpty
              ? Text(
                  name != null && name.isNotEmpty ? name[0] : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                )
              : null,
        ),
        title: Text(
          name ?? 'No Name',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'CNIC: ${cnic ?? 'No CNIC'}',
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        trailing: Wrap(
          spacing: 12, // space between two icons
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.delete),
              color: Colors.red,
              onPressed: () {
                Get.defaultDialog(
                  title: 'Delete Resident',
                  middleText: 'Are you sure you want to delete this resident?',
                  textCancel: 'Cancel',
                  textConfirm: 'Delete',
                  confirmTextColor: Colors.white,
                  onConfirm: () {
                    controller.deleteResident(residentId!);
                    Get.back();
                  },
                );
              },
            ),
            Chip(
              label: Text(
                'Status: ${status ?? 'Unknown'}',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              backgroundColor: status == 'Present' ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}