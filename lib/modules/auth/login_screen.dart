import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants.dart';
import '../../services/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;
  bool _isRegister = false;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      if (_isRegister) {
        await AuthService.register(_emailCtrl.text.trim(), _passCtrl.text.trim());
      } else {
        await AuthService.login(_emailCtrl.text.trim(), _passCtrl.text.trim());
      }
      // Navigation is handled automatically by AuthWrapper stream
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error)
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_car_filled, size: 80, color: AppColors.primary)
                  .animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 16),
              Text("SRTCars",
                  style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)),
              Text("Rent. Drive. Experience.",
                  style: GoogleFonts.inter(fontSize: 16, color: AppColors.textLight)),
              const SizedBox(height: 48),

              // Email Field
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email)
                ),
              ),
              const SizedBox(height: 16),

              // Password Field
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock)
                ),
              ),
              const SizedBox(height: 24),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(_isRegister ? "Register" : "Login"),
                ),
              ),

              // Toggle Mode
              TextButton(
                onPressed: () => setState(() => _isRegister = !_isRegister),
                child: Text(_isRegister ? "Already have an account? Login" : "New here? Register"),
              )
            ],
          ),
        ),
      ),
    );
  }
}