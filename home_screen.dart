import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'details_screen.dart';
import 'admin_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, String>> oldCars = [
    {"n": "Mehran", "p": "150", "r": "4.9", "t": "Electric", "i": "assets/images1/mehran.jpeg"},
    {"n": "Cultus", "p": "125", "r": "4.8", "t": "Sport", "i": "assets/images1/cultus.jpeg"},
    {"n": "Fx Special", "p": "450", "r": "5.0", "t": "Supercar", "i": "assets/images1/fx.jpeg"},
    {"n": "Suzuki Bolan", "p": "140", "r": "4.7", "t": "Van", "i": "assets/images1/suzuki.jpeg"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      drawer: _buildModernDrawer(),
      appBar: _buildTransparentAppBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images1/car1.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.2),
                Colors.black.withValues(alpha: 0.5),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Text(
                      "Explore Our\nLuxury Collection",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),

                  _buildPromoBanner(),

                  _buildSectionTitle("Premium Fleet"),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('cars')
                        .where('isDeleted', isEqualTo: false)
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      List<Map<String, String>> displayList = List.from(oldCars);

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 380,
                          child: Center(child: CircularProgressIndicator(color: Colors.white)),
                        );
                      }

                      if (snapshot.hasData && snapshot.data != null) {
                        for (var doc in snapshot.data!.docs) {
                          var data = doc.data() as Map<String, dynamic>;
                          displayList.add({
                            "n": data['carName']?.toString() ?? "New Car",
                            "p": data['price']?.toString() ?? "0",
                            "r": data['rating']?.toString() ?? "5.0",
                            "t": data['type']?.toString() ?? "Added",
                            "i": data['image']?.toString() ?? "assets/images1/mehran.jpeg",
                          });
                        }
                      }

                      return SizedBox(
                        height: 390,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          physics: const BouncingScrollPhysics(),
                          itemCount: displayList.length,
                          itemBuilder: (ctx, i) => SizedBox(width: 280, child: CornerAnimatedCard(car: displayList[i])),
                        ),
                      );
                    },
                  ),

                  _buildSectionTitle("Trust & Safety"),
                  _buildExtraSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildTransparentAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.menu_open_rounded, color: Colors.white, size: 30),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 10),
      ],
      title: const Text("DRIVE PREMIUM",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 22)),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      padding: const EdgeInsets.all(25),
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF334155)]),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 8))],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("SUMMER DISCOUNT", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(height: 5),
          Text("Flat 30% Off", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28)),
          Text("On all premium sedan cars", style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildExtraSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_user_rounded, color: Colors.white, size: 35),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              "All cars are sanitized and GPS enabled for your safety.",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 30, 25, 15),
      child: Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
    );
  }

  Widget _buildModernDrawer() {
    return Drawer(
      width: 280,
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF1A237E)),
            accountName: Text("Hammad Admin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: Text("admin@drivepremium.com"),
            currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.admin_panel_settings, color: Color(0xFF1A237E), size: 35)
            ),
          ),
          // Sirf Admin Panel rakha gaya hai
          _drawerItem(Icons.grid_view_rounded, "Admin Panel", () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (c) => const AdminPanel()));
          }),
          const Spacer(),

          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("Drive Premium v1.0", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  ListTile _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
      onTap: onTap,
    );
  }
}

class CornerAnimatedCard extends StatefulWidget {
  final Map<String, String> car;
  const CornerAnimatedCard({required this.car, super.key});
  @override
  State<CornerAnimatedCard> createState() => _CornerAnimatedCardState();
}

class _CornerAnimatedCardState extends State<CornerAnimatedCard> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        Navigator.push(context, MaterialPageRoute(builder: (c) => DetailsScreen(carData: widget.car)));
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 15, bottom: 20, left: 10, top: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: _isPressed ? 0.05 : 0.1),
                blurRadius: 15,
                offset: const Offset(0, 10)
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                child: Hero(tag: widget.car['n']!, child: Image.asset(widget.car['i']!, width: double.infinity, fit: BoxFit.cover)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.car['n']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                      Row(children: [const Icon(Icons.star, color: Colors.orange, size: 16), Text(" ${widget.car['r']}", style: const TextStyle(color: Colors.black87))]),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(widget.car['t']!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("\$${widget.car['p']}/d", style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.w900, fontSize: 20)),
                      const CircleAvatar(backgroundColor: Color(0xFF1A237E), radius: 16, child: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}