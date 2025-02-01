import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:secondfyp/app/modules/home/views/occupancy_card_view.dart';
import 'package:secondfyp/app/modules/home/views/parcel_card_view.dart';
import 'package:secondfyp/app/modules/home/views/resident_card_view.dart';
import 'package:secondfyp/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Hostel {
  final String id;
  final String name;
  String address;
  int numberOfRooms;
  String contactNumber;
  List<int> prices;
  List<Room> rooms;

  Hostel({
    required this.id,
    required this.name,
    this.address = '',
    this.numberOfRooms = 0,
    this.contactNumber = '',
    this.prices = const [],
    this.rooms = const [],
  });

  factory Hostel.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return Hostel(
      id: doc.id,
      name: data['name'] ?? 'Unknown Hostel',
      address: data['address'] ?? '',
      numberOfRooms: data['numberOfRooms'] ?? 0,
      contactNumber: data['contactNumber'] ?? '',
      prices: List<int>.from(data['prices'] ?? []),
      rooms: (data['rooms'] as List<dynamic>?)
              ?.map((room) => Room.fromJson(room))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'numberOfRooms': numberOfRooms,
      'contactNumber': contactNumber,
      'prices': prices,
      'rooms': rooms.map((room) => room.toJson()).toList(),
    };
  }
}

class Room {
  final int roomNumber;
  final int capacity;
  final int currentOccupancy;
  final bool hasAC;
  final List<String> residentIds;
  final String roomType;

  Room({
    required this.roomNumber,
    required this.capacity,
    this.currentOccupancy = 0,
    this.hasAC = false,
    this.residentIds = const [],
    this.roomType = 'Single',
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomNumber: json['roomNumber'],
      capacity: json['capacity'],
      currentOccupancy: json['currentOccupancy'] ?? 0,
      hasAC: json['hasAC'] ?? false,
      residentIds: List<String>.from(json['residentIds'] ?? []),
      roomType: json['roomType'] ?? 'Single',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomNumber': roomNumber,
      'capacity': capacity,
      'currentOccupancy': currentOccupancy,
      'hasAC': hasAC,
      'residentIds': residentIds,
      'roomType': roomType,
    };
  }
}

class HomeController extends GetxController {
  late StreamSubscription hostelSubscription;

  var paidChallans =
      <String, List<int>>{}.obs; // Observable map to track paid challans
  var totalPaidAmounts =
      <String, double>{}.obs; // Observable map to track total paid
  var hostels = <Hostel>[].obs;
  var selectedIndex = 0.obs;
  var selectedButtonIndex = 0.obs;
  var selectedResidentTotal = 0.0.obs;
  var presentCount = 0.obs;
  var totalResidents = 0.obs;
  var onLeaveResidents = 0.obs;
  var basePrice = 0.0.obs;
  var attributePrice = 0.0.obs;
  var isLoading = false.obs; // Add isLoading observable

  var residentData =
      Rx<Map<String, dynamic>?>(null); // Add residentData observable
  final RxDouble totalFullOccupancyBill = 0.0.obs;
  final RxDouble totalCurrentOccupancyBill = 0.0.obs;
  final RxDouble totalCurrentBill = 0.0.obs;
  final RxString selectedMonth =
      DateFormat('MMMM yyyy').format(DateTime.now()).obs;
  final RxList<String> months = List.generate(12, (index) {
    DateTime now = DateTime.now();
    DateTime month = DateTime(now.year, now.month - index, 1);
    return DateFormat('MMMM yyyy').format(month);
  }).obs;
  final RxMap<String, double> hostelBills = <String, double>{}.obs;
  var residentPreviousMonthRent = 0.0.obs;
  var residentCurrentMonthRent = 0.0.obs;
  var residentDailyRent = 0.0.obs;
  Future<void> fetchResidentDetails(String residentId) async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      DocumentSnapshot residentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('residents')
          .doc(residentId)
          .get();

