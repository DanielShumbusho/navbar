import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';

class StepDistanceSpeedScreen extends StatefulWidget {
  const StepDistanceSpeedScreen({Key? key}) : super(key: key);

  @override
  State<StepDistanceSpeedScreen> createState() => _StepDistanceSpeedScreenState();
}

class _StepDistanceSpeedScreenState extends State<StepDistanceSpeedScreen> {
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<StepCount>? _stepSubscription;

  int _initialSteps = 0;
  int _currentSteps = 0;
  double _totalDistance = 0.0; // in meters
  double _speed = 0.0; // m/s
  Position? _lastPosition;

  @override
  void initState() {
    super.initState();
    _initPermissions();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _stepSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initPermissions() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;

    _startStepCounter();
    _startPositionUpdates();
  }

  void _startStepCounter() {
    _stepSubscription = Pedometer.stepCountStream.listen((StepCount event) {
      setState(() {
        if (_initialSteps == 0) {
          _initialSteps = event.steps;
        }
        _currentSteps = event.steps - _initialSteps;
      });
    }, onError: (error) {
      debugPrint('Step counter error: $error');
    });
  }

  void _startPositionUpdates() {
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      if (_lastPosition != null) {
        final distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );

        setState(() {
          _totalDistance += distance;
          _speed = position.speed; // meters/second
        });
      }

      _lastPosition = position;
    });
  }

  void _resetData() {
    setState(() {
      _initialSteps = 0;
      _currentSteps = 0;
      _totalDistance = 0.0;
      _speed = 0.0;
      _lastPosition = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Step Tracker"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetData,
            tooltip: 'Reset Data',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.directions_walk, size: 80),
            const SizedBox(height: 20),
            Text("Steps: $_currentSteps", style: _statStyle()),
            const SizedBox(height: 10),
            Text("Distance: ${_totalDistance.toStringAsFixed(2)} meters", style: _statStyle()),
            const SizedBox(height: 10),
            Text("Speed: ${_speed.toStringAsFixed(2)} m/s", style: _statStyle()),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _resetData,
              icon: const Icon(Icons.restart_alt),
              label: const Text("Reset Data"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _statStyle() => const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
}
