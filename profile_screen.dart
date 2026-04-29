import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Logout Function logic
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images1/car1.jpeg'), // Aapki car1.jpeg image
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 30),

                // 1. Profile Header
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.indigo,
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : const AssetImage('assets/images1/car.jpeg') as ImageProvider,
                        child: user?.photoURL == null
                            ? const Icon(Icons.person, size: 65, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      user?.displayName ?? "Guest User",
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      user?.email ?? "No Email Found",
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // 2. Settings List with Glass Effect
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92), // Glass effect background
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 15, offset: const Offset(0, 8))
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildProfileItem(context, Icons.payment_rounded, "Payment Methods", "Manage your cards"),
                        _buildProfileItem(context, Icons.notifications_none_rounded, "Notifications", "Alerts & updates"),
                        _buildProfileItem(context, Icons.security_rounded, "Security", "Password & biometric"),
                        _buildProfileItem(context, Icons.help_outline_rounded, "Help Center", "Support & FAQ"),
                        _buildProfileItem(context, Icons.info_outline_rounded, "About DrivePremium", "Version 1.0.1"),

                        const Divider(height: 1, indent: 20, endIndent: 20),

                        // Logout Tile
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.logout_rounded, color: Colors.red),
                          ),
                          title: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                          onTap: () => _logout(context),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.indigo.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.indigo),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileDetailScreen(title: title)),
        );
      },
    );
  }
}

// --- Detail Screen with Dummy Content ---
class ProfileDetailScreen extends StatelessWidget {
  final String title;
  const ProfileDetailScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images1/car1.jpeg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black87, BlendMode.darken),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(25),
              ),
              child: _buildDetailContent(title),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailContent(String title) {
    if (title == "Payment Methods") {
      return Column(
        children: [
          _dummyTile(Icons.credit_card, "Visa Card", "**** 4242"),
          _dummyTile(Icons.account_balance_wallet, "JazzCash", "0300-XXXXXXX"),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: () {},
            child: const Text("Add New Card", style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    } else if (title == "Notifications") {
      return Column(
        children: [
          _dummySwitch("Booking Alerts", true),
          _dummySwitch("Discount Notifications", false),
          _dummySwitch("App Updates", true),
        ],
      );
    } else if (title == "Help Center") {
      return ListView(
        children: [
          _dummyFaq("How to rent?", "Pick a car, choose dates, and pay."),
          _dummyFaq("Cancellation Policy", "Free cancellation within 24 hours."),
          _dummyFaq("Contact Support", "Email: help@drivepremium.com"),
        ],
      );
    } else {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car, size: 80, color: Colors.indigo),
          SizedBox(height: 20),
          Text("Drive Premium v1.0.1", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("A premium car rental experience in Pakistan.", textAlign: TextAlign.center),
        ],
      );
    }
  }

  Widget _dummyTile(IconData i, String t, String s) => ListTile(
    leading: Icon(i, color: Colors.indigo),
    title: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Text(s),
  );

  Widget _dummySwitch(String t, bool v) => SwitchListTile(
    title: Text(t),
    value: v,
    onChanged: (val) {},
    activeColor: Colors.indigo,
  );

  Widget _dummyFaq(String q, String a) => ExpansionTile(
    title: Text(q, style: const TextStyle(fontWeight: FontWeight.bold)),
    children: [Padding(padding: const EdgeInsets.all(15), child: Text(a))],
  );
}