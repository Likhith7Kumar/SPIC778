import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isCropSelected = false; // Checkbox state
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  String _recognizedText = "No scanned text yet."; // OCR result text

  // Function to capture image from camera
  Future<void> captureImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      recognizeText(_selectedImage!);
    }
  }

  // Function to pick image from gallery
  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      recognizeText(_selectedImage!);
    }
  }

  // Function to send image to OCR.Space API
  Future<void> recognizeText(File imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.ocr.space/parse/image'),
    );

    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile.path));

    request.fields['apikey'] = "K8854448788957"; // Replace with your API key
    request.fields['language'] = "eng";
    request.fields['isOverlayRequired'] = "false";
    request.fields['OCREngine'] = "2"; // Use OCR Engine 2 for handwriting

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    var jsonResponse = json.decode(responseData);

    if (jsonResponse["OCRExitCode"] == 1) {
      setState(() {
        _recognizedText = jsonResponse["ParsedResults"][0]["ParsedText"] ??
            "No text recognized.";
      });
    } else {
      setState(() {
        _recognizedText = "Failed to recognize text.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: Colors.green[400],
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Camera Button
              CustomButton(
                icon: Icons.camera_alt,
                text: "Capture by Camera",
                onTap: captureImage,
              ),
              SizedBox(height: 15),

              // Gallery Button
              CustomButton(
                icon: Icons.image,
                text: "Pick from Gallery",
                onTap: pickImage,
              ),
              SizedBox(height: 20),

              // Crop Checkbox
              Row(
                children: [
                  Checkbox(
                    value: isCropSelected,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      setState(() {
                        isCropSelected = value!;
                      });
                    },
                  ),
                  Text(
                    "Use CROP for select text area",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Display selected image
              _selectedImage != null
                  ? Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    )
                  : (Text(
                      "No scanned files yet",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    )),
              SizedBox(height: 20),

              // Display recognized text
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Text(
                  _recognizedText,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.green[400],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: ""),
        ],
      ),
    );
  }
}

// Custom Button Widget
class CustomButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  CustomButton({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green[400],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.black),
            Text(
              text,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
