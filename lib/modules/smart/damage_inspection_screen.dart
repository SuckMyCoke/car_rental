import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_vision/flutter_vision.dart';

class RealDamageDetectionScreen extends StatefulWidget {
  const RealDamageDetectionScreen({super.key});
  @override
  State<RealDamageDetectionScreen> createState() => _RealDamageDetectionScreenState();
}

class _RealDamageDetectionScreenState extends State<RealDamageDetectionScreen> {
  late CameraController _controller;
  late FlutterVision _vision;
  bool _isLoaded = false;
  List<Map<String, dynamic>> _detections = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _vision = FlutterVision();
    // Load your custom trained model here
    // If fail, ensure assets are correct in pubspec.yaml
    try {
      await _vision.loadYoloModel(
        modelPath: 'assets/models/yolov8n.tflite',
        labels: 'assets/models/labels.txt',
        modelVersion: "yolov8",
        numThreads: 2, useGpu: true,
      );
      final cameras = await availableCameras();
      _controller = CameraController(cameras[0], ResolutionPreset.medium);
      await _controller.initialize();
      await _controller.startImageStream((image) {
        if (mounted) _runInference(image);
      });
      setState(() => _isLoaded = true);
    } catch (e) {
      print("AI Init Error: $e");
    }
  }

  Future<void> _runInference(CameraImage image) async {
    try {
      final results = await _vision.yoloOnFrame(
        bytesList: image.planes.map((plane) => plane.bytes).toList(),
        imageHeight: image.height, imageWidth: image.width,
        iouThreshold: 0.4, confThreshold: 0.4, classThreshold: 0.5,
      );
      if (mounted) setState(() => _detections = results);
    } catch (e) { /* ignore frame errors */ }
  }

  @override
  void dispose() {
    _controller.dispose();
    _vision.closeYoloModel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_controller),
          ..._detections.map((d) {
            final box = d["box"];
            return Positioned(
              left: box[0] * 1.0, top: box[1] * 1.0,
              width: (box[2] - box[0]) * 1.0, height: (box[3] - box[1]) * 1.0,
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.red, width: 3)),
                child: Text("${d['tag']} ${(d['box'][4]*100).toInt()}%", style: const TextStyle(backgroundColor: Colors.red, color: Colors.white)),
              ),
            );
          }),
          Positioned(top: 40, left: 20, child: BackButton(color: Colors.white)),
        ],
      ),
    );
  }
}