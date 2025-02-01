  import 'package:secondfyp/commonwidgets/cachednetworkimage.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
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
              icon: const Icon(Icons.refresh),
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

      return GestureDetector(
        onTap: () {
          Get.to(() => ResidentDetailView(resident: resident),
              transition: Transition.rightToLeft);
        },
        child: Card(
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
              child: ClipOval(
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? CachedImageWidget(
                        imageUrl: imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        placeholder: const Icon(Icons.person, size: 30),
                        errorWidget: const Icon(Icons.error),
                      )
                    : Text(
                        name != null && name.isNotEmpty ? name[0] : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
              ),
            ),
            title: Text(
              name ?? 'No Name',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CNIC: ${cnic ?? 'No CNIC'}',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                if (residentId != null) {
                  bool confirmDelete = await Get.dialog(
                        AlertDialog(
                          title: const Text('Delete Resident'),
                          content: const Text(
                              'Are you sure you want to delete this resident?'),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(result: false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Get.back(result: true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ) ??
                      false;

                  if (confirmDelete) {
                    await Get.find<ProfiledetailsController>()
                        .deleteResident(residentId);
                  }
                }
              },
            ),
          ),
        ),
      );
    }
  }

  class ResidentDetailView extends StatelessWidget {
    final Map<String, dynamic> resident;

    const ResidentDetailView({Key? key, required this.resident})
        : super(key: key);

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Resident Details'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              buildImageSection(resident['imageUrl'], 'Resident Image'),
              ListTile(
                title: Text(resident['name'] ?? 'No Name Available'),
                subtitle:
                    Text('CNIC: ${resident['cnic'] ?? 'No CNIC Available'}'),
              ),
              ListTile(
                title: const Text('Phone Number'),
                subtitle:
                    Text(resident['phoneNumber'] ?? 'No Phone Number Available'),
              ),
              ListTile(
                title: const Text('Room Type'),
                subtitle: Text(resident['roomType'] ?? 'No Room Type Specified'),
              ),
              ListTile(
                title: const Text('Vehicle Number'),
                subtitle: Text(resident['vehicleNumber'] ?? 'N/A'),
              ),
              buildImageSection(resident['vehicleImageUrl'], 'Vehicle Image'),
              buildImageSection(
                  resident['cnicFrontImageUrl'], 'CNIC Front Image'),
              buildImageSection(resident['cnicBackImageUrl'], 'CNIC Back Image'),
              ListTile(
                title: const Text('Resident ID'),
                subtitle: Text(resident['id'] ?? 'N/A'),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: resident['id'] ?? ''));
                    Get.snackbar('Copied', 'Resident ID copied to clipboard');
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildImageSection(String? imageUrl, String fallbackText) {
      return imageUrl != null && imageUrl.isNotEmpty
          ? Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              child: CachedImageWidget(
                imageUrl: imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: Container(
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Center(
                    child: Icon(Icons.image, size: 50, color: Colors.grey[400]),
                  ),
                ),
                errorWidget: Container(
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Center(
                    child: Icon(Icons.error, size: 50, color: Colors.red),
                  ),
                ),
              ),
            )
          : ListTile(
              leading: const Icon(Icons.image_not_supported),
              title: Text('$fallbackText not available'),
            );
    }
  }
