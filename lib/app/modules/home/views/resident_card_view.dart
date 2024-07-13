import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:secondfyp/app/modules/home/controllers/home_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResidentCardView extends GetView {
  final String total;
  final String present;
  final String onLeave;
  final String hostelId;

  ResidentCardView({
    required this.total,
    required this.present,
    required this.onLeave,
    required this.hostelId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: InkWell(
        onTap: () {
          Get.to(() => ResidentListView(hostelId: hostelId));
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Resident',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  TextButton(
                    onPressed: () {
                      // Action for "Leave Requests"
                    },
                    child: Text('Leave Requests'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatistic(context, 'Total', total, Colors.orange),
                  _buildStatistic(context, 'Present', present, Colors.blue),
                  _buildStatistic(context, 'On Leave', onLeave, Colors.teal),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatistic(
      BuildContext context, String label, String count, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Align(
            alignment: Alignment.center,
            child: Text(count,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 16)),
      ],
    );
  }
}

class Resident {
  String total;
  String present;
  String onLeave;

  Resident({
    required this.total,
    required this.present,
    required this.onLeave,
  });

  factory Resident.fromMap(Map<String, dynamic> map) {
    return Resident(
      total: map['total']?.toString() ?? '0',
      present: map['present']?.toString() ?? '0',
      onLeave: map['onLeave']?.toString() ?? '0',
    );
  }
}

class ResidentListView extends StatelessWidget {
  final String hostelId;

  ResidentListView({required this.hostelId});

  Future<Map<String, dynamic>> fetchResidentDetails(String residentId) async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      DocumentSnapshot residentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('residents')
          .doc(residentId)
          .get();
      if (residentSnapshot.exists) {
        return residentSnapshot.data() as Map<String, dynamic>;
      } else {
        throw Exception('Resident not found');
      }
    } catch (e) {
      throw Exception('Failed to fetch resident details: $e');
    }
  }

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    DateTime date = timestamp.toDate();
    return DateFormat.yMMMd().format(date);
  }

  int calculateDaysLeft(Timestamp? joinDate) {
    if (joinDate == null) return 0;
    DateTime joinDateTime = joinDate.toDate();
    DateTime expiryDate =
        DateTime(joinDateTime.year, joinDateTime.month + 1, joinDateTime.day);
    Duration difference = expiryDate.difference(DateTime.now());
    return difference.inDays;
  }

  Future<List<dynamic>> fetchRoomDetails(String hostelId) async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      DocumentSnapshot hostelSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('hostels')
          .doc(hostelId)
          .get();
      if (hostelSnapshot.exists) {
        var data = hostelSnapshot.data() as Map<String, dynamic>;
        return data['rooms'] as List<dynamic>? ?? [];
      } else {
        throw Exception('Hostel not found');
      }
    } catch (e) {
      throw Exception('Failed to fetch room details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Residents List'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid ?? '')
            .collection('hostels')
            .doc(hostelId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Hostel not found'));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          var rooms = data['rooms'] as List<dynamic>? ?? [];

          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              var room = rooms[index];
              var residentIds = room['residentIds'] as List<dynamic>? ?? [];
              return ExpansionTile(
                title: Text('Room ${room['roomNumber']}'),
                children: residentIds.map((residentId) {
                  return FutureBuilder<Map<String, dynamic>>(
                    future: fetchResidentDetails(residentId),
                    builder: (context, residentSnapshot) {
                      if (residentSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return ListTile(
                          title: Text('Loading...'),
                        );
                      }
                      if (residentSnapshot.hasError) {
                        return ListTile(
                          title: Text('Error: ${residentSnapshot.error}'),
                        );
                      }
                      if (!residentSnapshot.hasData) {
                        return ListTile(
                          title: Text('Resident details not found'),
                        );
                      }

                      var residentData = residentSnapshot.data!;
                      var joinDate = residentData['selectedDate'] as Timestamp?;
                      var expiryDate = joinDate != null
                          ? DateTime(
                              joinDate.toDate().year,
                              joinDate.toDate().month + 1,
                              joinDate.toDate().day)
                          : null;
                      var daysLeft = calculateDaysLeft(joinDate);

                      return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: ListTile(
                          title: Text(residentData['name'] ?? 'Unknown'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Joining Date: ${formatDate(joinDate)}'),
                              Text(
                                  'Expiry Date: ${formatDate(expiryDate != null ? Timestamp.fromDate(expiryDate) : null)}'),
                              Text('Days Left: $daysLeft days'),
                            ],
                          ),
                          onTap: () async {
                            var roomDetails = await fetchRoomDetails(hostelId);
                            var prices = await fetchPrices(hostelId);
                            var residentDetails =
                                await fetchResidentDetails(residentId);

                            Get.to(() => ResidentDetailsView(
                                residentId: residentId,
                                roomDetails: roomDetails,
                                prices: prices,
                                hostelId: hostelId, // Ensure hostelId is passed
                                roomNumber: room['roomNumber']
                                    .toString() // Ensure roomNumber is passed
                                ));
                          },
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}

class ResidentDetailsView extends StatelessWidget {
  final String residentId;
  final List<dynamic> roomDetails;
  final List<dynamic> prices;
  final String? roomNumber;
  final String hostelId;

  ResidentDetailsView({
    required this.residentId,
    required this.roomDetails,
    required this.prices,
    required this.hostelId,
    this.roomNumber,
  });

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    controller.fetchAndCalculateTotalAmount(
        residentId, hostelId, roomNumber ?? ''); // Fetch total amount
    return Scaffold(
      appBar: AppBar(
        title: Text('Resident Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              await controller.refreshResidentDetails(
                  residentId, hostelId, roomNumber ?? '');
              Get.snackbar(
                  'Refreshed', 'Resident details updated successfully.');
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              bool confirmed = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Confirm Deletion'),
                    content:
                        Text('Are you sure you want to delete this resident?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('Delete'),
                      ),
                    ],
                  );
                },
              );
              if (confirmed) {
                await controller.deleteResident(
                    residentId, hostelId, roomNumber ?? '');
                Get.back(); // Go back to the previous screen after deletion
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: controller.fetchResidentDetailsWithDaysSpent(residentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('Resident not found'));
          }

          var residentData = snapshot.data!;
          print("Resident data: $residentData"); // Debug print

          // Pass the total amount and attribute price to the challan generator
          pw.Document challan = ChallanGenerator.generateChallan(
              residentData,
              roomDetails,
              prices,
              roomNumber ?? '',
              controller.basePrice.value,
              controller.attributePrice.value);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Name', residentData['name'] ?? 'Unknown'),
                _buildDetailRow('CNIC', residentData['cnic'] ?? 'N/A'),
                _buildDetailRow(
                    'Phone Number', residentData['phoneNumber'] ?? 'N/A'),
                _buildDetailRow('Room Type', residentData['roomType'] ?? 'N/A'),
                _buildDetailRow('Joining Date',
                    formatDateString(residentData['selectedDate'])),
                _buildDetailRow(
                    'Days Spent', residentData['daysSpent'].toString()),
                _buildDetailRow('Room Number',
                    roomNumber ?? 'N/A'), // Display room number correctly
                Text(
                    'Resident Total: \Rs${controller.selectedResidentTotal.string}'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    print('Download button pressed'); // Debug statement
                    Printing.layoutPdf(
                      onLayout: (PdfPageFormat format) async {
                        print('Generating PDF'); // Debug statement
                        return challan.save();
                      },
                    );
                  },
                  child: Text('Download Challan'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String formatDateString(dynamic date) {
    if (date is Timestamp) {
      return DateFormat('yyyy-MM-dd').format(date.toDate());
    } else {
      return 'N/A';
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class ChallanGenerator {
  static pw.Document generateChallan(
      Map<String, dynamic> residentData,
      List<dynamic> roomDetails,
      List<dynamic> prices,
      String roomNumber,
      double basePrice,
      double attributePrice) {
    String name = residentData['name'] ?? 'Unknown';
    int daysSpent = residentData['daysSpent'] ?? 0;
    double totalAmount = daysSpent * (basePrice + attributePrice);

    final pdf = pw.Document();
    pdf.addPage(pw.Page(
        build: (pw.Context context) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Challan for Hostel Resident',
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 20),
                  pw.Text('Name: $name'),
                  pw.Text('CNIC: ${residentData['cnic']}'),
                  pw.Text('Phone Number: ${residentData['phoneNumber']}'),
                  pw.Text('Room Type: ${residentData['roomType']}'),
                  pw.Text(
                      'Joining Date: ${formatDateString(residentData['selectedDate'])}'),
                  pw.Text('Days Spent: $daysSpent'),
                  pw.Text('Room Number: $roomNumber'),
                  pw.SizedBox(height: 20),
                  pw.Text(
                      'Rate per Day: \$${basePrice.toStringAsFixed(2)} + \$${attributePrice.toStringAsFixed(2)} (attributes)'),
                  pw.Text('Total Amount: \$${totalAmount.toStringAsFixed(2)}'),
                  pw.SizedBox(height: 20),
                  pw.Text(
                      'Please make the payment at the earliest convenience.')
                ])));
    return pdf;
  }

  static String formatDateString(dynamic date) {
    if (date is Timestamp) {
      return DateFormat('yyyy-MM-dd').format(date.toDate());
    } else {
      return 'N/A';
    }
  }
}

Future<List<dynamic>> fetchRoomDetails(String hostelId) async {
  String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  DocumentSnapshot hostelSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('hostels')
      .doc(hostelId)
      .get();
  if (hostelSnapshot.exists) {
    var data = hostelSnapshot.data() as Map<String, dynamic>;
    print("Rooms Data: ${data['rooms']}");
    return data['rooms'] as List<dynamic>? ?? [];
  } else {
    throw Exception('Hostel not found');
  }
}

Future<List<dynamic>> fetchPrices(String hostelId) async {
  String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  DocumentSnapshot hostelSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('hostels')
      .doc(hostelId)
      .get();
  if (hostelSnapshot.exists) {
    var data = hostelSnapshot.data() as Map<String, dynamic>;
    print("Prices Data: ${data['prices']}");
    return data['prices'] as List<dynamic>;
  } else {
    throw Exception('Hostel not found');
  }
}
