import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:secondfyp/app/modules/addhostel/views/addhostel_view.dart';

class AddhostelController extends GetxController {
  var hostelName = ''.obs;
  var maxCapacity = 0.obs;
  var prices = <Map<String, int>>[].obs; // Stores prices for capacities
  var customAttributes = <List<Map<String, dynamic>>>[]
      .obs; // Stores custom attributes for each capacity
  var rooms = <RoomAttributes>[].obs;

  void removeRoom(int index) {
    rooms.removeAt(index);
    update();
  }

  void setMaxCapacity(int capacity) {
    maxCapacity.value = capacity;
    prices.clear();
    customAttributes.clear();
    for (int i = 0; i < capacity; i++) {
      prices.add({'base': 0});
      customAttributes.add([]);
    }
    update();
  }

  void setPrice(int capacity, String price) {
    prices[capacity - 1]['base'] = int.tryParse(price) ?? 0;
    update();
  }

  void addCustomAttribute(int capacityIndex) {
    int attributeId = customAttributes[capacityIndex].length + 1;
    customAttributes[capacityIndex].add({
      'id': attributeId,
      'name': '',
      'price': 0,
    });
    update();
  }

  void setCustomAttributeName(int capacityIndex, int attributeId, String name) {
    customAttributes[capacityIndex]
        .firstWhere((attr) => attr['id'] == attributeId)['name'] = name;
    update();
  }

  void setCustomAttributePrice(int capacityIndex, int attributeId, int price) {
    customAttributes[capacityIndex]
        .firstWhere((attr) => attr['id'] == attributeId)['price'] = price;
    update();
  }

  void removeCustomAttribute(int capacityIndex, int attributeId) {
    customAttributes[capacityIndex]
        .removeWhere((attr) => attr['id'] == attributeId);
    update();
  }

  void saveHostel() async {
    try {
      print("Saving hostel with name: ${hostelName.value}");

      // Create a new document with a unique ID
      DocumentReference hostelRef = FirebaseFirestore.instance
          .collection('hostels')
          .doc(); // Creates a new document with a unique ID

      // Convert customAttributes to a Map
      Map<String, Map<String, int>> attributesMap = {};
      for (int i = 0; i < customAttributes.length; i++) {
        for (var attr in customAttributes[i]) {
          String key = 'capacity_${i + 1}_attribute_${attr['name']}';
          attributesMap[key] = {'price': attr['price']};
        }
      }

      await hostelRef.set({
        'name': hostelName.value,
        'rooms': rooms.map((room) => room.toJson()).toList(),
        'prices': prices
            .map((price) => price['base'])
            .toList(), // Save the prices data
        'attributes': attributesMap, // Save custom attributes data as a Map
      });

      print('Hostel document created with ID: ${hostelRef.id}');

      Get.snackbar('Success', 'Hostel created successfully!');
      Get.to(() => HostelSuccessScreen(hostelName: hostelName.value));
    } catch (e) {
      print('Error creating hostel document: $e');
      Get.snackbar('Error', 'Failed to create new hostel: $e');
    }
  }

  void addRoom() {
    int nextRoomNumber = rooms.isNotEmpty ? rooms.last.roomNumber + 1 : 1;
    rooms.add(RoomAttributes(
        roomNumber: nextRoomNumber, capacity: 1)); // Default to 'Single'
    update(); // Update all widgets depending on this controller
  }

  var roomAttributes = RoomAttributes().obs;

  @override
  void onInit() {
    super.onInit();
  }

  void toggleAC(int roomIndex, bool value) {
    if (roomIndex < rooms.length) {
      rooms[roomIndex].hasAC = value;
      update(); // Update all widgets depending on this controller
    }
  }

  Future<void> fetchHostelData(String hostelId) async {
    try {
      DocumentSnapshot hostelDoc = await FirebaseFirestore.instance
          .collection('hostels')
          .doc(hostelId)
          .get();

      if (hostelDoc.exists) {
        hostelName.value = hostelDoc['name'];
        rooms.value = (hostelDoc['rooms'] as List)
            .map((room) => RoomAttributes.fromMap(room))
            .toList();
        print("Hostel data fetched successfully: $hostelName, Rooms: $rooms");
        update();
      } else {
        print('Hostel not found');

        Get.snackbar('Error', 'Hostel not found');
      }
    } catch (e) {
      print('Error fetching hostel data: $e');
      Get.snackbar('Error', 'Failed to fetch hostel data: $e');
    }
  }
}

class RoomAttributes {
  String roomType;
  bool hasAC;
  int capacity;
  int currentOccupancy;
  int roomNumber;

  RoomAttributes({
    this.roomType = 'Single',
    this.hasAC = false,
    this.capacity = 1,
    this.currentOccupancy = 0,
    this.roomNumber = 1,
  });

  factory RoomAttributes.fromMap(Map<String, dynamic> map) {
    return RoomAttributes(
      roomType: map['roomType'] ?? 'Unknown',
      hasAC: map['hasAC'] ?? false,
      capacity: map['capacity'] ?? 1,
      currentOccupancy: map['currentOccupancy'] ?? 0,
      roomNumber: map['roomNumber'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomType': roomType,
      'hasAC': hasAC,
      'capacity': capacity,
      'currentOccupancy': currentOccupancy,
      'roomNumber': roomNumber,
    };
  }
}
