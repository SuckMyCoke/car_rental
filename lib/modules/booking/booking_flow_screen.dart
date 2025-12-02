import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../services/services.dart';

class BookingFlowScreen extends StatefulWidget {
  const BookingFlowScreen({super.key});
  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  int _step = 0;
  bool _loading = false;
  bool _isVerified = false;
  late Map<String, dynamic> _bookingData;
  bool _init = false;

  @override
  void didChangeDependencies() {
    if (!_init) {
      _bookingData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _init = true;
    }
    super.didChangeDependencies();
  }

  // --- STEP 1: EKYC ---
  Future<void> _handleVerification() async {
    // Navigate to Real eKYC Screen and wait for result (true/false)
    final result = await Navigator.pushNamed(context, AppRoutes.realEkyc);

    if (result == true) {
      setState(() {
        _isVerified = true;
        _step++; // Move to payment
      });
    }
  }

  // --- STEP 2: PAYMENT & CONFIRM ---
  Future<void> _confirmBooking() async {
    setState(() => _loading = true);
    try {
      await DatabaseService.createBooking(
          carData: _bookingData,
          total: _bookingData['calculatedTotal'],
          startDate: _bookingData['startDate'],
          endDate: _bookingData['endDate']
      );
      if(mounted) setState(() { _loading = false; _step++; });
    } catch (e) {
      setState(() => _loading = false);
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Booking Failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_step == 0 ? "Identity Check" : _step == 1 ? "Payment" : "Confirmed")),
      body: _step == 0
          ? _buildEKYC()
          : _step == 1
          ? _buildPayment()
          : _buildSuccess(),
    );
  }

  Widget _buildEKYC() => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        const Icon(Icons.shield, size: 80, color: AppColors.primary),
        const SizedBox(height: 24),
        const Text("Identity Verification", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const Text("We need to scan your ID to verify your identity.", textAlign: TextAlign.center, style: TextStyle(color: AppColors.textLight)),
        const Spacer(),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _handleVerification, child: const Text("Start Scanning"))),
      ],
    ),
  );

  Widget _buildPayment() => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        const Text("Checkout", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        ListTile(
          title: const Text("Total Cost"),
          trailing: Text("RM${(_bookingData['calculatedTotal']).toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        const Spacer(),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _loading ? null : _confirmBooking, child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text("Pay Now"))),
      ],
    ),
  );

  Widget _buildSuccess() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, size: 100, color: AppColors.accentGreen),
        const Text("Booking Confirmed!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 48),
        OutlinedButton(onPressed: () => Navigator.popUntil(context, (route) => route.isFirst), child: const Text("Back to Home")),
      ],
    ),
  );
}