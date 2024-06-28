import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:secondfyp/app/modules/IDGenerator/idconfirm/controllers/idconfirm_controller.dart';

class IdconfirmView extends GetView<IdconfirmController> {
  final String documentId;

  IdconfirmView({Key? key, required this.documentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmation'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.copy),
            onPressed: () => _copyToClipboard(documentId),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.check_circle_outline,
                size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text(
              'Resident has been added successfully!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            SelectableText(
              'Document ID: $documentId',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.toNamed('/occupancy-detail'),
              child: Text('Go to Occupancy Details'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _copyToClipboard(documentId),
              child: Text('Copy Document ID'),
              style: ElevatedButton.styleFrom(
                primary: Colors.grey,
                onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied to Clipboard',
      'Document ID has been copied to your clipboard.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }
}