      if (residentSnapshot.exists) {
        var residentData = residentSnapshot.data() as Map<String, dynamic>;
        Timestamp joinDate = residentData['selectedDate'] ?? Timestamp.now();
        int daysSpent = calculateDaysSpent(joinDate);
        residentData['daysSpent'] = daysSpent;

        this.residentData.value = residentData;
        update();
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

    int daysSpent = currentDate.difference(joinDateTime).inDays + 1;

    print(
        'Join Date: $joinDateTime, Current Date: $currentDate, Days Spent: $daysSpent');

    return daysSpent;
  }

  void calculateResidentRent() {
    if (residentData.value != null) {
      int daysSpent = residentData.value!['daysSpent'] ?? 0;
      double discount = residentData.value!['discount'] ?? 0.0;

      // Add debugging logs
      print("Days Spent: $daysSpent, Discount: $discount");

      residentDailyRent.value = basePrice.value + attributePrice.value;

      DateTime currentDate = DateTime.now();
      DateTime joiningDate =
          (residentData.value!['selectedDate'] as Timestamp).toDate();

      // More debugging logs
      print("Joining Date: $joiningDate, Current Date: $currentDate");

      // Rest of the calculations...
    }
  }

  void fetchHostels() {
    String userId = _auth.currentUser?.uid ?? '';
    print("Fetching hostels for user: $userId"); // Add this log

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('hostels')
        .snapshots()
        .listen(
      (snapshot) {
        print("Hostels snapshot received"); // Add this log
        if (snapshot.docs.isEmpty) {
          print("No hostels found for user: $userId"); // Add this log
        }
        hostels.assignAll(
            snapshot.docs.map((doc) => Hostel.fromFirestore(doc)).toList());
        print("Fetched hostels: ${hostels.length}"); // Add this log
        update(); // Ensure the controller is updated to reflect changes in UI
      },
      onError: (error) {
        print("Error fetching hostels: $error"); // Add this log
        Get.snackbar('Error', 'Failed to fetch hostels: $error');
      },
    );
  }

  @override
  @override
  void onInit() {
    super.onInit();

    // Fetch initial data
    fetchHostels();
    calculateTotalRentForSelectedMonth();

    // Listen for changes in residentData
    ever(residentData, (data) {
      // Update UI or perform actions based on updated residentData
      print('Resident data updated: $data');
    });

    // Listen for changes in hostels collection
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    hostelSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('hostels')
        .snapshots()
        .listen((snapshot) {
      print("Hostels snapshot received"); // Log to help debugging
      hostels.assignAll(
          snapshot.docs.map((doc) => Hostel.fromFirestore(doc)).toList());
      print("Fetched hostels: ${hostels.length}");
      update(); // Ensure the controller is updated to reflect changes in UI
    });

    // Start listening for attendance changes
    listenForAttendanceChanges();
  }

  @override
  void onClose() {
    // Cancel Firestore listeners and any subscriptions
    hostelSubscription.cancel();

    // Call parent onClose to ensure any other cleanup is done
    super.onClose();
  }

  FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> calculateTotalRentForSelectedMonth() async {
    String userId = _auth.currentUser?.uid ?? '';
    DateTime selectedMonthDate =
        DateFormat('MMMM yyyy').parse(selectedMonth.value);
    DateTime startOfMonth =
        DateTime(selectedMonthDate.year, selectedMonthDate.month, 1);
    DateTime endOfMonth =
        DateTime(selectedMonthDate.year, selectedMonthDate.month + 1, 0);
    DateTime today = DateTime.now();

    if (today.isBefore(endOfMonth)) {
      endOfMonth = today;
    }

    try {
      QuerySnapshot hostelsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('hostels')
          .get();

      Map<String, double> calculatedHostelBills = {};

      for (var hostelDoc in hostelsSnapshot.docs) {
        var hostelData = hostelDoc.data() as Map<String, dynamic>;
        String hostelName = hostelData['name'] ?? 'Unnamed Hostel';
        double hostelBill = 0.0;

        List<dynamic> rooms = hostelData['rooms'] ?? [];
        List<dynamic> prices = hostelData['prices'] ?? [];
        Map<String, dynamic> attributes = hostelData['attributes'] ?? {};

        for (var room in rooms) {
          int capacity = room['capacity'] ?? 0;
          int roomNumber = room['roomNumber'] ?? 0;
          double pricePerRoom = prices.isNotEmpty && roomNumber <= prices.length
              ? (prices[roomNumber - 1] as num).toDouble()
              : 0.0;

          double roomAttributePrice = 0.0;
          attributes.forEach((key, value) {
            if (key.startsWith('capacity_${capacity}_attribute_')) {
              roomAttributePrice += (value['price'] as num).toDouble();
            }
          });

          if (room['residentIds'] != null) {
            for (var residentId in room['residentIds']) {
              DocumentSnapshot residentSnapshot = await FirebaseFirestore
                  .instance
                  .collection('users')
                  .doc(userId)
                  .collection('residents')
                  .doc(residentId)
                  .get();

              if (residentSnapshot.exists) {
                var residentData =
                    residentSnapshot.data() as Map<String, dynamic>;

                Timestamp joinDate;
                if (residentData['selectedDate'] is Timestamp) {
                  joinDate = residentData['selectedDate'];
                } else if (residentData['selectedDate'] is String) {
                  joinDate = Timestamp.fromDate(
                      DateTime.parse(residentData['selectedDate']));
                } else {
                  joinDate = Timestamp.now();
                }

                DateTime joinDateTime = joinDate.toDate();
                DateTime effectiveEndDate = endOfMonth;

                if (joinDateTime.isBefore(effectiveEndDate)) {
                  DateTime effectiveStartDate =
                      joinDateTime.isAfter(startOfMonth)
                          ? joinDateTime
                          : startOfMonth;

                  int daysResidentStayed =
                      effectiveEndDate.difference(effectiveStartDate).inDays +
                          1;

                  if (daysResidentStayed > 0) {
                    double dailyRate = pricePerRoom + roomAttributePrice;
                    double currentRent = dailyRate * daysResidentStayed;

                    double discount = residentData['discount'] ?? 0.0;
                    if (selectedMonthDate.month == joinDateTime.month &&
                        selectedMonthDate.year == joinDateTime.year) {
                      double advancePayment = double.tryParse(
                              residentData['advancePayment']?.toString() ??
                                  '0.0') ??
                          0.0;
                      currentRent -= advancePayment;
                    }
                    currentRent -= discount;

                    hostelBill += currentRent;
                  }
                }
              }
            }
          }
        }

        calculatedHostelBills[hostelName] = hostelBill;
      }

      hostelBills.assignAll(calculatedHostelBills);
      update();
    } catch (e) {
      print('Error calculating total rent for selected month: $e');
      Get.snackbar(
          'Error', 'Failed to calculate total rent for selected month: $e');
    }
  }

  Hostel get currentHostel => hostels.isNotEmpty
      ? hostels[selectedIndex.value]
      : Hostel(id: '', name: 'No Hostel');

  Future<void> applyDiscount(String residentId, double discountAmount) async {
    try {
      String userId = _auth.currentUser?.uid ?? '';

      // Update the discount in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('residents')
          .doc(residentId)
          .update({'discount': discountAmount});

      // Recalculate total amount for the resident
      var residentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('residents')
          .doc(residentId)
          .get();

      if (residentSnapshot.exists) {
        var residentData = residentSnapshot.data() as Map<String, dynamic>;
        Timestamp joinDate = residentData['selectedDate'] ?? Timestamp.now();
        int daysSpent = DateTime.now().difference(joinDate.toDate()).inDays;

        int roomCapacity = residentData['roomCapacity'];
        basePrice.value = double.parse(
            residentData['basePrice'][roomCapacity - 1].toString());

        // Calculate attribute prices
        attributePrice.value = 0.0;
        Map<String, dynamic> attributes = residentData['attributes'] ?? {};
        attributes.forEach((key, value) {
          if (key.startsWith('capacity_${roomCapacity}_attribute_')) {
            attributePrice.value += double.parse(value['price'].toString());
          }
        });

        double totalAmount =
            daysSpent * (basePrice.value + attributePrice.value);
        selectedResidentTotal.value =
            totalAmount - discountAmount; // Apply discount
      }
      Get.snackbar('Success', 'Discount applied successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to apply discount: $e');
    }
  }

