// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:Nutritrack/functions/barcode_scanner.dart';
//
// import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
//
// import 'barcode_scanner.dart';
// import 'calorie_tracker.dart';
//
//
//
// late List<CameraDescription> _cameras;
//
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   _cameras = await availableCameras();
//
//   runApp(const MyApp());
// }
//
//
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   //
//   // @override
//   // State<MyApp> createState() => _MyAppState();
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Demo'),
//     );
//   }
//
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.
//
//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//
//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }
//
//   String result = '';
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ElevatedButton(
//               onPressed: () async {
//                 var res = await Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const SimpleBarcodeScannerPage(),
//                     ));
//                 setState(() {
//                   if (res is String) {
//                     result = res;
//                     productID = result;
//                   }
//                 });
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const MyFoodPage()),
//                 );
//               },
//               child: const Text('Open Scanner'),
//             ),
//             Text('Barcode Result: $result'),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => CameraApp(cameras: _cameras),
//                     ));
//               },
//               child: const Text('Open Camera'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
