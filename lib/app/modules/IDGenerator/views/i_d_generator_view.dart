import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:secondfyp/app/modules/IDGenerator/controllers/i_d_generator_controller.dart';

class IDGeneratorView extends GetView<IDGeneratorController> {
  final _formKey = GlobalKey<FormState>();

  IDGeneratorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IDGeneratorController>(
      init: IDGeneratorController(),
      builder: (_) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Stack(
                children: [
                  Padding(
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
                        const SizedBox(height: 15),
                        _buildPhoneNumberField(_),
                        const SizedBox(height: 15),
                        _buildCNICField(_),
                        const SizedBox(height: 15),
                        _buildRoomTypeDropdown(_),
                        const SizedBox(height: 15),
                        _buildACSwitch(_),
                        const SizedBox(height: 15),
                        _buildDateSelector(context, _),
                        const SizedBox(height: 15),
                        _buildImageSection(_),
                        const SizedBox(height: 15),
                        _buildPickImageButton(_),
                        const SizedBox(height: 30),
                        _buildSubmitButton(_),
                      ],
                    ),
                  ),
                ],
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
        onTap: () => _selectDate(context),
      ),
    );
  }

  Obx _buildImageSection(IDGeneratorController controller) {
    return Obx(
      () => Center(
        child: controller.isLoading.value
            ? CircularProgressIndicator()
            : controller.imageUrl.value.isNotEmpty
                ? CircleAvatar(
                    radius: 75,
                    backgroundImage: NetworkImage(controller.imageUrl.value),
                  )
                : const Text('No image selected'),
      ),
    );
  }

  Center _buildPickImageButton(IDGeneratorController controller) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.blue,
          onPrimary: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        ),
        onPressed: () {
          _showImageSourceDialog(controller);
        },
        child: const Text(
          'Pick Image',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  void _showImageSourceDialog(IDGeneratorController controller) {
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
                controller.pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Camera'),
              onTap: () {
                Get.back();
                controller.pickImage(ImageSource.camera);
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
          primary: Colors.green,
          onPrimary: Colors.white,
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

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.2)
      ..quadraticBezierTo(
          size.width * 0.5, size.height * 0.4, size.width, size.height * 0.2)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);

    final path2 = Path()
      ..moveTo(0, size.height * 0.8)
      ..quadraticBezierTo(
          size.width * 0.5, size.height * 0.6, size.width, size.height * 0.8)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path2, paint..color = Colors.blue.withOpacity(0.15));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
