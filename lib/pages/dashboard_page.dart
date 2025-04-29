import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:navbar/pages/pedometer.dart';
import 'package:navbar/pages/shoppingpage.dart';
import 'package:provider/provider.dart';
import 'package:navbar/auth/auth_provider.dart';
import '../auth/sign_in_page.dart';
import 'Settings.dart';
import 'calculator_page.dart';
import 'contacts.dart';
import 'gallery.dart';
import 'geofence.dart';
import 'location.dart';
import 'profile_page.dart';
import 'settings_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  ImageProvider? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize with Google account picture
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user?.photoUrl != null) {
      _profileImage = NetworkImage(user!.photoUrl!);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _profileImage = FileImage(File(pickedFile.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
      );
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Profile Picture'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('Take a photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Choose from gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_profileImage != null)
                  ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Remove photo'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _profileImage = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            GestureDetector(
              onTap: _showImagePickerDialog,
              child: UserAccountsDrawerHeader(
                accountName: Text(user?.displayName ?? "User"),
                accountEmail: Text(user?.email ?? "user@example.com"),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: _profileImage ??
                      (user?.photoUrl != null
                          ? NetworkImage(user!.photoUrl!)
                          : AssetImage('assets/default_profile.png') as ImageProvider),
                ),
              ),
            ),
            // Rest of your drawer items...
            ListTile(
              leading: Icon(Icons.calculate),
              title: Text("Calculator"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalculatorPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Profile"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person_2_rounded),
              title: Text("Contacts"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ContactsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.image),
              title: Text("Gallery"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GalleryScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.hiking),
              title: Text("Pedometer"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StepDistanceSpeedScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text("Geofence"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GeofenceScreen()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () async {
                final provider =
                Provider.of<AuthProvider>(context, listen: false);
                provider.logout();
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome to the Dashboard",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  DashboardCard(
                    icon: Icons.people,
                    title: "Users",
                    onTap: () {
                      // Navigate to Users page
                    },
                  ),
                  DashboardCard(
                    icon: Icons.map,
                    title: "Map",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MapInputScreen()),
                      );
                    },
                  ),
                  DashboardCard(
                    icon: Icons.shopping_cart,
                    title: "Online shop",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ArticleScreen()),
                      );
                    },
                  ),
                  DashboardCard(
                    icon: Icons.settings,
                    title: "Settings",
                    onTap: () {
                      // Navigate to Settings page
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const DashboardCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}