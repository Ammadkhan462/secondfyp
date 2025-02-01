import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/home_controller.dart';

class RentCardsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
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
                Card(
                  child: ListTile(
                    title: const Text('Select Month'),
                    trailing: Obx(() {
                      return DropdownButton<String>(
                        value: controller.selectedMonth.value,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            controller.selectedMonth.value = newValue;
                            controller.calculateTotalRentForSelectedMonth();
                          }
                        },
                        items: controller.months
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      );
                    }),
                  ),
                ),
                SizedBox(height: 20),
                Obx(() {
                  return Column(
                    children: controller.hostelBills.entries
                        .map((entry) => Card(
                              child: ListTile(
                                title: Text(
                                    '${entry.key} Rent for ${controller.selectedMonth.value}'),
                                trailing: Text(
                                  'Rs ${entry.value.toStringAsFixed(2)}',
                                ),
                              ),
                            ))
                        .toList(),
                  );
                }),
                SizedBox(height: 20),
                AspectRatio(
                  aspectRatio: 1.8,
                  child: Obx(() {
                    // Ensure the rent data is updated
                    final fullOccupancy =
                        controller.totalFullOccupancyBill.value;
                    final currentOccupancy =
                        controller.totalCurrentOccupancyBill.value;
                    final currentBill = controller.totalCurrentBill.value;

                    // Calculate maxY dynamically and add some padding
                    final maxY = [
                          fullOccupancy,
                          currentOccupancy,
                          currentBill,
                        ].reduce((a, b) => a > b ? a : b) +
                        1000;

                    // Determine the interval dynamically based on maxY
                    final interval = maxY / 5;

                    return LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.withOpacity(0.2),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: SideTitles(
                            showTitles: true,
                            interval: interval,
                            getTitles: (value) => '${value.toInt()}',
                            reservedSize: 50,
                          ),
                          bottomTitles: SideTitles(
                            showTitles: true,
                            getTitles: (value) {
                              switch (value.toInt()) {
                                case 0:
                                  return 'Full Rent';
                                case 1:
                                  return 'Crnt Occ Rent';
                                case 2:
                                  return 'Bill';
                                default:
                                  return '';
                              }
                            },
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                              color: const Color(0xff37434d), width: 1),
                        ),
                        minY: 0,
                        maxY: maxY,
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              FlSpot(0, fullOccupancy),
                              FlSpot(1, currentOccupancy),
                              FlSpot(2, currentBill),
                            ],
                            isCurved: true,
                            colors: [Colors.blue],
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              colors: [Colors.blue.withOpacity(0.2)],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
