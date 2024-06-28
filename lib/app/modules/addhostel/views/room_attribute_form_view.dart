import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secondfyp/app/modules/addhostel/controllers/addhostel_controller.dart';

class RoomAttributeFormView extends GetView<AddhostelController> {
  final RoomAttributes roomAttributes;
  final VoidCallback onRemove;

  const RoomAttributeFormView({
    Key? key,
    required this.roomAttributes,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddhostelController>(
      init: AddhostelController(),
      builder: (controller) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Room No ${roomAttributes.roomNumber.toString()}'),
                DropdownButtonFormField<int>(
                  value: roomAttributes.capacity,
                  decoration: InputDecoration(
                    labelText: 'Room Capacity',
                    labelStyle: TextStyle(color: Colors.blue),
                  ),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      roomAttributes.capacity = newValue;
                      controller.update(); // Notify listeners of change
                    }
                  },
                  items: List.generate(controller.maxCapacity.value, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text('${index + 1}'),
                    );
                  }),
                ),
                SwitchListTile(
                  title: Text('Air Conditioning'),
                  value: roomAttributes.hasAC,
                  onChanged: (hasAC) => controller.toggleAC(
                      controller.rooms.indexOf(roomAttributes), hasAC),
                  activeColor: Colors.blue,
                ),
                Text('Current Occupancy: ${roomAttributes.currentOccupancy}'),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: onRemove,
                  child: Text('Remove Room'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
