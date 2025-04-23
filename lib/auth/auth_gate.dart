import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import '../pages/dashboard_page.dart';
import 'sign_in_page.dart';

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    // If the user is authenticated, go to Dashboard
    if (user != null) {
      return DashboardPage();
    }
    // If not, go to Sign In Page
    else {
      return SignInPage();
    }
  }
}
