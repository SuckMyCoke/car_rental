import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';
import '../../services/services.dart';

class DateSelectionScreen extends StatefulWidget {
  const DateSelectionScreen({super.key});

  @override
  State<DateSelectionScreen> createState() => _DateSelectionScreenState();
}

class _DateSelectionScreenState extends State<DateSelectionScreen> {
  DateTimeRange? _selectedRange;
  bool _isChecking = false;
  bool _isAvailable = false;
  String? _availabilityMessage;

  Future<void> _pickDateRange() async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primary,
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedRange = picked;
        _isChecking = true;
        _availabilityMessage = null;
      });
      _checkAvailability();
    }
  }

  Future<void> _checkAvailability() async {
    final carData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final isFree = await DatabaseService.checkAvailability(
        carData['id'],
        _selectedRange!.start,
        _selectedRange!.end
    );

    if (mounted) {
      setState(() {
        _isChecking = false;
        _isAvailable = isFree;
        _availabilityMessage = isFree
            ? "Car is available!"
            : "Sorry, the car is booked for these dates.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final carData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // Calculate cost if range selected
    double totalCost = 0;
    int days = 0;
    if (_selectedRange != null) {
      days = _selectedRange!.duration.inDays + 1; // inclusive
      // Assuming pricePerHour is actually used as a base unit, let's say 1 day = 10 hours of rental for calculation simplicity
      // Or if your data has pricePerDay, use that. Let's use 10 hours/day logic for now.
      totalCost = (carData['pricePerHour'] * 10) * days;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Select Dates")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("When do you need the car?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Date Picker Card
            GestureDetector(
              onTap: _pickDateRange,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.primary),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Rental Period", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(
                          _selectedRange == null
                              ? "Select Dates"
                              : "${_selectedRange!.start.day}/${_selectedRange!.start.month} - ${_selectedRange!.end.day}/${_selectedRange!.end.month}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Availability Status
            if (_isChecking)
              const Center(child: CircularProgressIndicator())
            else if (_availabilityMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: _isAvailable ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _isAvailable ? Colors.green : Colors.red)
                ),
                child: Text(
                  _availabilityMessage!,
                  style: TextStyle(color: _isAvailable ? Colors.green.shade800 : Colors.red.shade800, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),

            const Spacer(),

            // Summary & Button
            if (_isAvailable && _selectedRange != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("$days Days Total", style: const TextStyle(color: Colors.grey)),
                  Text("RM${totalCost.toStringAsFixed(2)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Pass dates and cost to Booking Flow
                    Navigator.pushNamed(
                        context,
                        AppRoutes.bookingFlow,
                        arguments: {
                          ...carData,
                          'startDate': _selectedRange!.start,
                          'endDate': _selectedRange!.end,
                          'calculatedTotal': totalCost
                        }
                    );
                  },
                  child: const Text("Proceed to Verification"),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}