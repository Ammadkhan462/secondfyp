import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/home_controller.dart';

class RentCardsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init:
          HomeController(), // Ensure your HomeController is initialized here if not already elsewhere
      builder: (controller) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rent Overview',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: PieChart(
                          PieChartData(
                            sections: _buildPieChartSections(controller),
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            borderData: FlBorderData(show: false),
                            pieTouchData: PieTouchData(
                              touchCallback: (pieTouchResponse) {
                                // Add touch interactions if needed
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10), // Add some spacing
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildLegend(controller),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () {
                      // Optionally implement navigation to detailed view
                      Get.toNamed('/details');
                    },
                    child: Text('See more details'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _buildPieChartSections(HomeController controller) {
    return [
      PieChartSectionData(
        color: Colors.green,
        value: controller.totalFullOccupancyBill.value,
        title:
            '${controller.totalFullOccupancyBill.value.toStringAsFixed(0)}Rs',
        radius: 50,
        titleStyle: TextStyle(
            fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: controller.totalCurrentOccupancyBill.value,
        title:
            '${controller.totalCurrentOccupancyBill.value.toStringAsFixed(0)}Rs',
        radius: 50,
        titleStyle: TextStyle(
            fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: controller.totalCurrentBill.value,
        title: '${controller.totalCurrentBill.value.toStringAsFixed(0)}Rs',
        radius: 50,
        titleStyle: TextStyle(
            fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
      ),
    ];
  }

  List<Widget> _buildLegend(HomeController controller) {
    return [
      _buildLegendItem('Full Occupancy',
          controller.totalFullOccupancyBill.value, Colors.green),
      _buildLegendItem('Current Occupancy',
          controller.totalCurrentOccupancyBill.value, Colors.orange),
      _buildLegendItem(
          'Current Bill', controller.totalCurrentBill.value, Colors.red),
    ];
  }

  Widget _buildLegendItem(String title, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '$title: Rs ${value.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
