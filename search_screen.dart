import 'package:flutter/material.dart';
import 'details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final List<Map<String, String>> allCars = [
    // Electric
    {"n": "Land Cruiser", "p": "190", "i": "assets/images1/land.jpeg", "d": "Electric • 1020hp", "cat": "Electric", "r": "4.9"},
    {"n": "Civic", "p": "210", "i": "assets/images1/civic.jpeg", "d": "Electric • Luxury", "cat": "Electric", "r": "5.0"},
    {"n": "Alto", "p": "250", "i": "assets/images1/alto.jpeg", "d": "Electric • Sport", "cat": "Electric", "r": "4.8"},
    // Petrol
    {"n": "City", "p": "90", "i": "assets/images1/city.jpeg", "d": "Petrol • VTEC Turbo", "cat": "Petrol", "r": "4.7"},
    {"n": "Toyota", "p": "95", "i": "assets/images1/toyota.jpeg", "d": "Petrol • Comfort", "cat": "Petrol", "r": "4.6"},
    {"n": "4x4", "p": "85", "i": "assets/images1/4x4.jpeg", "d": "Petrol • Sedan", "cat": "Petrol", "r": "4.5"},
    // Luxury
    {"n": "BMW", "p": "850", "i": "assets/images1/bmw.jpeg", "d": "Luxury • V12 Engine", "cat": "Luxury", "r": "5.0"},
    {"n": "MG", "p": "720", "i": "assets/images1/mg.jpeg", "d": "Luxury • Handcrafted", "cat": "Luxury", "r": "4.9"},
    {"n": "LC 300", "p": "680", "i": "assets/images1/lc300.jpeg", "d": "Luxury • Executive", "cat": "Luxury", "r": "4.9"},
    // Sports
    {"n": "Ferrari", "p": "1200", "i": "assets/images1/ferrari.jpeg", "d": "Sports • Twin Turbo", "cat": "Sports", "r": "5.0"},
    {"n": "Jeep Sport", "p": "1150", "i": "assets/images1/jeeps.jpeg", "d": "Sports • V10 Power", "cat": "Sports", "r": "5.0"},
    // Note: Thar has been removed from here

    // Jeep
    {"n": "Jeep Wrangler", "p": "180", "i": "assets/images1/jeep.jpeg", "d": "Jeep • 4x4 Off-road", "cat": "Jeep", "r": "4.8"},
    {"n": "Ford", "p": "175", "i": "assets/images1/ford.jpeg", "d": "Jeep • All-Terrain", "cat": "Jeep", "r": "4.7"},
    {"n": "Defender", "p": "220", "i": "assets/images1/defender.jpeg", "d": "Jeep • Rugged Luxury", "cat": "Jeep", "r": "4.9"},
  ];

  List<Map<String, String>> displayedCars = [];
  String selectedCategory = "All";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    displayedCars = allCars;
  }

  void filterLogic(String query) {
    setState(() {
      displayedCars = allCars.where((car) {
        final nameMatch = car['n']!.toLowerCase().contains(query.toLowerCase());

        if (query.isNotEmpty) {
          // Search prioritize ho gi
          return nameMatch;
        } else {
          // Empty search pe category filter chalay ga
          return selectedCategory == "All" || car['cat'] == selectedCategory;
        }
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categories = ["All", "Electric", "Petrol", "Luxury", "Sports", "Jeep"];

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("Discovery",
            style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 24)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: filterLogic,
                decoration: InputDecoration(
                  hintText: "Search your dream car...",
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.indigo, size: 28),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      filterLogic("");
                    },
                  ),
                ),
              ),
            ),
          ),

          // Categories Chips
          SizedBox(
            height: 55,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                bool isSel = selectedCategory == categories[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = categories[index];
                      _searchController.clear();
                      filterLogic("");
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    decoration: BoxDecoration(
                      color: isSel ? Colors.indigo : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: isSel ? [BoxShadow(color: Colors.indigo.withValues(alpha: 0.3), blurRadius: 10)] : [],
                    ),
                    child: Center(
                      child: Text(categories[index],
                          style: TextStyle(
                            color: isSel ? Colors.white : const Color(0xFF64748B),
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          )),
                    ),
                  ),
                );
              },
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(25, 25, 25, 10),
            child: Text("Results", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          ),

          // Search Result Cards
          Expanded(
            child: displayedCars.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: displayedCars.length,
              itemBuilder: (context, index) => _buildCarResultCard(displayedCars[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarResultCard(Map<String, String> car) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => DetailsScreen(carData: car))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(car['i']!, height: 90, width: 110, fit: BoxFit.cover),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(car['n']!, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF1E293B))),
                  const SizedBox(height: 4),
                  Text(car['d']!, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text("\$${car['p']}", style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.w900, fontSize: 18)),
                      const Text("/day", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.car_crash_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 10),
          Text("No cars found!", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 18)),
        ],
      ),
    );
  }
}