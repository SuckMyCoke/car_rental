import 'package:flutter/material.dart';
import '../../services/services.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(AuthService.currentUser?.email ?? "Guest User"),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () => AuthService.logout(),
            icon: const Icon(Icons.logout),
            label: const Text("Sign Out"),
            style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red)
            ),
          )
        ],
      ),
    );
  }
}