  Future<void> fetchPaidChallans() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('residents')
        .get();

    for (var doc in snapshot.docs) {
      var residentData = doc.data();
      List<dynamic> paidChallansList = residentData['paidChallans'] ?? [];
      double totalPaid = residentData['totalPaid'] ?? 0.0;
      paidChallans[doc.id] = List<int>.from(paidChallansList);
      totalPaidAmounts[doc.id] = totalPaid;
    }
  }

  Future<void> markChallanAsPaid(String residentId, int challanIndex) async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      DocumentReference residentRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('residents')
          .doc(residentId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot residentSnapshot = await transaction.get(residentRef);

        if (residentSnapshot.exists) {
          var residentData = residentSnapshot.data() as Map<String, dynamic>;
          List<dynamic> paidChallans = residentData['paidChallans'] ?? [];

          if (!paidChallans.contains(challanIndex)) {
            paidChallans.add(challanIndex);
            transaction.update(residentRef, {'paidChallans': paidChallans});
          }
        } else {
          throw Exception('Resident not found');
        }
      });

      Get.snackbar('Success', 'Challan marked as paid successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark challan as paid: $e');
      print('Failed to mark challan as paid: $e');
    }
  }

  Future<void> deleteHostel(int index) async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      String hostelId = hostels[index].id;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('hostels')
          .doc(hostelId)
          .delete();

      hostels.removeAt(index);
      Get.snackbar('Success', 'Hostel deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete hostel: $e');
    }
  }

  Future<void> updateOccupancyRate(int index, int newCapacity) async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      String hostelId = hostels[index].id;

      hostels[index].numberOfRooms = newCapacity;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('hostels')
          .doc(hostelId)
          .update({'numberOfRooms': newCapacity});

      Get.snackbar('Success', 'Occupancy rate updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update occupancy rate: $e');
    }
  }

  Future<void> updatePrice(int index, int roomCapacity, int newPrice) async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      String hostelId = hostels[index].id;

      if (roomCapacity - 1 < hostels[index].prices.length) {
        hostels[index].prices[roomCapacity - 1] = newPrice;
      } else {
        hostels[index].prices.addAll(List.generate(
            roomCapacity - hostels[index].prices.length, (_) => 0));
        hostels[index].prices[roomCapacity - 1] = newPrice;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('hostels')
          .doc(hostelId)
          .update({'prices': hostels[index].prices});

      Get.snackbar('Success', 'Price updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update price: $e');
    }
  }

  Future<void> addRoom(int index, Room newRoom) async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      String hostelId = hostels[index].id;

      hostels[index].rooms.add(newRoom);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('hostels')
          .doc(hostelId)
          .update({
        'rooms': hostels[index].rooms.map((room) => room.toJson()).toList()
      });

      Get.snackbar('Success', 'Room added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add room: $e');
    }
  }

  Future<void> removeRoom(int index, Room roomToRemove) async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      String hostelId = hostels[index].id;

      hostels[index]
          .rooms
          .removeWhere((room) => room.roomNumber == roomToRemove.roomNumber);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('hostels')
          .doc(hostelId)
          .update({
        'rooms': hostels[index].rooms.map((room) => room.toJson()).toList()
      });

      Get.snackbar('Success', 'Room removed successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove room: $e');
    }
  }

  int daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  // Updated fetchAndCalculateTotalAmount method
  Future<void> fetchAndCalculateTotalAmount(
      String residentId, String hostelId, String roomNumber) async {
    isLoading(true); // Start loading
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
        isLoading(false); // Stop loading
        return;
      }

      var hostelData = hostelSnapshot.data() as Map<String, dynamic>;
      List<dynamic> rooms = hostelData['rooms'];
      Map<String, dynamic>? room = rooms.firstWhere(
          (r) => r['roomNumber'].toString() == roomNumber,
          orElse: () => null);

      if (room == null) {
        print('Room not found for room number: $roomNumber');
        isLoading(false); // Stop loading
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
        isLoading(false); // Stop loading
        return;
      }

      var residentData = residentSnapshot.data() as Map<String, dynamic>;
      Timestamp joinDate = residentData['selectedDate'] ?? Timestamp.now();
      DateTime joinDateTime = joinDate.toDate();
      DateTime currentDate = DateTime.now();

      int daysSpent = currentDate.difference(joinDateTime).inDays + 1;

      int roomCapacity = room['capacity'];
      double perDayRent =
          double.parse(hostelData['prices'][roomCapacity - 1].toString());

      basePrice.value = perDayRent;

      attributePrice.value = 0.0;
      Map<String, dynamic> attributes = hostelData['attributes'] ?? {};
      attributes.forEach((key, value) {
        if (key.startsWith('capacity_${roomCapacity}_attribute_')) {
          attributePrice.value += double.parse(value['price'].toString());
        }
      });

      double dailyRent = perDayRent + attributePrice.value;

      // Calculate rent for the previous month
      DateTime startOfMonth = DateTime(currentDate.year, currentDate.month, 1);
      DateTime endOfLastMonth = startOfMonth.subtract(Duration(days: 1));
      DateTime startOfLastMonth =
          DateTime(endOfLastMonth.year, endOfLastMonth.month, 1);

      int daysInLastMonth = joinDateTime.isBefore(startOfLastMonth)
          ? daysInMonth(endOfLastMonth)
          : endOfLastMonth.difference(joinDateTime).inDays + 1;

      int daysInCurrentMonth = joinDateTime.isBefore(startOfMonth)
          ? currentDate.difference(startOfMonth).inDays + 1
          : currentDate.difference(joinDateTime).inDays + 1;

      double previousMonthRent = daysInLastMonth * dailyRent;
      double currentMonthRent = daysInCurrentMonth * dailyRent;

      // Calculate total amount
      double totalRent =
          (daysSpent * dailyRent) - (residentData['discount'] ?? 0.0);

      // Add advance payment only in the first month
      if (joinDateTime.year == startOfMonth.year &&
          joinDateTime.month == startOfMonth.month) {
        double advancePayment = double.tryParse(
                residentData['advancePayment']?.toString() ?? '0.0') ??
            0.0;
        totalRent += advancePayment;
      }

      selectedResidentTotal.value = totalRent;

      // Update the rents
      residentPreviousMonthRent.value = previousMonthRent;
      residentCurrentMonthRent.value = currentMonthRent;
      residentDailyRent.value = dailyRent;

      this.residentData.value = residentData; // Set the resident data
    } catch (e) {
      print('Failed to calculate total amount: $e');
    } finally {
      isLoading(false); // Stop loading
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
          return data['status'] == 'Present' && residentIds.contains(doc.id);
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
    const int daysInMonth = 30;
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
      calculateTotalRentForSelectedHostel();

      fetchParcelData();
      listenForAttendanceChanges();
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
    fetchHostels();
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
          .doc('parcelDoc');

      final docSnapshot = await parcelRef.get();

      if (docSnapshot.exists) {
        return Parcel.fromMap(docSnapshot.data()!);
      } else {
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
          'present': '0',
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
