import 'dart:convert';

import 'package:favorite_place/models/place.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:http/http.dart' as http;

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.selectedLocation});

  final void Function(PlaceLocation location) selectedLocation;

  @override
  State<LocationInput> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedlocation;
  bool _isGettingLocation = false;
  double? Longitude;
  double? latitude;
  MapLibreMapController? _mapController;

  String get imageLocation {
    if (_pickedlocation == null) {
      return '';
    }
    final lat = _pickedlocation!.latitude;
    final long = _pickedlocation!.longitude;

    return 'https://api.maptiler.com/maps/streets/static/$long,$lat,1/600x300.jpg?key=gJWsEh8XZ4QUehooL0kx';
  }

  void _getLocation() async {
    print("object => ${imageLocation}");
    Location location = new Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
    });

    locationData = await location.getLocation();
    final lat = locationData.latitude;
    final long = locationData.longitude;

    if (lat == null || long == null) {
      return;
    }

    final url = Uri.parse(
        'https://api.maptiler.com/geocoding/$long,$lat.json?key=gJWsEh8XZ4QUehooL0kx');
    final response = await http.get(url);
    final resData = json.decode(response.body);
    final address = resData['features'][0]['place_name'];
    print(address);

    setState(() {
      latitude = lat;
      Longitude = long;
      _pickedlocation =
          PlaceLocation(latitude: lat, longitude: long, address: address);
      _isGettingLocation = false;
    });

    widget.selectedLocation(_pickedlocation!);
  }

  void _addMarker(double longitude, double latitude) {
    if (_mapController != null) {
      _mapController!.addSymbol(
        SymbolOptions(
            geometry: LatLng(latitude, longitude),
            iconImage: 'assets/images/pin.png',
            iconSize: 1),
      );
    }
  }

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
    if (Longitude != null || latitude != null) {
      _addMarker(Longitude!, latitude!);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget locatinContent = Text(
      'No location is Selected',
      textAlign: TextAlign.center,
      style: Theme.of(context)
          .textTheme
          .bodyLarge!
          .copyWith(color: Theme.of(context).colorScheme.onBackground),
    );

    if (_isGettingLocation == true) {
      locatinContent = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_pickedlocation != null) {
      locatinContent = Image.network(
        imageLocation,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    // if (Longitude != null || latitude != null) {
    //   locatinContent = Scaffold(
    //     body: MapLibreMap(
    //       // styleString: MapLibreStyles.demo,
    //       styleString:
    //           "https://api.maptiler.com/maps/streets-v2/style.json?key=gJWsEh8XZ4QUehooL0kx",
    //       initialCameraPosition: CameraPosition(
    //         target: LatLng(latitude!, Longitude!),
    //         zoom: 12.0,
    //       ),
    //       onMapCreated: _onMapCreated,
    //       trackCameraPosition: true,
    //       myLocationEnabled: true,
    //       myLocationRenderMode: MyLocationRenderMode.normal,
    //       zoomGesturesEnabled: true,
    //       minMaxZoomPreference: MinMaxZoomPreference(2, 15),
    //     ),
    //   );
    // }

    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
            ),
          ),
          child: locatinContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _getLocation,
              icon: const Icon(Icons.location_on),
              label: const Text(
                'Get CurrentLocation',
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.map),
              label: const Text(
                'Select On Map',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
