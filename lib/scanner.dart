import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:Nutritrack/result_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Flutter Text Recognition Test",
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {

  bool _permissionGranted = false;
  late final Future<void> _future;
  CameraController? _cameraController;
  final _textRecognizer = TextRecognizer();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _future = _requestCamPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed && _cameraController != null && _cameraController!.value.isInitialized) {
      _startCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          return Stack(
            children: [

              //   Show camera feed behind everything
              if (_permissionGranted)
                FutureBuilder<List<CameraDescription>>(
                    future: availableCameras(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        _initCamController(snapshot.data!);

                        return Center(child: CameraPreview(_cameraController!));
                      } else {
                        return const LinearProgressIndicator();
                      }
                    }
                ),
              Scaffold(
                  appBar: AppBar(
                      title: const Text("Text Scanner")
                  ),
                  backgroundColor: _permissionGranted ? Colors.transparent : null,
                  body: _permissionGranted
                      ? Column(
                    children: [
                      Expanded(
                          child: Container()
                      ),
                      Container(
                        padding: const EdgeInsets.only(bottom: 30.0),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: _scanImage,
                            child: const Text('Scan Text'),
                          ),
                        ),
                      )
                    ],
                  )
                      : Center(
                      child: Container(
                          padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                          child: const Text("Camera Permission Denied", textAlign: TextAlign.center,)
                      )
                  )
              )
            ],
          );
        });
  }

  Future<void> _requestCamPermission() async {
    final status = await Permission.camera.request();
    _permissionGranted = status == PermissionStatus.granted;
    print(_permissionGranted);
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelected(_cameraController!.description);
    }
  }

  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController?.dispose();
    }
  }

  void _initCamController(List<CameraDescription> cameras) {
    if (_cameraController != null) {
      return;
    }

    CameraDescription? camera;
    for (var i = 0; i < cameras.length; i++) {
      final CameraDescription current = cameras[i];
      //   Choose the first cam that points backwards
      if (current.lensDirection == CameraLensDirection.back) {
        camera = current;
        break;
      }
    }

    if (camera != null) {
      _cameraSelected(camera);
    }
  }

  Future<void> _cameraSelected(CameraDescription camera) async {
    _cameraController = CameraController(camera, ResolutionPreset.max, enableAudio: false);

    await _cameraController?.initialize();

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _scanImage() async {
    if (_cameraController == null) {
      return;
    }

    final navigator = Navigator.of(context);

    try {
      final picFile = await _cameraController!.takePicture();

      final file = File(picFile.path);

      final inputImage = InputImage.fromFile(file);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      await navigator.push(MaterialPageRoute(
          builder: (context) => ResultScreen(text: recognizedText.text)
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occurred during text scan!"))
      );
    }
  }
}
