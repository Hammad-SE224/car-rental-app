import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Direct Firestore use for reliability
import '../nav_wrapper.dart';

class DetailsScreen extends StatefulWidget {
  final Map<String, String> carData;
  const DetailsScreen({super.key, required this.carData});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool _isBooking = false;

  // --- 1. Form Popup (Firestore Integration with Modern Calendar) ---
  void _showDetailsForm(BuildContext context) {
    final TextEditingController dateController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setPopupState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            title: const Column(
              children: [
                Icon(Icons.assignment_turned_in_rounded, color: Colors.indigo, size: 40),
                SizedBox(height: 10),
                Text("Finalize Booking", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Please provide your details to confirm the ride.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 20),

                // Professional Calendar Field
                TextField(
                  controller: dateController,
                  readOnly: true,
                  onTap: () async {
                    // Modern Professional Calendar Picker
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2027),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Colors.indigo, // header background color
                              onPrimary: Colors.white, // header text color
                              onSurface: Colors.indigo, // body text color
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(foregroundColor: Colors.indigo),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setPopupState(() => dateController.text = "${picked.day}/${picked.month}/${picked.year}");
                    }
                  },
                  decoration: InputDecoration(
                      labelText: "Select Pick-up Date",
                      filled: true,
                      fillColor: Colors.indigo.withOpacity(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.calendar_month_rounded, color: Colors.indigo)
                  ),
                ),
                const SizedBox(height: 15),

                // Phone Number Field
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                      labelText: "Your Phone Number",
                      filled: true,
                      fillColor: Colors.indigo.withOpacity(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.phone_android_rounded, color: Colors.indigo)
                  ),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                onPressed: _isBooking ? null : () async {
                  if (dateController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                    setPopupState(() => _isBooking = true);

                    // Preparing Final Data for Firestore
                    Map<String, dynamic> bookingData = {
                      "carName": widget.carData['n'],
                      "price": widget.carData['p'],
                      "bookingDate": dateController.text,
                      "phone": phoneController.text,
                      "userName": FirebaseAuth.instance.currentUser?.displayName ?? "User",
                      "userEmail": FirebaseAuth.instance.currentUser?.email ?? "Guest",
                      "status": "Confirmed",
                      "image": widget.carData['i'],
                      "createdAt": FieldValue.serverTimestamp(),
                    };

                    try {
                      // Final Save to Firebase Collection 'bookings'
                      await FirebaseFirestore.instance.collection('bookings').add(bookingData);

                      setPopupState(() => _isBooking = false);
                      if (mounted) {
                        Navigator.pop(ctx);
                        _showSuccessPopup(context);
                      }
                    } catch (e) {
                      setPopupState(() => _isBooking = false);
                      debugPrint("Error saving booking: $e");
                    }
                  }
                },
                child: _isBooking
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Confirm Ride", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- 2. Success Popup (Toast style) ---
  void _showSuccessPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const NavWrapper()),
                  (route) => false,
            );
          }
        });

        return Align(
          alignment: const Alignment(0, -0.8),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 5))]
              ),
              child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Text("Booking Saved ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ]
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.indigo, size: 20),
            onPressed: () => Navigator.pop(context)
        ),
        title: const Text("Car Details", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w900)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Premium Image Display
            Container(
              height: 250, width: double.infinity, margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))]
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: Image.asset(widget.carData['i']!, fit: BoxFit.cover)
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.carData['n']!, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                    const SizedBox(height: 5),
                    const Row(children: [
                      Icon(Icons.star, color: Colors.orange, size: 16),
                      Text(" 4.9 (120+ Reviews)", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                    ]),
                  ]),
                  Column(children: [
                    Text("\$${widget.carData['p']}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.indigo)),
                    const Text("/day", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ]),
                ]),

                const SizedBox(height: 30),
                const Text("Specifications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                const SizedBox(height: 15),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  _specBox(Icons.speed_rounded, "320km/h", "Max Speed"),
                  _specBox(Icons.airline_seat_recline_extra_rounded, "4 Seats", "Capacity"),
                  _specBox(Icons.local_gas_station_rounded, widget.carData['cat'] ?? "Petrol", "Fuel Type"),
                ]),

                const SizedBox(height: 30),
                const Text("Features", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                const SizedBox(height: 10),
                const Text("Enjoy premium features like self-driving, heated seats, and a panoramic sunroof for your ultimate comfort.",
                    style: TextStyle(color: Colors.grey, height: 1.5, fontSize: 13)),
                const SizedBox(height: 100), // Spacing for bottom button
              ]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(25, 10, 25, 30),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 60),
              elevation: 5,
              shadowColor: Colors.indigo.withOpacity(0.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
          ),
          onPressed: () => _showBookingSheet(context),
          child: const Text("BOOK THIS RIDE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.1)),
        ),
      ),
    );
  }

  Widget _specBox(IconData i, String t, String sub) => Container(
    width: 100, padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.indigo.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.02), blurRadius: 10)]
    ),
    child: Column(children: [
      Icon(i, color: Colors.indigo, size: 24),
      const SizedBox(height: 8),
      Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
      const SizedBox(height: 2),
      Text(sub, style: const TextStyle(fontSize: 9, color: Colors.grey)),
    ]),
  );

  void _showBookingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (c) => Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40))
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 25),
          const Text("Ready to Drive?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Text("Confirm booking for ${widget.carData['n']} and enjoy your journey.",
              textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))
              ),
              onPressed: () { Navigator.pop(context); _showDetailsForm(context); },
              child: const Text("PROCEED TO DETAILS", style: TextStyle(fontWeight: FontWeight.bold))
          ),
          const SizedBox(height: 10),
        ]),
      ),
    );
  }
}