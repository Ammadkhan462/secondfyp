import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:secondfyp/app/modules/home/controllers/home_controller.dart';
import 'package:secondfyp/app/modules/home/views/add_hostel_button_view.dart';
import 'package:secondfyp/app/modules/home/views/occupancy_card_view.dart';
import 'package:secondfyp/app/modules/home/views/parcel_card_view.dart';
import 'package:secondfyp/app/modules/home/views/regular_entry_view.dart';
import 'package:secondfyp/app/modules/home/views/rent_card.dart';
import 'package:secondfyp/app/modules/home/views/rent_card_view.dart';
import 'package:secondfyp/app/modules/home/views/resident_card_view.dart';
import 'package:secondfyp/app/modules/home/views/userheader_view.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            UserheaderView(),
            HostelListView(),
            Obx(() => _buildHostelDetailsView(controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildHostelDetailsView(HomeController controller) {
    return Column(
      children: [
        FutureBuilder<Occupancy?>(
          future: controller.fetchOccupancyData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              Occupancy occupancy = snapshot.data!;
              return Column(
                children: [
                  OccupancyCardView(
                    capacity: occupancy.capacity,
                    filled: occupancy.filled,
                    hostelId: controller.currentHostel.id,
                  ),
                  RegularEntryView(
                    entry: RegularEntry.fromOccupancy(occupancy),
                  ),
                  Obx(() => ResidentCardView(
                        total: controller.totalResidents.value.toString(),
                        present: controller.presentCount.value.toString(),
                        onLeave: controller.onLeaveResidents.value.toString(),
                        hostelId: controller.currentHostel.id,
                      )),
                ],
              );
            } else {
              return Text('No occupancy data available');
            }
          },
        ),
        FutureBuilder<Map<String, dynamic>>(
          future: controller.calculateRentDetails(),
          builder: (context, rentSnapshot) {
            if (rentSnapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (rentSnapshot.hasError) {
              return Text('Error: ${rentSnapshot.error}');
            } else if (rentSnapshot.hasData) {
              var rentDetails = rentSnapshot.data!;
              return RentCardsView(
                estimatedFullOccupancyBill:
                    rentDetails['estimatedFullOccupancyBill'],
                estimatedCurrentOccupancyBill:
                    rentDetails['estimatedCurrentOccupancyBill'],
                totalCurrentBill: rentDetails['totalCurrentBill'],
              );
            } else {
              return Text('No rent data available');
            }
          },
        ),
        FutureBuilder<Parcel?>(
          future: controller.fetchParcelData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              return ParcelCardView(
                newParcels: snapshot.data!.newParcels,
                delivered: snapshot.data!.delivered,
                disposed: snapshot.data!.disposed,
              );
            } else {
              return Text('No parcel data');
            }
          },
        ),
      ],
    );
  }
}

class HostelListView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
        init: HomeController(),
        builder: (controller) {
          return Obx(() => Container(
                height: 50, // Set a fixed height for the horizontal list
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.hostels.length +
                      1, // Include an extra item for the 'Add Hostel' button
                  itemBuilder: (context, index) {
                    if (index == controller.hostels.length) {
                      // If it's the last item, return the 'Add Hostel' button
                      return AddHostelButtonView().marginAll(4);
                    } else {
                      // Return a button for each hostel
                      return Obx(() => ElevatedButton(
                            onPressed: () {
                              controller.changeTabIndex(
                                  index); // Call changeTabIndex here
                            },
                            child: AutoSizeText(
                              controller.hostels[index].name,
                              maxLines: 1,
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: controller.selectedIndex.value == index
                                  ? Colors.blue
                                  : Colors.grey,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                            ),
                          ).marginAll(5));
                    }
                  },
                ),
              ));
        });
  }
}
