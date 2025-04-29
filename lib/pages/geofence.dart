import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    // Initialize controllers with default values
    _latController.text = _geofenceCenter.latitude.toString();
    _lngController.text = _geofenceCenter.longitude.toString();
    _radiusController.text = _geofenceRadius.toString();
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  void _updateGeofenceManually() {
    final double? lat = double.tryParse(_latController.text);
    final double? lng = double.tryParse(_lngController.text);
    final double? radius = double.tryParse(_radiusController.text);

    if (lat != null && lng != null && radius != null) {
      setState(() {
        _geofenceCenter = LatLng(lat, lng);
        _geofenceRadius = radius;
        // Recheck geofence status
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

  bool _checkGeofence(LatLng position) {
    // Simple distance calculation (for demonstration)
    // In a real app, use proper geospatial calculations
    final double latDiff = position.latitude - _geofenceCenter.latitude;
    final double lngDiff = position.longitude - _geofenceCenter.longitude;
    final double distance = latDiff * latDiff + lngDiff * lngDiff;
    return distance <= (_geofenceRadius * _geofenceRadius) / (1000000);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geofence Configuration'),
      ),
      body: Column(
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
                target: _geofenceCenter,
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
                ),
              }
                  : {},
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                // You might want to store the controller for later use
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _isInsideGeofence
                  ? 'Inside geofence'
                  : 'Outside geofence',
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