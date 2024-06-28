import 'package:flutter/material.dart';

class RentCardsView extends StatelessWidget {
  final String estimatedFullOccupancyBill;
  final String estimatedCurrentOccupancyBill;
  final String totalCurrentBill;

  const RentCardsView({
    required this.estimatedFullOccupancyBill,
    required this.estimatedCurrentOccupancyBill,
    required this.totalCurrentBill,
  });

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rent',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRentInfo('Estimated Monthly Bill (All units occupied)',
                    estimatedFullOccupancyBill, Colors.green),
                _buildRentInfo('Estimated Monthly Bill (Current occupancy)',
                    estimatedCurrentOccupancyBill, Colors.orange),
                _buildRentInfo(
                    'Total Current Monthly Bill', totalCurrentBill, Colors.red),
              ],
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  // Navigate to more details or perform some action
                },
                child: Text('See more'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRentInfo(String label, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            width: 80, child: Text(label, style: TextStyle(fontSize: 14))),
        SizedBox(height: 4),
        Text('\Rs$amount',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
