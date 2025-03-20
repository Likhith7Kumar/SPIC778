import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'welcome.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to HomeScreen after 2 seconds
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[400],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Image
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.green[800],
              ),
              padding: EdgeInsets.all(15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/image1.jpg', // Load your image from assets
                  width: 80, // Adjust size as needed
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),

            // App Name
            Text(
              "Handwritten Text Recognition",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanImageScreen(File(pickedFile.path)),
        ),
      );
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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300,
              height: 200, // Adjust height
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center align
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Align horizontally
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(context, ImageSource.camera),
                    icon: Icon(Icons.camera_alt),
                    label: Text("Capture Image"),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    ),
                  ),
                  SizedBox(height: 20), // Increased spacing
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(context, ImageSource.gallery),
                    icon: Icon(Icons.image),
                    label: Text("Pick from Gallery"),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
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

class ScanImageScreen extends StatefulWidget {
  final File imageFile;
  ScanImageScreen(this.imageFile);

  @override
  _ScanImageScreenState createState() => _ScanImageScreenState();
}

class _ScanImageScreenState extends State<ScanImageScreen> {
  bool isProcessing = false;

  Future<void> recognizeText() async {
    setState(() {
      isProcessing = true;
    });

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.ocr.space/parse/image'),
    );
    request.files
        .add(await http.MultipartFile.fromPath('file', widget.imageFile.path));
    request.fields['apikey'] = "K88454448788957"; // Replace with your API key
    request.fields['language'] = "eng";
    request.fields['OCREngine'] = "2";

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    var jsonResponse = json.decode(responseData);

    String recognizedText = "Failed to recognize text.";
    if (jsonResponse["OCRExitCode"] == 1) {
      recognizedText = jsonResponse["ParsedResults"][0]["ParsedText"] ??
          "No text recognized.";
    }

    setState(() {
      isProcessing = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TextResultScreen(recognizedText, widget.imageFile.path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan Image"),
        backgroundColor: Colors.green[400],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.file(widget.imageFile, height: 300),
          SizedBox(height: 20),
          isProcessing
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: recognizeText,
                  child: Text("Recognize Text"),
                ),
        ],
      ),
    );
  }
}

class TextResultScreen extends StatefulWidget {
  final String recognizedText;
  final dynamic imagePath;

  const TextResultScreen(this.recognizedText, this.imagePath);

  @override
  _TextResultScreenState createState() => _TextResultScreenState();
}

class _TextResultScreenState extends State<TextResultScreen> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.recognizedText);
  }

  Future<void> _saveFile(BuildContext context, bool isPdf) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) return; // User canceled

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child:
              pw.Text(_textController.text, style: pw.TextStyle(fontSize: 18)),
        ),
      ),
    );
    final file = File("$selectedDirectory/recognized_text.pdf");
    await file.writeAsBytes(await pdf.save());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Saved as PDF: ${file.path}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Text Recognize"),
        backgroundColor: Colors.green[400],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Edit recognized text...",
                  ),
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
          Container(
            color: Colors.green,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.share, color: Colors.white, size: 30),
                  onPressed: () => Share.share(_textController.text),
                ),
                IconButton(
                  icon: Icon(Icons.copy, color: Colors.white, size: 30),
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: _textController.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Text copied to clipboard")),
                    );
                  },
                ),
                IconButton(
                  icon:
                      Icon(Icons.picture_as_pdf, color: Colors.white, size: 30),
                  onPressed: () => _saveFile(context, true),
                ),
                IconButton(
                  icon: Icon(Icons.image_search, color: Colors.white, size: 30),
                  onPressed: () {
                    if (widget.imagePath.isNotEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Selected Image"),
                          content: Image.file(File(widget.imagePath),
                              fit: BoxFit.contain),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Close"),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
