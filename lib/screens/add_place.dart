import 'dart:io';

import 'package:favorite_place/models/place.dart';
import 'package:favorite_place/provider/user_places.dart';
import 'package:favorite_place/widget/image_input.dart';
import 'package:favorite_place/widget/location_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:location/location.dart';

class AddPlaceScreen extends ConsumerStatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  ConsumerState<AddPlaceScreen> createState() {
    return _AddPlaceScreenState();
  }
}

class _AddPlaceScreenState extends ConsumerState<AddPlaceScreen> {
  final _titleController = TextEditingController();
  File? _selectedImage;
  PlaceLocation? _selectedLocation;

  void _savePlace() {
    final _enteredTitle = _titleController.text;

    if (_enteredTitle.isEmpty ||
        _selectedImage == null ||
        _selectedLocation == null) {
      return;
    }
    ref
        .read(userPlacesNotifier.notifier)
        .addPlace(_enteredTitle, _selectedImage!, _selectedLocation!);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Place'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Title'),
              controller: _titleController,
              style:
                  TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
            const SizedBox(
              height: 12,
            ),
            ImageInput(
              onPickedImage: (image) {
                _selectedImage = image;
              },
            ),
            const SizedBox(
              height: 12,
            ),
            LocationInput(
              selectedLocation: (location) {
                _selectedLocation = location;
              },
            ),
            const SizedBox(
              height: 12,
            ),
            ElevatedButton.icon(
              onPressed: _savePlace,
              icon: const Icon(Icons.add),
              label: const Text('Add Place'),
            ),
          ],
        ),
      ),
    );
  }
}
