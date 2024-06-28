import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profiledetails_controller.dart';

class ProfiledetailsView extends GetView<ProfiledetailsController> {
  const ProfiledetailsView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resident Data'),
        centerTitle: true,
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
              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      resident['name']?.substring(0, 1) ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  title: Text(
                    resident['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'CNIC: ${resident['cnic'] ?? 'Unknown'}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  trailing: Chip(
                    label: Text(
                      'Status: ${resident['status'] ?? 'Unknown'}',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: (resident['status'] == 'Present')
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              );
            },
          );
        }
      }),
    );
  }
}
