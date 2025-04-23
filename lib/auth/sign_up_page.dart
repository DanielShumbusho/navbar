import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

class SignUpPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final provider =
                Provider.of<AuthProvider>(context, listen: false);
                provider.googleLogin();
              },
              child: Text("Already have an count? SignIn"),
            ),
          ],
        ),
      ),
    );
  }
}
