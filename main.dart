import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(PolylineApp());
}

class PolylineApp extends StatelessWidget {
  const PolylineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: PolylineScreen());
  }
}

class PolylineScreen extends StatefulWidget {
  PolylineScreen({super.key});

  @override
  State<PolylineScreen> createState() => _PolylineScreenState();
}

class _PolylineScreenState extends State<PolylineScreen> {
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  List<LatLng> polylinePoints = [];
  Set<Polyline> polylines = {};
  LatLng? startPoint;
  LatLng? endPoint;

  void _handleTap(LatLng tappedPoint) {
    setState(() {
      if (startPoint == null) {
        startPoint = tappedPoint;
        markers.add(
          Marker(
            markerId: MarkerId('start'),
            position: startPoint!,
            infoWindow: InfoWindow(title: 'Start Point'),
          ),
        );
      } else if (endPoint == null) {
        endPoint = tappedPoint;
        markers.add(
          Marker(
            markerId: MarkerId('end'),
            position: endPoint!,
            infoWindow: InfoWindow(title: 'End Point'),
          ),
        );
        // Draw the polyline
        polylinePoints.clear();
        polylinePoints.add(startPoint!);
        polylinePoints.add(endPoint!);
        polylines.add(
          Polyline(
            polylineId: PolylineId('route'),
            points: polylinePoints,
            color: Colors.blue,
            width: 5,
          ),
        );
        // Reset for the next polyline
        startPoint = null;
        endPoint = null;
      } else {
        // If both points are selected, clear everything for a new selection
        markers.clear();
        polylines.clear();
        startPoint = tappedPoint;
        endPoint = null;
        markers.add(
          Marker(
            markerId: MarkerId('start'),
            position: startPoint!,
            infoWindow: InfoWindow(title: 'Start Point'),
          ),
        );
      }
    });
  }

  void _goToCurrentLocation() async {
    if (!await _checkLocationServicePermission()) {
      return;
    }
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15,
          ),
        ),
      );
    } catch (e) {
      print("Error getting current location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not get current location.')),
      );
    }
  }

  Future<bool> _checkLocationServicePermission() async {
    bool isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location services are disabled. Please enable them in the settings.',
          ),
        ),
      );
      return false;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location permission denied. Please allow location access for the app.',
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
            'Location permission permanently denied. Please enable it in app settings.',
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
      appBar: AppBar(
        title: Text('Polyline on Map'),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: _goToCurrentLocation,
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(
            15.98776584206113,
            120.57316910317932,
          ), // Initial view of Urdaneta
          zoom: 12,
        ),
        markers: markers,
        polylines: polylines,
        onTap: _handleTap,
        myLocationButtonEnabled: false,
        myLocationEnabled: true,
      ),
    );
  }
}
