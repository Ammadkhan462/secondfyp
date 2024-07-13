import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/complains_controller.dart';
import 'package:flutter/material.dart';

class ComplainsView extends GetView<ComplainsController> {
  ComplainsView({Key? key}) : super(key: key);
  @override
  List<Map<String, String>> stats = [
    {'title': 'Success Rate', 'value': '12.33'},
    {'title': 'Total Complaints', 'value': '170.0'},
    {'title': 'Work Complete', 'value': '41.0'},
    {'title': 'Pending', 'value': '79.0'},
    {'title': 'Reopened', 'value': '24.0'},
    {'title': 'ACK. & Closed', 'value': '18.0'},
    {'title': 'Long Term', 'value': '6.0'},
    {'title': 'Rejected', 'value': '24.0'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Complains'),
          flexibleSpace: Image.asset(
            'assets/ammad.jpeg',
            fit: BoxFit.cover,
          ),
          backgroundColor: Colors.transparent,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.notification_important),
              onPressed: () {},
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95,
              margin: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(150),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                // ... other widgets ...
                GridView.builder(
                  physics:
                      NeverScrollableScrollPhysics(), // to disable GridView's scrolling
                  shrinkWrap:
                      true, // You need this to place a GridView inside a SingleChildScrollView
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: stats.length,
                  itemBuilder: (context, index) {
                    return StatCard(
                      title: stats[index]['title']!,
                      value: stats[index]['value']!,
                      onTap: () {},
                    );
                  },
                ),
              ],
            ),
          )
        ])));
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;
  const StatCard(
      {Key? key, required this.title, required this.value, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Container(
          width: (MediaQuery.of(context).size.width / 2) - 16,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;

  const Indicator({
    Key? key,
    required this.color,
    required this.text,
    this.isSquare = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
