import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:secondfyp/app/modules/IDGenerator/controllers/i_d_generator_controller.dart';

class IDGeneratorView extends GetView<IDGeneratorController> {
  final _formKey = GlobalKey<FormState>();

  IDGeneratorView({Key? key}) : super(key: key);

  Widget _buildImagePickerSection(
      IDGeneratorController controller, String imageType, String labelText) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(labelText,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildImageSection(controller, imageType),
            SizedBox(height: 10),
            _buildPickImageButton(controller, imageType),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IDGeneratorController>(
      init: IDGeneratorController(),
      builder: (_) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'New Resident Information',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildNameField(_),
                    const SizedBox(height: 10),

                    _buildPhoneNumberField(_),
                    const SizedBox(height: 10),

                    _buildCNICField(_),
                    const SizedBox(height: 10),

                    _buildRoomTypeDropdown(_),
                    const SizedBox(height: 10),

                    _buildACSwitch(_),
                    const SizedBox(height: 10),

                    _buildPaymentSwitch(_, 'is resident pay advance?', true),
                    const SizedBox(height: 10),

                    _buildPaymentSwitch(_, 'is resident pay Security?', false),
                    const SizedBox(height: 10),

                    _buildVehicleSwitch(_),
                    const SizedBox(height: 10),

                    _buildDateSelector(context, _),
                    const SizedBox(height: 15),

                    // Image Sections
                    _buildImagePickerSection(
                        _, 'residentImage', 'Resident Image'),
                    _buildImagePickerSection(
                        _, 'cnicFrontImage', 'CNIC Front Image'),
                    _buildImagePickerSection(
                        _, 'cnicBackImage', 'CNIC Back Image'),

                    const SizedBox(height: 30),
                    _buildSubmitButton(_),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  TextFormField _buildNameField(IDGeneratorController controller) {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Name',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
      ),
      onSaved: (value) {
        controller.name.value = value ?? '';
      },
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter a name';
        }
        return null;
      },
    );
  }

  TextFormField _buildPhoneNumberField(IDGeneratorController controller) {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Phone Number',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.phone),
      ),
      keyboardType: TextInputType.phone,
      initialValue: '+92 ', // Ensure +92 is always present
      inputFormatters: [
        PhoneNumberFormatter(),
      ],
      onSaved: (value) {
        controller.phoneNumber.value = value ?? '';
      },
      validator: (value) {
        if (value!.isEmpty || value.length != 16) {
          return 'Please enter a valid phone number';
        }
        return null;
      },
    );
  }

  TextFormField _buildCNICField(IDGeneratorController controller) {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'CNIC',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.credit_card),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        CNICFormatter(),
      ],
      onSaved: (value) {
        controller.cnic.value = value ?? '';
      },
      validator: (value) {
        if (value!.isEmpty || value.length != 15) {
          return 'Please enter a valid CNIC number';
        }
        return null;
      },
    );
  }

  DropdownButtonFormField<String> _buildRoomTypeDropdown(
      IDGeneratorController controller) {
    return DropdownButtonFormField<String>(
      value: controller.roomType.value.isNotEmpty
          ? controller.roomType.value
          : null,
      items: ['Single Bed', 'Double Bed', 'Triple Bed'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) controller.roomType.value = value;
      },
      decoration: const InputDecoration(
        labelText: 'Room Type',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.bed),
      ),
    );
  }

  Obx _buildACSwitch(IDGeneratorController controller) {
    return Obx(
      () => SwitchListTile(
        title: const Text('Air Conditioning'),
        value: controller.hasAC.value,
        onChanged: (bool value) {
          controller.toggleAC(value);
        },
        secondary: Icon(
          controller.hasAC.value ? Icons.ac_unit : Icons.device_thermostat,
          color: controller.hasAC.value ? Colors.blue[800] : null,
        ),
      ),
    );
  }

  Obx _buildVehicleSwitch(IDGeneratorController controller) {
    return Obx(
      () => Column(
        children: [
          SwitchListTile(
            title: const Text('Do you have a vehicle?'),
            value: controller.hasVehicle.value,
            onChanged: (bool value) {
              controller.toggleVehicle(value);
            },
            secondary: Icon(
              controller.hasVehicle.value
                  ? Icons.directions_car
                  : Icons.car_repair,
              color: controller.hasVehicle.value ? Colors.blue[800] : null,
            ),
          ),
          if (controller.hasVehicle.value) _buildVehicleNumberField(controller),
          SizedBox(height: 10),
          if (controller.hasVehicle.value)
            _buildVehicleTypeDropdown(controller),
          SizedBox(height: 10),
          if (controller.hasVehicle.value)
            _buildImagePickerSection(
                controller, 'vehicleImage', 'Vehicle Image'),
        ],
      ),
    );
  }

  Obx _buildPaymentSwitch(
      IDGeneratorController controller, String title, bool isAdvance) {
    return Obx(() => Column(
          children: [
            SwitchListTile(
              title: Text(title),
              value: isAdvance
                  ? controller.hasadvance.value
                  : controller.hassecurity.value,
              onChanged: (bool value) {
                if (isAdvance) {
                  controller.toggleadvance(value);
                } else {
                  controller.togglesecurity(value);
                }
              },
              secondary: Icon(
                (isAdvance
                        ? controller.hasadvance.value
                        : controller.hassecurity.value)
                    ? Icons.check_circle_outline
                    : Icons.remove_circle_outline,
                color: (isAdvance
                        ? controller.hasadvance.value
                        : controller.hassecurity.value)
                    ? Colors.green[800]
                    : Colors.red[800],
              ),
            ),
            if (isAdvance
                ? controller.hasadvance.value
                : controller.hassecurity.value)
              _buildPaymentField(controller, isAdvance),
          ],
        ));
  }

  TextFormField _buildPaymentField(
      IDGeneratorController controller, bool isAdvance) {
    return TextFormField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: isAdvance ? 'Enter Advance Amount' : 'Enter Security Amount',
        border: OutlineInputBorder(),
        prefixIcon: Icon(isAdvance ? Icons.monetization_on : Icons.security),
      ),
      onSaved: (value) {
        if (isAdvance) {
          controller.setAvancepayment(value ?? '');
        } else {
          controller.setsecuritypayment(value ?? '');
        }
      },
      validator: (value) {
        if (value!.isEmpty || double.tryParse(value) == null) {
          return 'Please enter a valid amount';
        }
        return null;
      },
    );
  }

  TextFormField _buildVehicleNumberField(IDGeneratorController controller) {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Vehicle Number',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.confirmation_number),
      ),
      onSaved: (value) {
        controller.setVehicleNumber(value ?? '');
      },
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter the vehicle number';
        }
        return null;
      },
    );
  }

  DropdownButtonFormField<String> _buildVehicleTypeDropdown(
      IDGeneratorController controller) {
    return DropdownButtonFormField<String>(
      value: controller.vehicleType.value.isNotEmpty
          ? controller.vehicleType.value
          : null,
      items: [
        'Car',
        'Motorcycle',
      ].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) controller.setVehicleType(value);
      },
      decoration: const InputDecoration(
        labelText: 'Vehicle Type',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.two_wheeler),
      ),
    );
  }

  Obx _buildDateSelector(
      BuildContext context, IDGeneratorController controller) {
    return Obx(
      () => ListTile(
        title: const Text('Move-in Date'),
        subtitle: Text(
          controller.selectedDate.value == null
              ? 'No date chosen!'
              : 'Date: ${controller.selectedDate.value!.day}/${controller.selectedDate.value!.month}/${controller.selectedDate.value!.year}',
        ),
        leading: const Icon(Icons.calendar_today),
        onTap: () async {
          // Call the date picker
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: controller.selectedDate.value ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          // If a date is picked, update the controller
          if (picked != null && picked != controller.selectedDate.value) {
            controller.selectedDate.value = picked;
          }
        },
      ),
    );
  }

  Widget _buildImageSection(
      IDGeneratorController controller, String imageType) {
    Rx<File?> tempImage;
    RxString uploadedImageUrl; // Directly use RxString

    switch (imageType) {
      case 'residentImage':
        tempImage = controller.tempResidentImage;
        uploadedImageUrl = controller.imageUrl; // Directly use the RxString
        break;
      case 'cnicFrontImage':
        tempImage = controller.tempCnicFrontImage;
        uploadedImageUrl = controller.cnicFrontImageUrl; // No need for .obs
        break;
      case 'cnicBackImage':
        tempImage = controller.tempCnicBackImage;
        uploadedImageUrl = controller.cnicBackImageUrl; // No need for .obs
        break;
      case 'vehicleImage':
        tempImage = controller.tempVehicleImage;
        uploadedImageUrl = controller.vehicleImageUrl; // No need for .obs
        break;
      default:
        tempImage = Rx<File?>(null);
        uploadedImageUrl = ''.obs; // This creates a new RxString, if needed
    }

    return Obx(() => Stack(
          alignment: Alignment.topRight,
          children: [
            Column(
              children: [
                if (tempImage.value != null)
                  Image.file(tempImage.value!,
                      fit: BoxFit.cover, width: 100, height: 100),
                if (uploadedImageUrl.value.isNotEmpty)
                  Image.network(uploadedImageUrl.value,
                      fit: BoxFit.cover, width: 100, height: 100),
              ],
            ),
            if (uploadedImageUrl.value.isNotEmpty || tempImage.value != null)
              IconButton(
                icon: Icon(Icons.cancel, color: Colors.red),
                onPressed: () {
                  // Clear the selected image
                  switch (imageType) {
                    case 'residentImage':
                      controller.tempResidentImage.value = null;
                      controller.imageUrl.value = '';
                      break;
                    case 'cnicFrontImage':
                      controller.tempCnicFrontImage.value = null;
                      controller.cnicFrontImageUrl.value = '';
                      break;
                    case 'cnicBackImage':
                      controller.tempCnicBackImage.value = null;
                      controller.cnicBackImageUrl.value = '';
                      break;
                    case 'vehicleImage':
                      controller.tempVehicleImage.value = null;
                      controller.vehicleImageUrl.value = '';
                      break;
                  }
                },
              ),
          ],
        ));
  }

  Center _buildPickImageButton(
      IDGeneratorController controller, String imageType) {
    // Attributes based on imageType
    String buttonText;
    IconData buttonIcon;
    Color buttonColor;

    switch (imageType) {
      case 'residentImage':
        buttonText = 'Pick Resident Image';
        buttonIcon = Icons.image;
        buttonColor = Colors.blue;
        break;
      case 'cnicfrontImage':
        buttonText = 'Pick CNIC Front';
        buttonIcon = Icons.credit_card;
        buttonColor = Colors.green;
        break;
      case 'cnicbackImage':
        buttonText = 'Pick CNIC Back';
        buttonIcon = Icons.credit_card_outlined;
        buttonColor = Colors.red;
        break;
      case 'vehicleImage':
        buttonText = 'Pick Vehicle Image';
        buttonIcon = Icons.directions_car;
        buttonColor = Colors.purple;
        break;
      default:
        buttonText = 'Pick Image';
        buttonIcon = Icons.photo_camera;
        buttonColor = Colors.grey;
    }

    return Center(
      child: ElevatedButton.icon(
        icon: Icon(buttonIcon, color: Colors.white),
        label: Text(buttonText),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: buttonColor, // Text and icon color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        ),
        onPressed: () {
          _showImageSourceDialog(controller, imageType);
        },
      ),
    );
  }

  void _showImageSourceDialog(
      IDGeneratorController controller, String imageType) {
    Get.dialog(
      AlertDialog(
        title: Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Gallery'),
              onTap: () {
                Get.back();
                controller.pickImage(imageType, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Camera'),
              onTap: () {
                Get.back();
                controller.pickImage(imageType, ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Center _buildSubmitButton(
    IDGeneratorController controller,
  ) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            controller.processFormData(
              _formKey,
            );
          }
        },
        child: const Text(
          'Add Resident',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != controller.selectedDate.value) {
      controller.selectedDate.value = picked;
    }
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!newValue.text.startsWith('+92 ')) {
      final newText = '+92 ' + newValue.text.replaceFirst('+92 ', '');
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }

    final text = newValue.text.replaceFirst('+92 ', '');
    final buffer = StringBuffer('+92 ');

    final digits = text.replaceAll(RegExp(r'\D'), '');

    if (digits.length > 0) buffer.write(digits.substring(0, 3));
    if (digits.length >= 4) buffer.write(' ' + digits.substring(3, 6));
    if (digits.length >= 7) buffer.write(' ' + digits.substring(6, 10));

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class CNICFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    if (digitsOnly.length > 0) {
      buffer.write(digitsOnly.substring(0, 5));
    }
    if (digitsOnly.length > 5) {
      buffer.write('-' + digitsOnly.substring(5, 12));
    }
    if (digitsOnly.length > 12) {
      buffer.write('-' + digitsOnly.substring(12));
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
