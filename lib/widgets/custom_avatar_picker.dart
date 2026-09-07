import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CustomAvatarPicker extends StatefulWidget {

  final ValueChanged<XFile> onChanged;

  const CustomAvatarPicker({
    super.key,
    required this.onChanged,
  });

  @override
  State<CustomAvatarPicker> createState() => _CustomAvatarPickerState();
}

class _CustomAvatarPickerState extends State<CustomAvatarPicker> {

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if(image != null) {
      setState(() {
        _selectedImage = image;
      });
      widget.onChanged(image);
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: pickImage,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: _selectedImage == null
                ? null
                : FileImage(File(_selectedImage!.path)),
            child: _selectedImage == null
                ? const Icon(Icons.person, size: 60,)
                : null,
          ),
          const CircleAvatar(
            radius: 18,
            child: Icon(Icons.camera_alt, size: 18,),
          ),
        ],
      ),
    );
  }
}

/* Call from the main form
   XFile? _selectedImage;
  //Call from the Scaffold
  child: CustomAvatarPicker(onChanged: (value) {
    setState(() {
      _selectedImage = value;
    });
  }),
*/