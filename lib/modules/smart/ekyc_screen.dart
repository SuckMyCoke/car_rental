import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants.dart';

class RealEKYCScreen extends StatefulWidget {
  const RealEKYCScreen({super.key});
  @override
  State<RealEKYCScreen> createState() => _RealEKYCScreenState();
}

class _RealEKYCScreenState extends State<RealEKYCScreen> {
  File? _imageFile;
  bool _isScanning = false;
  String? _detectedName;
  String? _detectedID;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() { _imageFile = File(pickedFile.path); _detectedName = null; _detectedID = null; });
      _processImage();
    }
  }

  Future<void> _processImage() async {
    if (_imageFile == null) return;
    setState(() => _isScanning = true);
    final inputImage = InputImage.fromFile(_imageFile!);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      // Basic heuristic for demo: Find numbers resembling ID format
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          String text = line.text.trim();
          if (RegExp(r'\d{6}-?\d{2}-?\d{4}').hasMatch(text)) _detectedID = text;
          if (text == text.toUpperCase() && text.length > 5 && !text.contains(RegExp(r'\d'))) _detectedName = text;
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      textRecognizer.close();
      setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan ID")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              height: 200, width: double.infinity,
              color: Colors.grey[200],
              child: _imageFile != null ? Image.file(_imageFile!, fit: BoxFit.cover) : const Icon(Icons.camera_alt, size: 50, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: ElevatedButton(onPressed: () => _pickImage(ImageSource.camera), child: const Text("Camera"))),
              const SizedBox(width: 16),
              Expanded(child: OutlinedButton(onPressed: () => _pickImage(ImageSource.gallery), child: const Text("Gallery"))),
            ]),
            const SizedBox(height: 24),
            if (_isScanning) const CircularProgressIndicator(),
            if (_detectedID != null) ...[
              ListTile(title: const Text("Name"), subtitle: Text(_detectedName ?? "Unknown")),
              ListTile(title: const Text("ID"), subtitle: Text(_detectedID!)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true), // Return success
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Confirm Identity"),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}