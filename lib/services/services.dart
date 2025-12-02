import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static Stream<User?> get userStream => _auth.authStateChanges();
  static User? get currentUser => _auth.currentUser;

  static Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> register(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }
}

class DatabaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String _appId = 'srtcars-default';

  static CollectionReference get carsRef =>
      _db.collection('artifacts/$_appId/public/data/cars');

  static CollectionReference userBookingsRef(String uid) =>
      _db.collection('artifacts/$_appId/users/$uid/bookings');

  // --- SEEDING ---
  static Future<void> seedData() async {
    try {
      final snapshot = await carsRef.limit(1).get();
      if (snapshot.docs.isEmpty) {
        // ... (Seed logic from previous steps) ...
      }
    } catch (e) {
      print("Seeding error: $e");
    }
  }

  // --- CAR LISTING ---
  static Future<String> uploadCarImage(File imageFile, String carId, String imageName) async {
    final ref = _storage.ref().child('cars/$carId/$imageName.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  static Future<void> addCarListing({
    required String make, required String model, required int year,
    required double price, required String description,
    required List<String> features, File? imageFile,
  }) async {
    final user = AuthService.currentUser;
    if (user == null) throw Exception("Must be logged in");

    final docRef = carsRef.doc();
    String imageUrl = "";
    if (imageFile != null) {
      imageUrl = await uploadCarImage(imageFile, docRef.id, 'hero_image');
    }

    await docRef.set({
      "id": docRef.id, // Store ID inside doc for easier access
      "ownerId": user.uid,
      "make": make, "model": model, "year": year,
      "pricePerHour": price, "description": description,
      "features": features, "imageUrl": imageUrl,
      "location": "Kuala Lumpur", "status": "Available", "rating": 5.0,
      "arReady": false,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  // --- 3D SCAN ---
  static Future<void> uploadPhotogrammetryDataset(String carId, List<File> photos) async {
    int index = 0;
    for (var photo in photos) {
      final ref = _storage.ref().child('cars/$carId/3d_raw/img_$index.jpg');
      await ref.putFile(photo);
      index++;
    }
    await carsRef.doc(carId).update({"arStatus": "Processing"});
  }

  // --- BOOKING & AVAILABILITY ---
  static Future<bool> checkAvailability(String carId, DateTime start, DateTime end) async {
    final query = await _db.collectionGroup('bookings')
        .where('carId', isEqualTo: carId)
        .where('status', whereIn: ['Confirmed', 'Active'])
        .get();

    for (var doc in query.docs) {
      final data = doc.data();
      if (data['startDate'] == null || data['endDate'] == null) continue;
      DateTime bookedStart = (data['startDate'] as Timestamp).toDate();
      DateTime bookedEnd = (data['endDate'] as Timestamp).toDate();
      // Overlap check
      if (start.isBefore(bookedEnd) && end.isAfter(bookedStart)) return false;
    }
    return true;
  }

  static Future<void> createBooking({
    required Map<String, dynamic> carData,
    required double total,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    await userBookingsRef(uid).add({
      "carId": carData['id'],
      "carMake": carData['make'],
      "carModel": carData['model'],
      "total": total,
      "status": "Confirmed",
      "imageUrl": carData['imageUrl'],
      "startDate": Timestamp.fromDate(startDate),
      "endDate": Timestamp.fromDate(endDate),
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot> getUserBookings(String uid) {
    return userBookingsRef(uid).orderBy('createdAt', descending: true).snapshots();
  }

  // --- USER PROFILE ---
  static Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('artifacts/$_appId/users').doc(uid).set(data, SetOptions(merge: true));
  }
}