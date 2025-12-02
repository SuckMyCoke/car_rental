import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';

class ARSimulationScreen extends StatelessWidget {
  const ARSimulationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final carData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fake Camera Background
          Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.black, Colors.transparent, Colors.black],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter
                )
            ),
            child: const Center(
              child: Opacity(
                  opacity: 0.3,
                  child: Text("Camera Feed Active\n(Simulated AR)",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white))
              ),
            ),
          ),

          // Simulated 3D Object
          Center(
            child: Container(
              width: 250, height: 150,
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.blue.shade300.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(-10, -10)
                    )
                  ],
                  border: Border.all(color: Colors.white.withOpacity(0.2))
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.directions_car, color: Colors.white, size: 48),
                    const SizedBox(height: 8),
                    Text("3D Model:\n${carData?['model'] ?? 'Car'}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                  ],
                ),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(end: 10, duration: 2000.ms),
          ),

          Positioned(
              top: 50, left: 20,
              child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white)
              )
          ),
        ],
      ),
    );
  }
}