import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';

class PlateScannerScreen extends StatefulWidget {
  const PlateScannerScreen({super.key});
  @override
  State<PlateScannerScreen> createState() => _PlateScannerScreenState();
}

class _PlateScannerScreenState extends State<PlateScannerScreen> {
  bool _scanning = true;
  String? _detected;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() { _scanning = false; _detected = "WVA 1234"; });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(child: Icon(Icons.directions_car, size: 200, color: Colors.white.withOpacity(0.1))),
          Center(
            child: Container(
              width: 280, height: 100,
              decoration: BoxDecoration(border: Border.all(color: _scanning ? AppColors.primary : AppColors.accentGreen, width: 3), borderRadius: BorderRadius.circular(8)),
              child: _scanning
                  ? Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0), AppColors.primary.withOpacity(0.5), AppColors.primary.withOpacity(0)], begin: Alignment.topCenter, end: Alignment.bottomCenter))).animate(onPlay: (c) => c.repeat()).moveY(begin: -50, end: 50, duration: 1500.ms)
                  : null,
            ),
          ),
          if (!_scanning && _detected != null)
            Positioned(
              bottom: 50, left: 20, right: 20,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text("Plate Detected", style: TextStyle(color: AppColors.textLight)),
                      Text(_detected!, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                          onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vehicle Found: Toyota Yaris"))); },
                          child: const Text("View Car Details")
                      )
                    ],
                  ),
                ),
              ).animate().slideY(begin: 1, end: 0),
            ),
          Positioned(top: 50, left: 20, child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white))),
        ],
      ),
    );
  }
}