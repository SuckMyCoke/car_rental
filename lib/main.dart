import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants.dart';
import 'core/routes.dart';

// Auth & Core
import 'modules/auth/auth_wrapper.dart';
import 'modules/auth/login_screen.dart';
import 'modules/home/main_scaffold.dart';

// Rental
import 'modules/rental/car_details_screen.dart';

// Real Smart Features
import 'modules/smart/ekyc_screen.dart';
import 'modules/smart/damage_inspection_screen.dart';
import 'modules/smart/photogrammetry.dart';
import 'modules/smart/ar_simulation_screen.dart'; // Keep AR Viewer (It displays the real model)
import 'modules/smart/plate_scanner_screen.dart';

// Real Booking & Profile
import 'modules/booking/booking_flow_screen.dart';
import 'modules/booking/booking_selection_screen.dart';
import 'modules/booking/my_bookings_screen.dart';
import 'modules/profile/edit_profile_screen.dart';
import 'modules/admin/add_car_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("Firebase Init Error: $e");
  }
  runApp(const SRTCarsApp());
}

class SRTCarsApp extends StatelessWidget {
  const SRTCarsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SRTCars',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: AppColors.textDark),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 0,
          ),
        ),
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        // Core
        AppRoutes.splash: (context) => const AuthWrapper(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.home: (context) => const MainScaffold(),
        AppRoutes.carDetails: (context) => const CarDetailsScreen(),

        // Smart Features (Real)
        AppRoutes.arView: (context) => const ARSimulationScreen(),
        AppRoutes.realEkyc: (context) => const RealEKYCScreen(),
        AppRoutes.realDamageDetection: (context) => const RealDamageDetectionScreen(),
        AppRoutes.plateScanner: (context) => const PlateScannerScreen(),
        AppRoutes.realPhotogrammetry: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return RealPhotogrammetryScreen(carId: args);
        },

        // Functional Features
        AppRoutes.dateSelection: (context) => const DateSelectionScreen(),
        AppRoutes.bookingFlow: (context) => const BookingFlowScreen(),
        AppRoutes.myBookings: (context) => const MyBookingsScreen(),
        AppRoutes.editProfile: (context) => const EditProfileScreen(),
        AppRoutes.addCar: (context) => const AddCarScreen(),
      },
    );
  }
}