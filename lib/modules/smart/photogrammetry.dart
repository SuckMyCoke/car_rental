import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants.dart';
import '../../services/services.dart';

class RealPhotogrammetryScreen extends StatefulWidget {
  final String carId; // We need to know which car we are scanning
  const RealPhotogrammetryScreen({super.key, required this.carId});

  @override
  State<RealPhotogrammetryScreen> createState() => _RealPhotogrammetryScreenState();
}

class _RealPhotogrammetryScreenState extends State<RealPhotogrammetryScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _capturedImages = [];
  bool _isUploading = false;

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80 // Reduce size slightly for faster uploads
    );

    if (photo != null) {
      setState(() {
        _capturedImages.add(File(photo.path));
      });
    }
  }

  Future<void> _uploadDataset() async {
    if (_capturedImages.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please take at least 5 photos around the vehicle."))
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      await DatabaseService.uploadPhotogrammetryDataset(widget.carId, _capturedImages);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Dataset uploaded! Processing started."))
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Upload failed: $e"))
        );
      }
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("3D Scan (Optional)")),
      body: Column(
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: const Row(
              children: [
                Icon(Icons.info, color: AppColors.primary),
                SizedBox(width: 12),
                Expanded(child: Text("Walk around the car and take overlapping photos. We need 20-50 photos to generate a 3D model.")),
              ],
            ),
          ),

          // Grid of taken photos
          Expanded(
            child: _capturedImages.isEmpty
                ? const Center(child: Text("No photos taken yet.", style: TextStyle(color: Colors.grey)))
                : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8
              ),
              itemCount: _capturedImages.length,
              itemBuilder: (ctx, i) => Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(_capturedImages[i], fit: BoxFit.cover),
                  Positioned(
                      right: 0, top: 0,
                      child: GestureDetector(
                          onTap: () => setState(() => _capturedImages.removeAt(i)),
                          child: Container(color: Colors.black54, child: const Icon(Icons.close, color: Colors.white, size: 16))
                      )
                  )
                ],
              ),
            ),
          ),

          // Bottom Controls
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]
            ),
            child: Column(
              children: [
                Text("${_capturedImages.length} Photos Taken", style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _takePhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("Capture"),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : _uploadDataset,
                        icon: _isUploading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.cloud_upload),
                        label: Text(_isUploading ? "Uploading..." : "Finish Scan"),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}