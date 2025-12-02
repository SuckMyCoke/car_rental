import 'package:flutter/material.dart';
import '../../services/services.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: "Phone Number", border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  setState(() => _isLoading = true);
                  final uid = AuthService.currentUser?.uid;
                  if (uid != null) {
                    await DatabaseService.updateUserProfile(uid, {
                      'displayName': _nameCtrl.text,
                      'phoneNumber': _phoneCtrl.text
                    });
                    if (mounted) Navigator.pop(context);
                  }
                },
                child: _isLoading ? const CircularProgressIndicator() : const Text("Save Changes"),
              ),
            )
          ],
        ),
      ),
    );
  }
}