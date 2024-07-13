import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NotificationController extends GetxController {
  Future<void> sendNotification(String title, String body) async {
    final Uri url = Uri.parse('http://192.168.1.42:3000/send-notification'); // Use your server IP address

    // Fetch all FCM tokens from Firestore
    List<String> tokens = await getAllTokens();

    if (tokens.isEmpty) {
      print('No tokens available');
      return;
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'tokens': tokens,
        'title': title,
        'body': body,
      }),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.body}');
    }
  }

  Future<List<String>> getAllTokens() async {
    List<String> tokens = [];

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('residents').get();
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('fcmToken')) {
          tokens.add(data['fcmToken']);
        }
      }
    } catch (e) {
      print('Error retrieving tokens: $e');
    }

    return tokens;
  }
}