import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class GeofenceScreen extends StatefulWidget {
  const GeofenceScreen({Key? key}) : super(key: key);

  @override
  _GeofenceScreenState createState() => _GeofenceScreenState();
}

class _GeofenceScreenState extends State<GeofenceScreen> {
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController();

  LatLng _geofenceCenter = const LatLng(37.7749, -122.4194); // Default SF
  double _geofenceRadius = 200.0; // Default 200m
  LatLng? _currentPosition;
  bool _isInsideGeofence = false;
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _latController.text = _geofenceCenter.latitude.toString();
    _lngController.text = _geofenceCenter.longitude.toString();
    _radiusController.text = _geofenceRadius.toString();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _latController.dispose();
    _lngController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    setState(() => _isLoading = true);

    final status = await Permission.location.request();
    if (status.isGranted) {
      await _getCurrentLocation();
      _startLocationUpdates();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission denied')),
      );
    }

    setState(() => _isLoading = false);
  }
  bool _checkGeofence(LatLng position) {
    // Using the Haversine formula for accurate distance calculation
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      _geofenceCenter.latitude,
      _geofenceCenter.longitude,
    );
    return distance <= _geofenceRadius;
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isInsideGeofence = _checkGeofence(_currentPosition!);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not get location: $e')),
      );
    }
  }

  void _startLocationUpdates() {
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _isInsideGeofence = _checkGeofence(_currentPosition!);
        });
      }
    });
  }


  void _updateGeofenceManually() {
    final double? lat = double.tryParse(_latController.text);
    final double? lng = double.tryParse(_lngController.text);
    final double? radius = double.tryParse(_radiusController.text);

    if (lat != null && lng != null && radius != null) {
      setState(() {
        _geofenceCenter = LatLng(lat, lng);
        _geofenceRadius = radius;
        if (_currentPosition != null) {
          _isInsideGeofence = _checkGeofence(_currentPosition!);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid coordinates or radius")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geofence Configuration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkLocationPermission,
            tooltip: 'Refresh location',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latController,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Latitude'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _lngController,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Longitude'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _radiusController,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Radius (m)'),
                  ),
                ),
                ElevatedButton(
                  onPressed: _updateGeofenceManually,
                  child: const Text("Set"),
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition ?? _geofenceCenter,
                zoom: 14,
              ),
              circles: {
                Circle(
                  circleId: const CircleId('geofence'),
                  center: _geofenceCenter,
                  radius: _geofenceRadius,
                  strokeWidth: 2,
                  strokeColor: _isInsideGeofence ? Colors.green : Colors.red,
                  fillColor: _isInsideGeofence
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                ),
              },
              markers: _currentPosition != null
                  ? {
                Marker(
                  markerId: const MarkerId('current_position'),
                  position: _currentPosition!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    _isInsideGeofence
                        ? BitmapDescriptor.hueGreen
                        : BitmapDescriptor.hueRed,
                  ),
                ),
              }
                  : {},
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (GoogleMapController controller) {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _currentPosition == null
                  ? 'Waiting for location...'
                  : _isInsideGeofence
                  ? 'Inside geofence (${Geolocator.distanceBetween(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
                _geofenceCenter.latitude,
                _geofenceCenter.longitude,
              ).toStringAsFixed(1)}m from center)'
                  : 'Outside geofence (${Geolocator.distanceBetween(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
                _geofenceCenter.latitude,
                _geofenceCenter.longitude,
              ).toStringAsFixed(1)}m from center)',
              style: TextStyle(
                color: _isInsideGeofence ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}