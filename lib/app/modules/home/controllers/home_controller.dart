import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:secondfyp/app/modules/home/views/occupancy_card_view.dart';
import 'package:secondfyp/app/modules/home/views/parcel_card_view.dart';
import 'package:secondfyp/app/modules/home/views/resident_card_view.dart';
import 'package:secondfyp/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Hostel {
  final String id;
  final String name;
  final String address;
  final int numberOfRooms;
  final String contactNumber;

  Hostel({
    required this.id,
    required this.name,
    this.address = '',
    this.numberOfRooms = 0,
    this.contactNumber = '',
  });

  factory Hostel.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return Hostel(
      id: doc.id,
      name: data['name'] ?? 'Unknown Hostel',
      address: data['address'] ?? '',
      numberOfRooms: data['numberOfRooms'] ?? 0,
      contactNumber: data['contactNumber'] ?? '',
    );
  }
}

class HomeController extends GetxController {
  var hostels = <Hostel>[].obs;
  var selectedIndex = 0.obs;
  var selectedButtonIndex = 0.obs;
  var selectedResidentTotal = 0.0.obs;
  var presentCount = 0.obs;
  var totalResidents = 0.obs;
  var onLeaveResidents = 0.obs;
  var basePrice = 0.0.obs;
  var attributePrice = 0.0.obs;
  var totalFullOccupancyBill = 0.0.obs;
  var totalCurrentOccupancyBill = 0.0.obs;
  var totalCurrentBill = 0.0.obs;

  FirebaseAuth _auth = FirebaseAuth.instance;

  Hostel get currentHostel => hostels.isNotEmpty
      ? hostels[selectedIndex.value]
      : Hostel(id: '', name: 'No Hostel');

  @override
  void onInit() {
    super.onInit();
    fetchHostels();
    listenForAttendanceChanges();
  }

  void fetchHostels() {
    String userId = _auth.currentUser?.uid ?? '';
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('hostels')
        .snapshots()
        .listen(
      (snapshot) {
        hostels.assignAll(
            snapshot.docs.map((doc) => Hostel.fromFirestore(doc)).toList());
        update(); // Ensure the controller is updated to reflect changes in UI
      },
      onError: (error) =>
          Get.snackbar('Error', 'Failed to fetch hostels: $error'),
    );
  }

