import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secondfyp/app/modules/addhostel/views/room_attribute_form_view.dart';
import 'package:secondfyp/app/routes/app_pages.dart';
import '../controllers/addhostel_controller.dart';

class AddHostelDetailsView extends StatefulWidget {
  const AddHostelDetailsView({Key? key}) : super(key: key);

  @override
  _AddHostelDetailsViewState createState() => _AddHostelDetailsViewState();
}

class _AddHostelDetailsViewState extends State<AddHostelDetailsView> {
  final controller = Get.put(AddhostelController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter Hostel Details"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blue.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Hostel Name',
                  labelStyle: TextStyle(color: Colors.blue.shade700),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.blue.shade200, width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onChanged: (val) => controller.hostelName.value = val,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Maximum Room Capacity',
                  labelStyle: TextStyle(color: Colors.blue.shade700),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.blue.shade200, width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  int capacity = int.tryParse(val) ?? 0;
                  controller.setMaxCapacity(capacity);
                },
              ),
              const SizedBox(height: 20),
              Obx(() {
                return Column(
                  children:
                      List.generate(controller.maxCapacity.value, (index) {
                    return Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Base Price for capacity ${index + 1}',
                            labelStyle: TextStyle(color: Colors.blue.shade700),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.blue, width: 2.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.blue.shade200, width: 2.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            controller.setPrice(index + 1, val);
                          },
                        ),
                        const SizedBox(height: 10),
                        Obx(() {
                          return Column(
                            children: controller.customAttributes[index]
                                .map((attribute) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: attribute['name'],
                                        decoration: InputDecoration(
                                          labelText: 'Attribute Name',
                                          labelStyle: TextStyle(
                                              color: Colors.blue.shade700),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.blue, width: 2.0),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.blue.shade200,
                                                width: 2.0),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                        onChanged: (val) {
                                          controller.setCustomAttributeName(
                                              index, attribute['id'], val);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextFormField(
                                        initialValue:
                                            attribute['price'].toString(),
                                        decoration: InputDecoration(
                                          labelText: 'Price',
                                          labelStyle: TextStyle(
                                              color: Colors.blue.shade700),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.blue, width: 2.0),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.blue.shade200,
                                                width: 2.0),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged: (val) {
                                          controller.setCustomAttributePrice(
                                              index,
                                              attribute['id'],
                                              int.tryParse(val) ?? 0);
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle,
                                          color: Colors.red),
                                      onPressed: () =>
                                          controller.removeCustomAttribute(
                                              index, attribute['id']),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        }),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => setState(() {
                            controller.addCustomAttribute(index);
                          }),
                          child: const Text('Add Attribute'),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }),
                );
              }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Get.to(const AddhostelView()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Proceed to Add Rooms'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HostelSuccessScreen extends StatelessWidget {
  final String hostelName;

  HostelSuccessScreen({Key? key, required this.hostelName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Success"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline,
                size: 100, color: Colors.green),
            Text(
              'Hostel "$hostelName" Created Successfully!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: () => Get.toNamed(Routes.DASH_BOARD),
              child: const Text('Back to Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddhostelView extends GetView<AddhostelController> {
  const AddhostelView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddhostelController());

    return GetBuilder<AddhostelController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Add Rooms"),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blue.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => controller.addRoom(),
            ),
          ),
          body: SingleChildScrollView(
            child: Form(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Obx(() {
                      return Column(
                        children: controller.rooms
                            .map((room) => RoomAttributeFormView(
                                  roomAttributes: room,
                                  onRemove: () => controller.removeRoom(
                                      controller.rooms.indexOf(room)),
                                ))
                            .toList(),
                      );
                    }),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: controller.saveHostel,
                      child: const Text('Save Hostel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
