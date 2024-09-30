import 'package:flutter/material.dart';
import 'package:flutter_test_app/screens/home/profile.dart';
import 'package:flutter_test_app/screens/home/feed.dart';
import 'package:flutter_test_app/screens/home/capture_image.dart';
import 'package:flutter_test_app/screens/home/scan.dart';
import 'package:flutter_test_app/services/auth.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final AuthService _auth = AuthService();
  int currIndex = 0;


  List<Widget> screens = [
    const Feed(),
    const Scan(),
    const CaptureImage(),
    const Profile()
  ];

  void _onItemTap(int index) {
    setState(() {
      currIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Container(
          child: Text("NutriTrack"),
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 3.0),
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(5)
          ),
        ),

        backgroundColor: Colors.grey,
        elevation: 10,
        actions: <Widget>[
          TextButton.icon(
            icon: const Icon(Icons.person, color: Colors.deepPurple),
            label: const Text("Logout"),
            onPressed: () async {
              await _auth.signOut();
            }
          )
        ],
      ),
      body: screens.elementAtOrNull(currIndex),
      bottomNavigationBar: BottomNavigationBarTheme(
          data: const BottomNavigationBarThemeData(backgroundColor: Colors.grey, elevation: 10, selectedItemColor: Colors.deepPurple, unselectedItemColor: Colors.amberAccent),
          child: BottomNavigationBar(
            currentIndex: currIndex,
            onTap: _onItemTap,
            items: [
              BottomNavigationBarItem(icon: Icon(MdiIcons.fromString("home-circle-outline"),), label: "Home"),
              BottomNavigationBarItem(icon: Icon(MdiIcons.fromString("barcode-scan")), label: "Scan"),
              BottomNavigationBarItem(icon: Icon(MdiIcons.fromString("camera-outline")), label: "Take Picture"),
              BottomNavigationBarItem(icon: Icon(MdiIcons.fromString("account-circle-outline")), label: "Profile"),

            ],
          )
      ),
    );
  }
}