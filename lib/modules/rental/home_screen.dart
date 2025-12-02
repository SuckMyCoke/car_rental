import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../services/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Find your drive", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text("Available near Kuala Lumpur", style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                  ],
                ),
                CircleAvatar(backgroundColor: Colors.grey[200], child: const Icon(Icons.notifications, color: AppColors.textDark)),
              ],
            ),
          ),

          // Search Bar (Fixed)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search 'Toyota', 'SUV'...",
                prefixIcon: const Icon(Icons.search),
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),

          // Car List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: DatabaseService.carsRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData) return const Center(child: Text("No cars found"));

                // Filter Logic
                final cars = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final make = (data['make'] ?? '').toString().toLowerCase();
                  final model = (data['model'] ?? '').toString().toLowerCase();
                  return make.contains(_searchQuery) || model.contains(_searchQuery);
                }).toList();

                if (cars.isEmpty) return const Center(child: Text("No matching cars found"));

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: cars.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final car = cars[index].data() as Map<String, dynamic>;
                    car['id'] = cars[index].id;

                    return GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.carDetails, arguments: car),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: Image.network(
                                    car['imageUrl'] ?? "", height: 180, width: double.infinity, fit: BoxFit.cover,
                                    errorBuilder: (c,o,s) => Container(height: 180, color: Colors.grey[200], child: const Icon(Icons.car_repair)),
                                  ),
                                ),
                                if (car['arReady'] == true)
                                  Positioned(
                                    bottom: 10, left: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.9), borderRadius: BorderRadius.circular(8)),
                                      child: const Row(children: [Icon(Icons.view_in_ar, color: Colors.white, size: 14), SizedBox(width: 4), Text("AR Ready", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))]),
                                    ),
                                  )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text("${car['make']} ${car['model']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    Text(car['location'] ?? "Kuala Lumpur", style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
                                  ]),
                                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                    Text("RM${car['pricePerHour']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                    const Text("/hr", style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                                  ])
                                ],
                              ),
                            )
                          ],
                        ),
                      ).animate().fadeIn().slideY(begin: 0.1),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}