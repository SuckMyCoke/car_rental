import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/services.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.all(24.0), child: Text("Owner Dashboard", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text("My Fleet", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      // UPDATED BUTTON
                      IconButton(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.addCar),
                          icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 32)
                      )
                    ]),
                    const SizedBox(height: 16),

                    // REAL DATA LIST
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        // Query cars owned by current user
                        stream: DatabaseService.carsRef
                            .where('ownerId', isEqualTo: AuthService.currentUser?.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                          final cars = snapshot.data!.docs;

                          if (cars.isEmpty) {
                            return const Center(child: Text("You haven't listed any cars yet."));
                          }

                          return ListView.builder(
                            itemCount: cars.length,
                            itemBuilder: (context, index) {
                              final data = cars[index].data() as Map<String, dynamic>;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: data['imageUrl'] != ""
                                      ? Image.network(data['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                                      : const Icon(Icons.car_rental),
                                  title: Text("${data['make']} ${data['model']}"),
                                  subtitle: Text(data['status']),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.camera_alt_outlined),
                                    onPressed: () {
                                      // Open Optional 3D Scan for this specific car
                                      Navigator.pushNamed(
                                          context,
                                          AppRoutes.realPhotogrammetry,
                                          arguments: cars[index].id
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}