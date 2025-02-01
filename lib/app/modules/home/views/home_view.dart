import 'package:auto_size_text/auto_size_text.dart';
import 'package:secondfyp/app/modules/home/controllers/home_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secondfyp/app/modules/home/views/add_hostel_button_view.dart';
import 'package:secondfyp/app/modules/home/views/occupancy_card_view.dart';
import 'package:secondfyp/app/modules/home/views/parcel_card_view.dart';
import 'package:secondfyp/app/modules/home/views/rent_card.dart';
import 'package:secondfyp/app/modules/home/views/resident_card_view.dart';
import 'package:secondfyp/app/modules/home/views/rent_card_view.dart';
import 'package:secondfyp/app/modules/home/views/userheader_view.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            UserheaderView(),
            HostelListView(),
            Obx(() => _buildHostelDetailsView(controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildHostelDetailsView(HomeController controller) {
    return Column(
      children: [
        FutureBuilder<Occupancy?>(
          future: controller.fetchOccupancyData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              Occupancy occupancy = snapshot.data!;
              return Column(
                children: [
                  OccupancyCardView(
                    capacity: occupancy.capacity,
                    filled: occupancy.filled,
                    hostelId: controller.currentHostel.id,
                  ),
                  Obx(() => ResidentCardView(
                        total: occupancy.capacity,
                        present: controller.presentCount.value.toString(),
                        onLeave: controller.onLeaveResidents.value.toString(),
                        hostelId: controller.currentHostel.id,
                      )),
                ],
              );
            } else {
              return Text('No occupancy data available');
            }
          },
        ),
        FutureBuilder<void>(
          future: controller.calculateTotalRentForSelectedHostel(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return RentCardsView();
            }
          },
        ),
      ],
    );
  }
}

class HostelListView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Obx(() => Container(
              height: 60, // Adjusted height for better appearance
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.hostels.length +
                    1, // Include an extra item for the 'Add Hostel' button
                itemBuilder: (context, index) {
                  if (index == controller.hostels.length) {
                    // If it's the last item, return the 'Add Hostel' button
                    return AddHostelButtonView().marginAll(8);
                  } else {
                    // Return a button for each hostel
                    return Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            controller.changeTabIndex(
                                index); // Call changeTabIndex here
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            margin: EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              gradient: controller.selectedIndex.value == index
                                  ? LinearGradient(
                                      colors: [
                                        Colors.blue.shade400,
                                        Colors.blue.shade700
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : LinearGradient(
                                      colors: [
                                        Colors.grey.shade300,
                                        Colors.grey.shade400
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: controller.selectedIndex.value == index
                                  ? [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.apartment,
                                  color: controller.selectedIndex.value == index
                                      ? Colors.white
                                      : Colors.grey.shade800,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  controller.hostels[index].name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        controller.selectedIndex.value == index
                                            ? Colors.white
                                            : Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _buildEditHostelButton(context, controller, index),
                      ],
                    );
                  }
                },
              ),
            ));
      },
    );
  }

  Widget _buildEditHostelButton(
      BuildContext context, HomeController controller, int index) {
    return PopupMenuButton<String>(
      onSelected: (String result) {
        switch (result) {
          case 'delete':
            _showDeleteHostelDialog(context, controller, index);
            break;
          case 'occupancy':
            _showChangeOccupancyDialog(context, controller, index);
            break;
          case 'prices':
            _showChangePricesDialog(context, controller, index);
            break;
          case 'rooms':
            _showEditRoomsDialog(context, controller, index);
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'delete',
          child: Text('Delete Hostel'),
        ),
      ],
      icon: Icon(Icons.more_vert),
    );
  }

  void _showChangeOccupancyDialog(
      BuildContext context, HomeController controller, int index) {
    TextEditingController occupancyController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Occupancy Rate'),
          content: TextField(
            controller: occupancyController,
            decoration: const InputDecoration(labelText: 'New Occupancy Rate'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                int newCapacity = int.tryParse(occupancyController.text) ?? 0;
                controller.updateOccupancyRate(index, newCapacity);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showChangePricesDialog(
      BuildContext context, HomeController controller, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Prices'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(controller.hostels[index].prices.length, (i) {
                TextEditingController priceController = TextEditingController(
                    text: controller.hostels[index].prices[i].toString());
                return TextField(
                  controller: priceController,
                  decoration:
                      InputDecoration(labelText: 'Price for capacity ${i + 1}'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    int newPrice = int.tryParse(val) ?? 0;
                    controller.updatePrice(index, i + 1, newPrice);
                  },
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditRoomsDialog(
      BuildContext context, HomeController controller, int index) {
    TextEditingController roomNumberController = TextEditingController();
    TextEditingController roomCapacityController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Rooms'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: roomNumberController,
                decoration: const InputDecoration(labelText: 'Room Number'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: roomCapacityController,
                decoration: const InputDecoration(labelText: 'Room Capacity'),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: () {
                  int roomNumber = int.parse(roomNumberController.text);
                  int roomCapacity = int.parse(roomCapacityController.text);
                  Room newRoom =
                      Room(roomNumber: roomNumber, capacity: roomCapacity);
                  controller.addRoom(index, newRoom);
                },
                child: const Text('Add Room'),
              ),
              ElevatedButton(
                onPressed: () {
                  int roomNumber = int.parse(roomNumberController.text);
                  Room roomToRemove = Room(roomNumber: roomNumber, capacity: 0);
                  controller.removeRoom(index, roomToRemove);
                },
                child: const Text('Remove Room'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteHostelDialog(
      BuildContext context, HomeController controller, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
              'Are you sure you want to delete this hostel? This action cannot be undone.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the confirmation dialog
                _showPasswordVerificationDialog(context, controller, index);
              },
            ),
          ],
        );
      },
    );
  }

  void _showPasswordVerificationDialog(
      BuildContext context, HomeController controller, int index) {
    TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Password Verification'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Enter your password'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Verify'),
              onPressed: () async {
                String password = passwordController.text;
                bool verified = await _verifyPassword(password);
                if (verified) {
                  Navigator.of(context).pop(); // Close the password dialog
                  controller.deleteHostel(index);
                } else {
                  Get.snackbar(
                      'Error', 'Incorrect password. Please try again.');
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _verifyPassword(String password) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      UserCredential result =
          await user.reauthenticateWithCredential(credential);
      return result.user != null;
    } catch (e) {
      return false;
    }
  }
}
