// import 'package:flutter/material.dart';

// import 'package:get/get.dart';

// class RentCardView extends GetView {
//    final String estimatedBill;
//   final String currentBill;
//   RentCardView({required this.estimatedBill, required this.currentBill});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 5,
//       margin: EdgeInsets.all(16),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Rent',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18,
//                 // Adjust the color to match your theme
//               ),
//             ),
//             SizedBox(height: 16), // Adjust spacing as needed
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Estimated Monthly Bill',
//                         style: TextStyle(fontSize: 14, color: Colors.grey),
//                       ),
//                       Text(
//                         '(All units occupied)',
//                         style: TextStyle(fontSize: 12, color: Colors.grey),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         '\$${estimatedBill}',
//                         style: TextStyle(
//                           color: Colors.green,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Estimated Monthly Bill',
//                         style: TextStyle(fontSize: 14, color: Colors.grey),
//                       ),
//                       Text(
//                         '(Current occupancy)',
//                         style: TextStyle(fontSize: 12, color: Colors.grey),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         '\$ ${currentBill}',
//                         style: TextStyle(
//                           color: Colors.orange,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Total Current',
//                         style: TextStyle(fontSize: 14, color: Colors.grey),
//                       ),
//                       Text(
//                         'Monthly Bill',
//                         style: TextStyle(fontSize: 14, color: Colors.grey),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         '\$0',
//                         style: TextStyle(
//                           color: Colors.red,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             Align(
//               alignment: Alignment.centerRight,
//               child: TextButton(
//                 onPressed: () {
//                   // Action for "See more"
//                 },
//                 child: Text(
//                   'See more',
//                   style: TextStyle(
//                     color: Colors.blue, // Adjust the color to match your theme
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
