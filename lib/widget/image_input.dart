import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  const ImageInput({super.key, required this.onPickedImage});

  final void Function(File image) onPickedImage;

  @override
  State<ImageInput> createState() {
    return _ImageInputState();
  }
}

class _ImageInputState extends State<ImageInput> {
  File? _selectedImage;

  void _takepicture() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );
    if (pickedImage == null) {
      return;
    }
    setState(() {
      _selectedImage = File(pickedImage.path);
    });

    widget.onPickedImage(_selectedImage!);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = TextButton.icon(
      onPressed: _takepicture,
      icon: const Icon(Icons.camera_alt),
      label: const Text('Take Image'),
    );

    if (_selectedImage != null) {
      content = Stack(
        children: [
          Image.file(
            _selectedImage!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          IconButton(
            alignment: Alignment.topLeft,
            onPressed: _takepicture,
            icon: const Icon(Icons.edit),
          ),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
        ),
      ),
      height: 300,
      width: double.infinity,
      child: content,
    );
  }
}
