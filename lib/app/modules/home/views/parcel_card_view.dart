import 'package:flutter/material.dart';

import 'package:get/get.dart';

class ParcelCardView extends GetView {
  final String newParcels;

  final String delivered;
  final String disposed;
  ParcelCardView(
      {required this.newParcels,
      required this.delivered,
      required this.disposed});

  @override
  Widget build(BuildContext context) {
    return Card(
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
                Text('Parcel',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                TextButton(
                  onPressed: () {
                    // Action for "See parcels"
                  },
                  child: Text('See parcels'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatistic(context, 'New', newParcels, Colors.orange),
                _buildStatistic(context, 'Delivered', delivered, Colors.blue),
                _buildStatistic(context, 'Disposed', disposed, Colors.teal),
              ],
            ),
          ],
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

class Parcel {
  final String newParcels;
  final String delivered;
  final String disposed;

  Parcel(
      {required this.newParcels,
      required this.delivered,
      required this.disposed});

  factory Parcel.fromMap(Map<String, dynamic> data) {
    return Parcel(
      newParcels: data['newParcels']?.toString() ?? '0',
      delivered: data['delivered']?.toString() ?? '0',
      disposed: data['disposed']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'newParcels': newParcels,
      'delivered': delivered,
      'disposed': disposed,
    };
  }
}
