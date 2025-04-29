import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:light/light.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _shakeDetectionEnabled = false;
  bool _lightSensorEnabled = false;

  StreamSubscription? _accelerometerSubscription;
  StreamSubscription? _lightSubscription;

  double _lastX = 0, _lastY = 0, _lastZ = 0;
  final double _shakeThreshold = 15;

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);
  }

  void _startShakeDetection() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      double dx = event.x - _lastX;
      double dy = event.y - _lastY;
      double dz = event.z - _lastZ;

      double acceleration = sqrt(dx * dx + dy * dy + dz * dz);

      if (acceleration > _shakeThreshold) {
        _showNotification("Shake Detected", "You shook the phone!");
      }

      _lastX = event.x;
      _lastY = event.y;
      _lastZ = event.z;
    });
  }

  void _stopShakeDetection() {
    _accelerometerSubscription?.cancel();
  }

  void _showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'shake_channel',
      'Shake Alerts',
      importance: Importance.high,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(0, title, body, notificationDetails);
  }
  final Light _light = Light();
  void _startLightSensor() {
    try {
      _lightSubscription = _light.lightSensorStream.listen((luxValue) {
        double brightness = (luxValue / 1000).clamp(0.1, 1.0);
        ScreenBrightness().setScreenBrightness(brightness);
      });
    } catch (e) {
      debugPrint("Light sensor not available: $e");
    }
  }

  void _stopLightSensor() {
    _lightSubscription?.cancel();
  }

  @override
  void dispose() {
    _stopShakeDetection();
    _stopLightSensor();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Shake Notification'),
            subtitle: const Text('Notify when phone is shaken'),
            value: _shakeDetectionEnabled,
            onChanged: (val) {
              setState(() {
                _shakeDetectionEnabled = val;
                if (val) {
                  _startShakeDetection();
                } else {
                  _stopShakeDetection();
                }
              });
            },
          ),
          SwitchListTile(
            title: const Text('Ambient Light Adjustment'),
            subtitle: const Text('Adjust brightness based on ambient light'),
            value: _lightSensorEnabled,
            onChanged: (val) {
              setState(() {
                _lightSensorEnabled = val;
                if (val) {
                  _startLightSensor();
                } else {
                  _stopLightSensor();
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
