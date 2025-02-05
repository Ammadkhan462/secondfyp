import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:secondfyp/app/modules/home/controllers/home_controller.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

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
                  // TextButton(
                  //   onPressed: () {
                  //     // Action for "Leave Requests"
                  //   },
                  //   // child: Text('Leave Requests'),
                  // ),
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
  double discount;

  Resident({
    required this.total,
    required this.present,
    required this.onLeave,
    this.discount = 0.0,
  });

  factory Resident.fromMap(Map<String, dynamic> map) {
    return Resident(
      total: map['total']?.toString() ?? '0',
      present: map['present']?.toString() ?? '0',
      onLeave: map['onLeave']?.toString() ?? '0',
      discount: (map['discount']?.toDouble() ?? 0.0),
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
        residentId, hostelId, roomNumber ?? '');
    controller.fetchResidentDetails(residentId);

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
                Get.back();
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        var residentData = controller.residentData.value;

        if (residentData == null) {
          return Center(child: Text('Resident not found'));
        }

        double discount = residentData['discount'] ?? 0.0;
        double perDayRent =
            controller.basePrice.value + controller.attributePrice.value;

        DateTime joinDate =
            (residentData['selectedDate'] as Timestamp).toDate();
        DateTime currentDate = DateTime.now();

        double advancePayment = double.tryParse(
                residentData['advancePayment']?.toString() ?? '0.0') ??
            0.0;

        int calculateDaysInMonth(DateTime date) {
          return DateTime(date.year, date.month + 1, 0).day;
        }

        // Calculate the total number of months from the joining month to the current month
        int monthsSinceJoining = (currentDate.year - joinDate.year) * 12 +
            currentDate.month -
            joinDate.month;

        // Ensure at least 1 month is calculated
        monthsSinceJoining =
            (monthsSinceJoining + 1).clamp(1, double.infinity).toInt();

        List<dynamic> paidChallans = residentData['paidChallans'] ?? [];

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildResidentInfoCard(residentData, roomNumber, perDayRent,
                  discount, advancePayment),
              SizedBox(height: 20),
              Text(
                'Challans',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ...List.generate(monthsSinceJoining, (index) {
                return _buildChallanCard(
                  context,
                  controller,
                  residentData,
                  roomDetails,
                  prices,
                  roomNumber ?? '',
                  discount,
                  advancePayment,
                  joinDate,
                  currentDate,
                  index,
                  monthsSinceJoining, // Pass the calculated value here
                  paidChallans.contains(index),
                );
              }),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _showDiscountDialog(context, controller, residentId);
                },
                child: Text('Apply Discount'),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildChallanCard(
    BuildContext context,
    HomeController controller,
    Map<String, dynamic> residentData,
    List<dynamic> roomDetails,
    List<dynamic> prices,
    String roomNumber,
    double discount,
    double advancePayment,
    DateTime joinDate,
    DateTime currentDate,
    int index,
    int monthsSinceJoining, // Add this parameter to use it in the method
    bool isPaid,
  ) {
    DateTime challanMonth = DateTime(joinDate.year, joinDate.month + index, 1);
    DateTime startDate;
    DateTime endDate;

    if (index == 0) {
      // First challan: Start from the join date in July and end at the end of July
      startDate = joinDate;
      endDate = DateTime(joinDate.year, joinDate.month + 1, 0);
    } else {
      // Subsequent challans: Start from the 1st of the month and end either at the end of the month or the current date (if it's the current month)
      startDate = DateTime(challanMonth.year, challanMonth.month, 1);
      endDate = (index == monthsSinceJoining - 1)
          ? currentDate
          : DateTime(challanMonth.year, challanMonth.month + 1, 0);
    }

    int daysInPeriod = endDate.difference(startDate).inDays + 1;
    double periodRent = daysInPeriod *
        (controller.basePrice.value + controller.attributePrice.value);

    if (index == 0 && advancePayment > 0) {
      periodRent -= advancePayment;
    }
    periodRent -= discount;

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Challan for ${DateFormat('MMMM yyyy').format(challanMonth)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Rs${periodRent.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Printing.layoutPdf(
                      onLayout: (PdfPageFormat format) async {
                        return ChallanGenerator.generateChallan(
                          residentData,
                          roomDetails,
                          prices,
                          roomNumber,
                          controller.basePrice.value,
                          controller.attributePrice.value,
                          discount,
                          advancePayment,
                          index,
                          startDate,
                          endDate,
                        ).save();
                      },
                    );
                  },
                  child: Text('Download'),
                ),
                isPaid
                    ? ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        child: Text('Paid'),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          _showPasswordDialog(
                              context, controller, residentId, index);
                        },
                        child: Text('Mark as Paid'),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResidentInfoCard(
    Map<String, dynamic> residentData,
    String? roomNumber,
    double perDayRent,
    double discount,
    double advancePayment,
  ) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              'Name',
              residentData['name']?.toString() ?? 'Unknown',
            ),
            _buildDetailRow(
              'CNIC',
              residentData['cnic']?.toString() ?? 'N/A',
            ),
            _buildDetailRow(
              'Phone Number',
              residentData['phoneNumber']?.toString() ?? 'N/A',
            ),
            _buildDetailRow(
              'Room Type',
              residentData['roomType']?.toString() ?? 'N/A',
            ),
            _buildDetailRow(
              'Joining Date',
              _formatDateString(residentData['selectedDate']),
            ),
            _buildDetailRow(
              'Room Number',
              roomNumber ?? 'N/A',
            ),
            _buildDetailRow(
              'Discount',
              discount.toString(),
            ),
            _buildDetailRow(
              'Advance Payment',
              advancePayment.toString(),
            ),
            _buildDetailRow(
              'Per Day Rent',
              'Rs${perDayRent.toStringAsFixed(2)}',
            ),
          ],
        ),
      ),
    );
  }

  int calculateDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  String _formatDateString(dynamic date) {
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

  void _showPasswordDialog(BuildContext context, HomeController controller,
      String residentId, int challanIndex) {
    TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Account Password'),
          content: TextField(
            controller: passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                _verifyPasswordAndMarkPaid(passwordController.text, controller,
                    residentId, challanIndex, context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _verifyPasswordAndMarkPaid(
      String password,
      HomeController controller,
      String residentId,
      int challanIndex,
      BuildContext context) async {
    try {
      auth.User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        auth.AuthCredential credential = auth.EmailAuthProvider.credential(
            email: user.email!, password: password);
        await user.reauthenticateWithCredential(credential);
        await controller.markChallanAsPaid(residentId, challanIndex);
        Navigator.of(context).pop();
        Get.snackbar('Success', 'Challan marked as paid');
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      Navigator.of(context).pop();
      Get.snackbar('Error', 'Failed to verify password: $e');
    }
  }

  void _showDiscountDialog(
      BuildContext context, HomeController controller, String residentId) {
    TextEditingController discountController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Apply Discount'),
          content: TextField(
            controller: discountController,
            decoration: const InputDecoration(labelText: 'Discount Amount'),
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
              child: const Text('Apply'),
              onPressed: () {
                double discountAmount =
                    double.tryParse(discountController.text) ?? 0.0;
                controller.applyDiscount(residentId, discountAmount);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
    double attributePrice,
    double discount,
    double advancePayment, // Only subtract this in the first month
    int challanIndex,
    DateTime startDate,
    DateTime endDate,
  ) {
    String name = residentData['name'] ?? 'Unknown';

    // Calculate total amount
    double totalAmount = calculateMonthlyAmount(
      basePrice,
      attributePrice,
      discount,
      challanIndex == 0
          ? advancePayment
          : 0.0, // Subtract advance payment only for the first month
      startDate,
      endDate,
    );

    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Hostel Resident Challan',
              style:
                  pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 20),
          pw.Text('Name: $name'),
          pw.Text('CNIC: ${residentData['cnic']}'),
          pw.Text('Phone Number: ${residentData['phoneNumber']}'),
          pw.Text('Room Type: ${residentData['roomType']}'),
          pw.Text(
              'Joining Date: ${formatDateString(residentData['selectedDate'])}'),
          pw.Text('Room Number: $roomNumber'),
          pw.Text('Discount: \Rs${discount.toStringAsFixed(2)}'),
          if (challanIndex == 0)
            pw.Text(
                'Advance Payment (Subtracted in First Month): \Rs${advancePayment.toStringAsFixed(2)}'),
          pw.SizedBox(height: 20),
          pw.Text(
              'Rate per Day: \Rs${basePrice.toStringAsFixed(2)} + \Rs${attributePrice.toStringAsFixed(2)} (attributes)'),
          pw.Text(
              'Total Amount for ${DateFormat('MMMM yyyy').format(startDate)}: \Rs${totalAmount.toStringAsFixed(2)}'),
          pw.SizedBox(height: 20),
          pw.Text('Please make the payment at your earliest convenience.'),
          pw.SizedBox(height: 20),
          pw.Text(
              'Challan Period: ${DateFormat('yyyy-MM-dd').format(startDate)} to ${DateFormat('yyyy-MM-dd').format(endDate)}'),
        ],
      ),
    ));
    return pdf;
  }

  static double calculateMonthlyAmount(
      double basePrice,
      double attributePrice,
      double discount,
      double advancePayment,
      DateTime startDate,
      DateTime endDate) {
    int daysInPeriod = endDate.difference(startDate).inDays + 1;
    return daysInPeriod * (basePrice + attributePrice) -
        discount -
        advancePayment;
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
