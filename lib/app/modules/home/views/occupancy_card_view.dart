import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secondfyp/app/modules/home/controllers/home_controller.dart';

class OccupancyCardView extends StatelessWidget {
  final String capacity;
  final String filled;
  final String hostelId;

  OccupancyCardView({
    required this.capacity,
    required this.filled,
    required this.hostelId,
  });

  @override
  Widget build(BuildContext context) {
    HomeController controller = Get.find<HomeController>();
    double capacityValue = double.tryParse(capacity) ?? 0;
    double filledValue = double.tryParse(filled) ?? 0;
    double fillPercentage = 0;

    if (capacityValue > 0) {
      fillPercentage = (filledValue / capacityValue) * 100;
    }

    return InkWell(
      onTap: () => controller.navigateToAccupancyDetails(hostelId),
      child: Card(
        elevation: 8,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.blue.shade300, Colors.blue.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Occupancy',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white)),
                  Icon(Icons.people, color: Colors.white70),
                ],
              ),
              SizedBox(height: 8),
              Text('Capacity: $capacity',
                  style: TextStyle(color: Colors.white70)),
              Text('Filled: $filled', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 16),
              LinearProgressIndicator(
                value: fillPercentage / 100,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 20,
              ),
              SizedBox(height: 8),
              Text('Utilization: ${fillPercentage.toStringAsFixed(2)}%',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class Occupancy {
  final String capacity;
  final String filled;

  Occupancy({required this.capacity, required this.filled});

  factory Occupancy.fromMap(Map<String, dynamic> data) {
    return Occupancy(
      capacity: data['capacity']?.toString() ?? '0',
      filled: data['filled']?.toString() ?? '0',
    );
  }
}
