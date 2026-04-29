class BookingModel {
  final String carName;
  final String price;
  final String date;
  final String phone;
  final String userEmail;
  final String status; // Pending, Confirmed, etc.
  final String image;

  BookingModel({
    required this.carName,
    required this.price,
    required this.date,
    required this.phone,
    required this.userEmail,
    required this.status,
    required this.image,
  });

  // Firestore ke liye Map banana
  Map<String, dynamic> toMap() {
    return {
      'carName': carName,
      'price': price,
      'date': date,
      'phone': phone,
      'userEmail': userEmail,
      'status': status,
      'image': image,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  // Firestore se data lene ke liye
  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      carName: map['carName'] ?? '',
      price: map['price'] ?? '',
      date: map['date'] ?? '',
      phone: map['phone'] ?? '',
      userEmail: map['userEmail'] ?? '',
      status: map['status'] ?? 'Pending',
      image: map['image'] ?? '',
    );
  }
}