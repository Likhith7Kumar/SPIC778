import 'package:flutter/material.dart';

class TextResultScreen extends StatelessWidget {
  final String recognizedText;

  const TextResultScreen({super.key, required this.recognizedText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recognized Text")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          recognizedText,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
