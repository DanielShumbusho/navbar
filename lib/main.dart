import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:navbar/pages/home_page.dart';
import 'package:provider/provider.dart';
import 'auth/auth_provider.dart';
import 'auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: home_page(),
      ),
    );
  }

