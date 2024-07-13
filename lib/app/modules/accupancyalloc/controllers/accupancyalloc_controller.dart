import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:secondfyp/app/modules/home/controllers/home_controller.dart';
import '../controllers/accupancyalloc_controller.dart';

class AccupancyallocController extends GetxController {
  var hostelDetails = HostelAttributes(name: '', rooms: []).obs;
  var hostelId = ''.obs; // Using RxString for reactive updates
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    hostelId.value =
        Get.arguments as String; // Ensure this is a global variable
    if (hostelId.value.isEmpty) {
      Get.snackbar('Error', 'Hostel ID is missing.');
      return;
    }
    print("Hostel ID on init: ${hostelId.value}");
    fetchHostelDetails(hostelId.value);
  }

  void fetchHostelDetails(String hostelId) async {
    try {
      print('Fetching details for hostel ID: $hostelId');
      String userId = _auth.currentUser?.uid ?? '';
      var hostelData = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('hostels')
          .doc(hostelId)
          .get();

      if (hostelData.exists) {
        print('Hostel document found: ${hostelData.data()}');
        Map<String, dynamic> data = hostelData.data()!;
        List<RoomAttributes> roomsAttributes = (data['rooms'] as List)
            .map((room) => RoomAttributes.fromMap(room as Map<String, dynamic>))
            .toList();

        hostelDetails.value = HostelAttributes(
          name: data['name'] ?? '',
          rooms: roomsAttributes,
        );
      } else {
        print('Hostel document not found for ID: $hostelId');
        Get.snackbar('Error', 'Hostel not found!');
      }
    } catch (e) {
      print('Error fetching hostel details: $e');
      Get.snackbar('Error', e.toString());
    }
  }
}

class HostelAttributes {
  String name;
  List<RoomAttributes> rooms;

  HostelAttributes({required this.name, required this.rooms});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'rooms': rooms.map((room) => room.toJson()).toList(),
    };
  }
}

class RoomAttributes {
  String roomType;
  bool hasAC;
  int capacity;
  int currentOccupancy;
  int roomNumber;
  List<String> residentIds;

  RoomAttributes({
    this.roomType = 'Single',
    this.hasAC = false,
    this.capacity = 1,
    this.currentOccupancy = 0,
    this.roomNumber = 1,
    this.residentIds = const [],
  });

  factory RoomAttributes.fromMap(Map<String, dynamic> map) {
    return RoomAttributes(
      roomType: map['roomType'] ?? 'Unknown',
      hasAC: map['hasAC'] ?? false,
      capacity: map['capacity'] ?? 1,
      currentOccupancy: map['currentOccupancy'] ?? 0,
      roomNumber: map['roomNumber'] ?? 1,
      residentIds: List<String>.from(map['residentIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomType': roomType,
      'hasAC': hasAC,
      'capacity': capacity,
      'currentOccupancy': currentOccupancy,
      'roomNumber': roomNumber,
      'residentIds': residentIds,
    };
  }
}

Future<void> assignResidentToRoomAndUpdateOccupancy(
    int roomNumber, String residentId, String hostelId) async {
  if (residentId.isEmpty || hostelId.isEmpty) {
    Get.snackbar('Error', 'Resident ID or Hostel ID is empty.');
    return;
  }

  String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  DocumentReference<Map<String, dynamic>> hostelRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('hostels')
      .doc(hostelId)
      .withConverter<Map<String, dynamic>>(
        fromFirestore: (snapshots, _) => snapshots.data() ?? {},
        toFirestore: (data, _) => data,
      );

  DocumentReference occupancyRef =
      hostelRef.collection('occupancy').doc('occupancyDoc');

  try {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot<Map<String, dynamic>> hostelSnapshot =
          await transaction.get(hostelRef);

      if (!hostelSnapshot.exists) {
        print('Hostel document not found: $hostelId');
        Get.snackbar('Error', 'Hostel not found.');
        return;
      }
      print('Hostel document found: ${hostelSnapshot.data()}');

      DocumentSnapshot occupancySnapshot = await transaction.get(occupancyRef);

      List<dynamic> rooms = hostelSnapshot.data()?['rooms'] ?? [];
      int roomIndex =
          rooms.indexWhere((room) => room['roomNumber'] == roomNumber);

      if (roomIndex == -1) {
        print('Room not found: $roomNumber');
        Get.snackbar('Error', 'Room not found.');
        return;
      }

      Map<String, dynamic> roomData = rooms[roomIndex];
      if (roomData['currentOccupancy'] >= roomData['capacity']) {
        Get.snackbar('Error', 'Room is at full capacity.');
        return;
      }

      List<dynamic> residentIds = roomData['residentIds'] ?? [];
      if (!residentIds.contains(residentId)) {
        residentIds.add(residentId);
        roomData['currentOccupancy']++;
        roomData['residentIds'] = residentIds; // Update to use 'residentIds'
        rooms[roomIndex] = roomData;

        transaction.update(hostelRef, {'rooms': rooms});
        print('Room data updated successfully: $roomData');

        if (occupancySnapshot.exists) {
          transaction.update(occupancyRef, {'filled': FieldValue.increment(1)});
          print('Occupancy data updated successfully.');
        } else {
          print('Occupancy document not found.');
          Get.snackbar('Error', 'Occupancy document not found.');
        }
      } else {
        Get.snackbar('Error', 'Resident already assigned to this room.');
      }
    });

    Get.snackbar('Success', 'Resident has been assigned to room $roomNumber.');
    Get.find<HomeController>().fetchOccupancyData();
  } catch (e) {
    print('Failed to assign resident: $e');
    Get.snackbar('Error', 'Failed to assign resident: $e');
  }
}
