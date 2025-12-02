import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';

class CarDetailsScreen extends StatelessWidget {
  const CarDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final carData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final bool isArReady = carData['arReady'] == true;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300, pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    carData['imageUrl'] ?? "", fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text("${carData['make']} ${carData['model']}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        Text("RM${carData['pricePerHour']}/hr", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18)),
                      ]),
                      const SizedBox(height: 24),

                      // Smart Feature Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: isArReady
                                  ? () => Navigator.pushNamed(context, AppRoutes.arView, arguments: carData)
                                  : null, // Disable if not ready
                              icon: const Icon(Icons.view_in_ar),
                              label: Text(isArReady ? "View in AR" : "No 3D Model"),
                              style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: BorderSide(color: isArReady ? AppColors.primary : Colors.grey)
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pushNamed(context, AppRoutes.realDamageDetection),
                              icon: const Icon(Icons.search),
                              label: const Text("AI Inspect"),
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: const BorderSide(color: Colors.red), foregroundColor: Colors.red),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(carData['description'] ?? "No details.", style: const TextStyle(color: AppColors.textLight, height: 1.5)),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              )
            ],
          ),
          Positioned(
            bottom: 24, left: 24, right: 24,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.dateSelection, arguments: carData),
              child: const Text("Book Now", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}