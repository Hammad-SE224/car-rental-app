import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'booking_screen.dart';
import '../nav_wrapper.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  // Text Controllers for Add Car Dialog
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController typeController = TextEditingController();

  // --- FUNCTION: ADD NEW CAR TO FIREBASE ---
  Future<void> _addNewCar() async {
    // Basic Validation
    if (nameController.text.isEmpty || priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter Car Name and Price!")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('cars').add({
        'carName': nameController.text.trim(),
        'price': priceController.text.trim(),
        'type': typeController.text.isEmpty ? "Premium" : typeController.text.trim(),
        'rating': "5.0",
        'image': "assets/images1/mehran.jpeg", // FIXED: Default image path for all new cars
        'isDeleted': false, // Soft delete flag (Home screen par nazar ayegi)
        'createdAt': FieldValue.serverTimestamp(), // Sorting ke liye zaroori hai
      });

      // Clear fields and close dialog
      nameController.clear();
      priceController.clear();
      typeController.clear();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.green, content: Text("Car added successfully!")),
        );
      }
    } catch (e) {
      debugPrint("Error adding car: $e");
    }
  }

  // --- FUNCTION: HIDE CAR (SOFT DELETE) ---
  Future<void> _softDeleteCar(String docId, String carName) async {
    bool confirm = await _showConfirmDelete(carName);
    if (confirm) {
      await FirebaseFirestore.instance.collection('cars').doc(docId).update({
        'isDeleted': true, // Firebase se delete nahi hogi, bas users se hide ho jayegi
      });
    }
  }

  // --- HELPER: CONFIRMATION DIALOG ---
  Future<bool> _showConfirmDelete(String name) async {
    return await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove Car?"),
        content: Text("Are you sure you want to remove '$name' from the Home Screen? It will remain in the database."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Remove", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),

      // Floating Action Button to Add New Car
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCarDialog(),
        backgroundColor: const Color(0xFF1E3C72),
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: const Text("Add New Car", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),

      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        centerTitle: true,
        title: const Text("ADMIN DASHBOARD",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ),

      drawer: Drawer(
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1E3C72)),
              accountName: Text("Hammad Admin", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              accountEmail: Text("admin@drivepremium.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.admin_panel_settings, color: Color(0xFF1E3C72), size: 45),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.indigo),
              title: const Text("Booking History", style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (c) => const BookingScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context, MaterialPageRoute(builder: (c) => const NavWrapper()), (route) => false,
                );
              },
            ),
            const Spacer(),
            const Padding(padding: EdgeInsets.all(20.0), child: Text("System Version 1.1.0", style: TextStyle(color: Colors.grey, fontSize: 12))),
          ],
        ),
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // --- STATS SECTION ---
            _buildStatsHeader(),

            const Padding(
              padding: EdgeInsets.fromLTRB(25, 10, 25, 15),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Fleet Management",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3C72))),
              ),
            ),

            // --- REAL-TIME FLEET LIST ---
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('cars')
                  .where('isDeleted', isEqualTo: false) // Sirf active cars
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()));
                }

                var carDocs = snapshot.data?.docs ?? [];

                if (carDocs.isEmpty) {
                  return _buildEmptyFleetState();
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: carDocs.length,
                  itemBuilder: (ctx, i) {
                    var data = carDocs[i].data() as Map<String, dynamic>;
                    String docId = carDocs[i].id;
                    return _buildCarManageTile(data, docId);
                  },
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // --- UI WIDGETS ---

  Widget _buildStatsHeader() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
      builder: (context, snapshot) {
        var docs = snapshot.data?.docs ?? [];
        double revenue = 0;
        for (var d in docs) {
          var data = d.data() as Map<String, dynamic>;
          revenue += double.tryParse(data['price'].toString()) ?? 0.0;
        }

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2A5298), Color(0xFFF4F7FA)],
                stops: [0.5, 0.5]
            ),
          ),
          child: Row(
            children: [
              _buildStatCard("Total Orders", "${docs.length}", Icons.shopping_cart_checkout, Colors.orange),
              const SizedBox(width: 15),
              _buildStatCard("Total Revenue", "\$${revenue.toStringAsFixed(0)}", Icons.payments_outlined, Colors.green),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCarManageTile(Map<String, dynamic> data, String docId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.directions_car_filled, color: Colors.indigo),
        ),
        title: Text(data['carName'] ?? "Unnamed Car", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text("${data['type']} • \$${data['price']}/day", style: const TextStyle(color: Colors.grey)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => _softDeleteCar(docId, data['carName'] ?? "this car"),
        ),
      ),
    );
  }

  void _showAddCarDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Add New Car to Fleet", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Car Name", prefixIcon: Icon(Icons.drive_file_rename_outline))),
            const SizedBox(height: 10),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: "Price per Day", prefixIcon: Icon(Icons.attach_money)), keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            TextField(controller: typeController, decoration: const InputDecoration(labelText: "Category (e.g. SUV, Sport)", prefixIcon: Icon(Icons.category_outlined))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: _addNewCar,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3C72), foregroundColor: Colors.white),
            child: const Text("Add to Fleet"),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 15),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFleetState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.car_rental_outlined, size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 10),
          const Text("No extra cars added yet.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}