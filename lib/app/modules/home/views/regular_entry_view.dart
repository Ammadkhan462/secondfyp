import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:secondfyp/app/modules/home/views/occupancy_card_view.dart';

class RegularEntryView extends GetView {
  const RegularEntryView({Key? key, required this.entry}) : super(key: key);

  final RegularEntry entry;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigation or other logic here
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 5,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Regular Entry',
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
                  _buildStatistic(context, 'Total', entry.total, Colors.orange),
                  _buildStatistic(
                      context, 'Present', entry.present, Colors.blue),
                  _buildStatistic(
                      context, 'On Leave', entry.onLeave, Colors.teal),
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

class RegularEntry {
  String total;
  String present;
  String onLeave;

  RegularEntry({
    required this.total,
    required this.present,
    required this.onLeave,
  });

  Map<String, dynamic> toMap() {
    return {
      'total': total,
      'present': present,
      'onLeave': onLeave,
    };
  }

  factory RegularEntry.fromMap(Map<String, dynamic> map) {
    return RegularEntry(
      total: map['total']?.toString() ?? '0',
      present: map['present']?.toString() ?? '0',
      onLeave: map['onLeave']?.toString() ?? '0',
    );
  }

  factory RegularEntry.fromOccupancy(Occupancy occupancy) {
    return RegularEntry(
      total: occupancy.filled,
      present: '0', // You can update this with actual data if available
      onLeave: '0', // You can update this with actual data if available
    );
  }
}
