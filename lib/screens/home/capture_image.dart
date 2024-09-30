import 'package:flutter/material.dart';

class CaptureImage extends StatefulWidget {
  const CaptureImage({super.key});

  @override
  State<CaptureImage> createState() => _CaptureImageState();
}

class _CaptureImageState extends State<CaptureImage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("Image"),
    );
  }
}
