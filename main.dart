import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MapApp());
}

class MapApp extends StatelessWidget {
  const MapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MapScreen());
  }
}

class MapScreen extends StatefulWidget {
  MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;

  Set<Marker> markers = {
    // Marker(
    //   markerId: MarkerId('01'),
    //   position: LatLng(15.987668, 120.573004),
    //   infoWindow: InfoWindow(title: 'Urdaneta'),
    // ),
    // Marker(
    //   markerId: MarkerId('02'),
    //   position: LatLng(16.03036585722708, 120.33268377759823),
    //   infoWindow: InfoWindow(title: 'Dagupan'),
    // ),
  };

  void markLocation(LatLng position) {
    markers.clear();
    markers.add(Marker(markerId: MarkerId('${position}'), position: position));
    setState(() {});
  }

  void gotoLocation() async {
    if (!await checkLocationServicePermission()) {
      return;
    }
    // var geoPosition = await Geolocator.getCurrentPosition();
    // markLocation(LatLng(geoPosition.latitude, geoPosition.longitude));
    await Geolocator.getPositionStream().listen((geoPosition) {
      markLocation(LatLng(geoPosition.latitude, geoPosition.longitude));
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(geoPosition.latitude, geoPosition.longitude),
            zoom: 12,
          ),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    gotoLocation();
  }

  Future<bool> checkLocationServicePermission() async {
    //check for the locationservice
    bool isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location services is disabled. Please enable it in the settings.',
          ),
        ),
      );
      return false;
    }
    //check permissions, if these are set
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location permission is denied. Please accept the location permission for the app to work.',
            ),
          ),
        );
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location permission is permanently denied. Please allow in the settings to continue',
          ),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          onMapCreated: (controller) {
            mapController = controller;
          },
          markers: markers,
          mapType: MapType.normal,
          mapToolbarEnabled: true,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          initialCameraPosition: CameraPosition(
            target: LatLng(15.98776584206113, 120.57316910317932),
            zoom: 10,
            // tilt: 60,
          ),
          onTap: (position) {
            print(position.latitude);
            print(position.longitude);
            markLocation(position);
          },
        ),
      ),
    );
  }
}
