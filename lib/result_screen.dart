import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {

  final String text;

  const ResultScreen({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Text Scan Result"),
      ),
      body: Container(
        padding: const EdgeInsets.all(30.0),
        child: Text(text),
      )
    );
  }
}