  Future<void> fetchAndCalculateTotalAmount(
      String residentId, String hostelId, String roomNumber) async {
    try {
      String userId = _auth.currentUser?.uid ?? '';
      var hostelSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('hostels')
          .doc(hostelId)
          .get();

      if (!hostelSnapshot.exists) {
        print('Hostel not found');
        return;
      }

      var hostelData = hostelSnapshot.data() as Map<String, dynamic>;
      List<dynamic> rooms = hostelData['rooms'];
      Map<String, dynamic>? room = rooms.firstWhere(
          (r) => r['roomNumber'].toString() == roomNumber,
          orElse: () => null);

      if (room == null) {
        print('Room not found for room number: $roomNumber');
        return;
      }

      var residentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('residents')
          .doc(residentId)
          .get();

      if (!residentSnapshot.exists) {
        print('Resident not found for ID: $residentId');
        return;
      }

      var residentData = residentSnapshot.data() as Map<String, dynamic>;
      Timestamp joinDate = residentData['selectedDate'] ?? Timestamp.now();
      int daysSpent = DateTime.now().difference(joinDate.toDate()).inDays;

      int roomCapacity = room['capacity'];
      basePrice.value =
          double.parse(hostelData['prices'][roomCapacity - 1].toString());

      // Calculate attribute prices
      attributePrice.value = 0.0;
      Map<String, dynamic> attributes = hostelData['attributes'] ?? {};
      attributes.forEach((key, value) {
        if (key.startsWith('capacity_${roomCapacity}_attribute_')) {
          attributePrice.value += double.parse(value['price'].toString());
        }
      });

      double totalAmount = daysSpent * (basePrice.value + attributePrice.value);
      selectedResidentTotal.value =
          totalAmount; // Update the observable to reflect on UI
    } catch (e) {
      print('Failed to calculate total amount: $e');
    }
  }
Future<List<String>> fetchResidentsOfCurrentHostel() async {
    if (currentHostel.id.isEmpty) return [];
    String userId = _auth.currentUser?.uid ?? '';
    try {
      DocumentSnapshot hostelSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('hostels')
          .doc(currentHostel.id)
          .get();
      if (hostelSnapshot.exists) {
        var data = hostelSnapshot.data() as Map<String, dynamic>;
        List<dynamic> rooms = data['rooms'] ?? [];
        List<String> residentIds = [];
        for (var room in rooms) {
          List<dynamic> ids = room['residentIds'] ?? [];
          residentIds.addAll(ids.map((id) => id.toString()).toList());
        }
        totalResidents.value =
            residentIds.length; // Update total residents count
        return residentIds;
      } else {
        return [];
      }
    } catch (e) {
      print('Failed to fetch residents: $e');
      return [];
    }
  }
void listenForAttendanceChanges() async {
    String userId = _auth.currentUser?.uid ?? '';
    // Ensure the correct residents are being fetched for the current hostel
    List<String> residentIds = await fetchResidentsOfCurrentHostel();

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('hostels')
        .doc(currentHostel.id)
        .collection('attendance')
        .snapshots()
        .listen(
      (snapshot) {
        int present = snapshot.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return data['status'] == 'Present' &&
              residentIds.contains(doc.id);
        }).length;

        int onLeave =
            totalResidents.value - present; // Calculate on leave residents

        presentCount.value =
            present; // Ensure this line correctly updates the count
        onLeaveResidents.value = onLeave; // Update on leave count
      },
      onError: (error) => Get.snackbar(
          'Error', 'Failed to listen for attendance changes: $error'),
    );
  }
  Future<void> calculateTotalRentForSelectedHostel() async {
    const int daysInMonth = 30; // Assuming a month has 30 days for simplicity
    String userId = _auth.currentUser?.uid ?? '';
    try {
      totalFullOccupancyBill.value = 0.0;
      totalCurrentOccupancyBill.value = 0.0;
      totalCurrentBill.value = 0.0;

      var hostel = currentHostel;
      var hostelSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('hostels')
          .doc(hostel.id)
          .get();

      if (hostelSnapshot.exists) {
        var hostelData = hostelSnapshot.data() as Map<String, dynamic>;
        List<dynamic> rooms = hostelData['rooms'] ?? [];
        List<dynamic> prices = hostelData['prices'] ?? [];
        Map<String, dynamic> attributes = hostelData['attributes'] ?? {};

        for (var room in rooms) {
          int capacity = room['capacity'] ?? 0;
          List<dynamic> residentIds = room['residentIds'] ?? [];

          double roomBasePrice = prices.length > capacity - 1
              ? double.parse(prices[capacity - 1].toString())
              : 0.0;
          double roomAttributePrice = 0.0;

          attributes.forEach((key, value) {
            if (key.startsWith('capacity_${capacity}_attribute_')) {
              roomAttributePrice += double.parse(value['price'].toString());
            }
          });

          double monthlyBasePrice = roomBasePrice * daysInMonth;
          double monthlyAttributePrice = roomAttributePrice * daysInMonth;

          totalFullOccupancyBill.value +=
              capacity * (monthlyBasePrice + monthlyAttributePrice);
          totalCurrentOccupancyBill.value +=
              residentIds.length * (monthlyBasePrice + monthlyAttributePrice);
          totalCurrentBill.value +=
              residentIds.length * (monthlyBasePrice + monthlyAttributePrice);

          print(
              'Room $room: Base Price: $roomBasePrice, Attribute Price: $roomAttributePrice');
        }
      }
      print('Total Full Occupancy Bill: ${totalFullOccupancyBill.value}');
      print('Total Current Occupancy Bill: ${totalCurrentOccupancyBill.value}');
      print('Total Current Bill: ${totalCurrentBill.value}');
    } catch (e) {
      print('Failed to calculate total rent: $e');
    }
  }

  void changeTabIndex(int index) {
    if (index >= 0 && index < hostels.length) {
      selectedButtonIndex.value = index;
      selectedIndex.value = index;
      fetchOccupancyData();
      calculateTotalRentForSelectedHostel(); // Recalculate rent for the selected hostel

      fetchParcelData();
      listenForAttendanceChanges(); // Call this to update the attendance listener for the new hostel
    }
  }

  Future<void> refreshResidentDetails(
      String residentId, String hostelId, String roomNumber) async {
    await fetchAndCalculateTotalAmount(residentId, hostelId, roomNumber);
    await fetchResidentDetailsWithDaysSpent(residentId);
  }

  Future<Map<String, String>> calculateRentDetails() async {
    try {
      if (hostels.isEmpty) {
        return {
          'estimatedFullOccupancyBill': '0',
          'estimatedCurrentOccupancyBill': '0',
          'totalCurrentBill': '0',
        };
      }
      var selectedResidentTotal =
          0.0.obs; // To store and update the resident's total amount on UI

      // Existing initialization and hostel fetching methods remain unchanged

      // Method to fetch and calculate the total amount for a specific resident

      final currentHostelId = hostels[selectedIndex.value].id;
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('hostels')
          .doc(currentHostelId)
          .get();

      if (docSnapshot.exists) {
        var data = docSnapshot.data() as Map<String, dynamic>;
        int totalCapacity = 0;
        int totalFilled = 0;
        double totalFullOccupancyBill = 0.0;
        double totalCurrentOccupancyBill = 0.0;

        List<dynamic> rooms = data['rooms'] ?? [];
        List<dynamic> prices = data['prices'] ?? [];
        Map<String, dynamic> attributes = data['attributes'] ?? {};

        for (int i = 0; i < rooms.length; i++) {
          var room = rooms[i] as Map<String, dynamic>;
          int capacity = room['capacity'] is int
              ? room['capacity']
              : int.parse(room['capacity']);
          int currentOccupancy = room['currentOccupancy'] is int
              ? room['currentOccupancy']
              : int.parse(room['currentOccupancy']);
          int basePrice = prices[capacity - 1] is int
              ? prices[capacity - 1]
              : int.parse(prices[capacity - 1]);

          totalCapacity += capacity;
          totalFilled += currentOccupancy;

          double roomFullOccupancyBill = basePrice.toDouble() * capacity;
          double roomCurrentOccupancyBill =
              basePrice.toDouble() * currentOccupancy;

          // Add custom attribute prices
          attributes.forEach((key, value) {
            if (key.startsWith('capacity_${capacity}_attribute_')) {
              int attrPrice = value['price'] is int
                  ? value['price']
                  : int.parse(value['price']);
              roomFullOccupancyBill += attrPrice;
              if (currentOccupancy > 0) {
                roomCurrentOccupancyBill += attrPrice;
              }
            }
          });

          totalFullOccupancyBill += roomFullOccupancyBill;
          totalCurrentOccupancyBill += roomCurrentOccupancyBill;
        }

        double totalCurrentBill = totalCurrentOccupancyBill;

        return {
          'estimatedFullOccupancyBill':
              totalFullOccupancyBill.toStringAsFixed(0),
          'estimatedCurrentOccupancyBill':
              totalCurrentOccupancyBill.toStringAsFixed(0),
          'totalCurrentBill': totalCurrentBill.toStringAsFixed(0),
        };
      } else {
        return {
          'estimatedFullOccupancyBill': '0',
          'estimatedCurrentOccupancyBill': '0',
          'totalCurrentBill': '0',
        };
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to calculate rent details: $e');
      print(e);
      return {
        'estimatedFullOccupancyBill': '0',
        'estimatedCurrentOccupancyBill': '0',
        'totalCurrentBill': '0',
      };
    }
  }

  void refreshHostelData() {
    fetchHostels(); // Call this method when returning to the home screen
  }

  Future<Occupancy> fetchOccupancyData() async {
    if (hostels.isEmpty) return Occupancy(capacity: '0', filled: '0');

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('hostels')
          .doc(hostels[selectedIndex.value].id)
          .get();

      if (docSnapshot.exists) {
        var data = docSnapshot.data()!;
        int totalCapacity = 0;
        int totalFilled = 0;

        List<dynamic> rooms = data['rooms'] ?? [];
        for (var room in rooms) {
          totalCapacity += (room['capacity'] as int) ?? 0;
          totalFilled += (room['currentOccupancy'] as int) ?? 0;
        }

        var occupancy = Occupancy(
          capacity: totalCapacity.toString(),
          filled: totalFilled.toString(),
        );

        return occupancy;
      } else {
        return Occupancy(capacity: '0', filled: '0');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch occupancy data: $e');
      return Occupancy(capacity: '0', filled: '0');
    }
  }

  Future<Parcel?> fetchParcelData() async {
    if (hostels.isEmpty) {
      return Parcel(newParcels: '0', delivered: '0', disposed: '0');
    }
    try {
      final parcelRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('hostels')
          .doc(hostels[selectedIndex.value].id)
          .collection('parcels')
          .doc(
              'parcelDoc'); // Adjust this according to your actual document ID or structure

      final docSnapshot = await parcelRef.get();

      if (docSnapshot.exists) {
        return Parcel.fromMap(docSnapshot.data()!);
      } else {
        // If the document does not exist, create it with default values
        final defaultParcel =
            Parcel(newParcels: '0', delivered: '0', disposed: '0');
        await parcelRef.set(defaultParcel.toMap());
        return defaultParcel;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch parcel data: $e');
      return Parcel(newParcels: '0', delivered: '0', disposed: '0');
    }
  }

  void updateResidentData(String filled) {
// Assuming that 'filled' will become the new 'total' for Resident
    DocumentReference residentRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('hostels')
        .doc(currentHostel.id)
        .collection('residents')
        .doc('residentDoc');

    residentRef
        .update({
          'total': filled,
          'present': '0', // Reset or maintain as necessary
        })
        .then((value) => print("Resident data updated"))
        .catchError((error) => print("Failed to update resident data: $error"));
  }

  Future<Map<String, dynamic>> fetchResidentDetailsWithDaysSpent(
      String residentId) async {
    try {
      DocumentSnapshot residentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('residents')
          .doc(residentId)
          .get();
      if (residentSnapshot.exists) {
        var data = residentSnapshot.data() as Map<String, dynamic>;
        Timestamp joinDate = data['selectedDate'] ?? Timestamp.now();
        int daysSpent = calculateDaysSpent(joinDate);
        data['daysSpent'] = daysSpent;
        return data;
      } else {
        throw Exception('Resident not found');
      }
    } catch (e) {
      throw Exception('Failed to fetch resident details: $e');
    }
  }

  int calculateDaysSpent(Timestamp joinDate) {
    DateTime joinDateTime = joinDate.toDate();
    DateTime currentDate = DateTime.now();
    Duration difference = currentDate.difference(joinDateTime);
    return difference.inDays;
  }

  Future<Resident> fetchResidentData(String residentId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('residents')
          .doc(residentId)
          .get();

      return docSnapshot.exists
          ? Resident.fromMap(docSnapshot.data()!)
          : Resident(total: '0', present: '0', onLeave: '0');
    } catch (e) {
      return Future.error('Failed to fetch resident data: $e');
    }
  }

  void navigateToAccupancyDetails(String hostelId) {
    Get.toNamed(Routes.ACCUPANCYALLOC, arguments: hostelId);
  }

  Future<void> deleteResident(
      String residentId, String hostelId, String roomNumber) async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      var residentRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('residents')
          .doc(residentId);

      // Remove residentId from the room in the hostel
      var hostelRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('hostels')
          .doc(hostelId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var hostelSnapshot = await transaction.get(hostelRef);
        if (!hostelSnapshot.exists) {
          throw Exception('Hostel not found');
        }

        var hostelData = hostelSnapshot.data() as Map<String, dynamic>;
        List<dynamic> rooms = hostelData['rooms'];
        var room = rooms.firstWhere(
            (r) => r['roomNumber'].toString() == roomNumber,
            orElse: () => null);

        if (room == null) {
          throw Exception('Room not found');
        }

        List<dynamic> residentIds = room['residentIds'] ?? [];
        if (residentIds.contains(residentId)) {
          residentIds.remove(residentId);

          room['currentOccupancy'] = (room['currentOccupancy'] as int) - 1;

          transaction.update(hostelRef, {
            'rooms': rooms,
          });

          transaction.delete(residentRef);
        } else {
          throw Exception('Resident ID not found in room');
        }
      });

      Get.snackbar('Success', 'Resident deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete resident: $e');
      print('Failed to delete resident: $e');
    }
  }
}
