import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:navbar/auth/sign_up_page.dart';

import 'package:battery_plus/battery_plus.dart'; // For battery level
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // For Bluetooth status
import 'package:connectivity_plus/connectivity_plus.dart'; // For internet connection
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // For notifications

import '../auth/sign_in_page.dart';
import 'dashboard_page.dart';

class home_page extends StatefulWidget {
  @override
  _home_pageState createState() => _home_pageState();
}

class _home_pageState extends State<home_page> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final Battery _battery = Battery();
  BluetoothAdapterState _bluetoothState = BluetoothAdapterState.unknown;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _monitorBattery();
    _monitorBluetooth();
    _monitorInternet();
  }

  void _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  void _monitorBattery() async {
    _battery.onBatteryStateChanged.listen((BatteryState state) async {
      if (state == BatteryState.charging || state == BatteryState.full) {
        return; // Ignore when charging or full
      }
      final batteryLevel = await _battery.batteryLevel;
      if (batteryLevel <= 20) {
        if (mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Low Battery'),
            ),
          );
        }
      }
    });
  }

  void _monitorBluetooth() {
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      if (state != _bluetoothState) {
        setState(() {
          _bluetoothState = state;
        });
        if (state == BluetoothAdapterState.on) {
          if (mounted){
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Bluetooth On'),
                ),
            );
          }
        } else if (state == BluetoothAdapterState.off) {
          if (mounted){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Bluetooth Off'),
              ),
            );
          }
        }
      }
    });
  }

  void _monitorInternet() async {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;

      if (result != _connectionStatus) {
        setState(() {
          _connectionStatus = result;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result == ConnectivityResult.none
                  ? 'You are offline'
                  : 'You are online'),
            ),
          );
        }
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return DashboardPage();
          } else if (snapshot.hasError) {
            return Center(child: Text("Something went wrong"));
          } else {
            return SignInPage();
          }
        },
      ),
    );
  }
}