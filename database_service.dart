import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Booking ko Firestore mein save karna
  Future<void> saveBooking(Map<String, dynamic> bookingData) async {
    try {
      // 'bookings' naam ki collection mein data add hoga
      await _db.collection('bookings').add(bookingData);
    } catch (e) {
      print("Firestore Error: $e");
    }
  }

  // Admin Dashboard ke liye bookings ka real-time data lena
  Stream<QuerySnapshot> getBookingsStream() {
    return _db.collection('bookings').snapshots();
  }
}