import 'package:Nutritrack/screens/authenticate/sign_in.dart';
import 'package:Nutritrack/screens/wrapper.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
// import 'package:Nutritrack/functions/calorie_tracker.dart';
import 'package:Nutritrack/screens/home/profile.dart';
import 'package:Nutritrack/screens/home/feed.dart';
import 'package:Nutritrack/screens/home/capture_image.dart';
import 'package:Nutritrack/screens/home/scan.dart';
import 'package:Nutritrack/services/auth.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final AuthService _auth = AuthService();
  late List<CameraDescription> _cameras;
  String result = '';
  // static image_path = "";
  int currIndex = 0;



  List<Widget> screens = [
    const Feed(),
    const Scan(),
    const ImageViewPage(),
    const Profile()
  ];

  Future<void> _onItemTap(int index) async {

    _cameras = await availableCameras();

    if (index == 1) {
      var res = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SimpleBarcodeScannerPage(),
          ));
      if (res == '-1') {
        index = 0;
      } else {
        setState(() {
          if (res is String) {
            result = res;
            productID = result;
          }
        });
      }
    }

    if (index == 2) {
      var res = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CaptureImage(cameras: _cameras),
          ));
      print("res:");
      print(res);
      if (res == null) {
        index = 0;
      } else {
        print("accesssed");
        setState(() {
          if (res is String) {
            imagePath = res;
          }
        });
      }
    }

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
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 3.0),
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(5)
          ),
          child: const Text("NutriTrack"),
        ),

        backgroundColor: Colors.green,
        elevation: 10,
        actions: <Widget>[
          TextButton.icon(
            // style: ,
            icon: const Icon(Icons.person, color: Colors.amber),
            label: const Text("Logout", style: TextStyle(color: Colors.amber),),
            onPressed: () async {
              await _auth.signOut();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Wrapper()),
                (Route<dynamic> route) => false
              );
            }
          )
        ],
      ),
      body: screens.elementAtOrNull(currIndex),
      bottomNavigationBar: BottomNavigationBarTheme(
          data: const BottomNavigationBarThemeData(backgroundColor: Colors.grey, elevation: 10, selectedItemColor: Colors.green, unselectedItemColor: Colors.amberAccent),
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