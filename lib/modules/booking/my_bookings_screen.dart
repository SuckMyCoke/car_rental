import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../services/services.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return const Scaffold(body: Center(child: Text("Please login")));

    return Scaffold(
      appBar: AppBar(title: const Text("My Bookings")),
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseService.getUserBookings(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.car_rental, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text("No bookings yet.", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Browse Cars")
                  )
                ],
              ),
            );
          }

          final bookings = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 16),
            itemBuilder: (ctx, i) {
              final data = bookings[i].data() as Map<String, dynamic>;
              // Format dates safely
              final start = (data['startDate'] as Timestamp?)?.toDate();
              final end = (data['endDate'] as Timestamp?)?.toDate();
              final dateStr = start != null && end != null
                  ? "${DateFormat('MMM dd').format(start)} - ${DateFormat('MMM dd').format(end)}"
                  : "Date N/A";

              return Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        data['imageUrl'] ?? "",
                        width: 80, height: 80, fit: BoxFit.cover,
                        errorBuilder: (_,__,___) => Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.car_repair)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${data['carMake']} ${data['carModel']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                                child: Text(data['status'] ?? 'Active', style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                              const Spacer(),
                              Text("RM${data['total']?.toStringAsFixed(2) ?? '0'}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}