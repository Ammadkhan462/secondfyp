import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/accupancyalloc_controller.dart';

class AccupancyallocView extends GetView<AccupancyallocController> {
  const AccupancyallocView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Occupancy Details'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.fetchHostelDetails(controller.hostelId.value);
            },
          ),
        ],
      ),
      body: Obx(() {
        var hostel = controller.hostelDetails.value;
        if (hostel.name.isEmpty) {
          return const Center(
              child:
                  Text('No details available', style: TextStyle(fontSize: 18)));
        } else {
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Hostel Name: ${hostel.name}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: hostel.rooms.length,
                  itemBuilder: (context, index) {
                    var room = hostel.rooms[index];
                    return InkWell(
                      onTap: () {
                        print("Room number tapped: ${room.roomNumber}");
                        _showAssignResidentDialog(room.roomNumber, context,
                            controller.hostelId.value);
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        elevation: 5,
                        shadowColor: Colors.blueGrey[50],
                        child: ListTile(
                          title: Text(
                            'Room ${room.roomNumber}',
                            style: TextStyle(
                                color: Colors.blue[800],
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Capacity: ${room.capacity}',
                                  style:
                                      TextStyle(color: Colors.blueGrey[600])),
                              Text('Filled: ${room.currentOccupancy}',
                                  style:
                                      TextStyle(color: Colors.blueGrey[600])),
                              Text(
                                  'Available: ${room.capacity - room.currentOccupancy}',
                                  style: TextStyle(color: Colors.green[800])),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              room.hasAC ? Icons.ac_unit : Icons.error_outline,
                              color: room.hasAC
                                  ? Colors.blue[300]
                                  : Colors.red[300],
                            ),
                            onPressed: () {
                              // Logic to toggle AC if needed
                            },
                          ),
                          tileColor: Colors.grey[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          );
        }
      }),
    );
  }

  void _showAssignResidentDialog(
      int roomNumber, BuildContext context, String hostelId) {
    final _residentIdController = TextEditingController();
    print("Opening dialog for room number: $roomNumber");

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Assign Resident'),
          content: TextField(
            controller: _residentIdController,
            decoration: const InputDecoration(
              hintText: 'Enter Resident ID',
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Assign'),
              onPressed: () {
                String residentId = _residentIdController.text;
                if (residentId.isNotEmpty) {
                  assignResidentToRoomAndUpdateOccupancy(
                      roomNumber, residentId, hostelId);
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
