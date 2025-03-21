import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/mvp/penginapan-tab/Rekomended-tab.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/mvp/penginapan-tab/populer-tab.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/mvp/penginapan-tab/semua-tab.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/mvp/penginapan-tab/terdekat-tab.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/mvp/penginapan-tab/warlok-tab.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/mvp/penginapan-tab/dashboard/dashboard_warlog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HotelPage extends StatefulWidget {
  const HotelPage({super.key});

  @override
  State<HotelPage> createState() => _HotelPageState();
}

class _HotelPageState extends State<HotelPage>
    with SingleTickerProviderStateMixin {
  final screens = [
    SemuaTab(),
    PopulerTab(),
    TerdekatTab(),
    RekomendedTab(),
    WarlokTab(),
  ];

  bool _isWarlok = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkWarlokStatus();
  }

  Future<void> _checkWarlokStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (userData.exists && userData.data()?['role'] == 'warlok') {
          if (mounted) {
            setState(() => _isWarlok = true);
          }
        }
      }
    } catch (e) {
      print('Error checking warlok status: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: screens.length,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(160), // Tinggi AppBar diperbesar

          child: AppBar(
            title: const Text(
              "Hotel & Akomodasi",
              style: TextStyle(color: Colors.black, fontFamily: 'Poppins'),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'), // Ganti dengan path yang sesuai jika perlu
              icon: Image.asset('assets/icons/Back-Button.png'),
            ),
            flexibleSpace: Padding(
              padding: const EdgeInsets.fromLTRB(16, 70, 16, 0), // Jarak dari atas
              child: Column(
                children: [
                  Row(
                    children: [
                      // Search Bar
                      Expanded(
                        child: SizedBox(
                          height: 35,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.black54), // Outline color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              backgroundColor: Colors.white,
                            ),
                            onPressed: () => Navigator.pushNamed(context, '/search_hotel'),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.search, color: Colors.grey, size: 20),
                                SizedBox(width: 10),
                                Text(
                                  'Cari hotel termurah',
                                  style: TextStyle(color: Colors.grey, fontFamily: 'Poppins', fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Filter Button
                      IconButton(
                        icon: Image.asset("assets/icons/filter-btn.png"),
                        onPressed: () {},
                      ),
                      // Sort Button
                      IconButton(
                        icon: Image.asset("assets/icons/sort-btn.png"),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(50),
              child: Container(
                color: Colors.white,
                child: Builder(
                  builder: (context) {
                    final TabController tabController = DefaultTabController.of(
                      context,
                    );
                    return AnimatedBuilder(
                      animation: tabController,
                      builder: (context, child) {
                        return TabBar(
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          indicator: BoxDecoration(),
                          labelPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          tabs: List.generate(5, (index) {
                            final isSelected = tabController.index == index;
                            return _buildTab(
                              [
                                "Semua",
                                "Populer",
                                "Terdekat",
                                "Rekomended",
                                "Warga Lokal",
                              ][index],
                              isSelected,
                            );
                          }),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(children: screens),
        // Menggunakan floating action button dengan padding
        floatingActionButton:
            _isWarlok
                ? Padding(
                  padding: const EdgeInsets.only(bottom: 17, right: 17),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DashboardWarlog(),
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/icons/home-icon.png',
                      width: 75,
                      height: 75,
                    ),
                  ),
                )
                : null,
        // Mengatur posisi floating action button
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildTab(String text, bool isSelected) {
    return Tab(
      child: Container(
        width: 130,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.blueGrey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.blue,
            fontFamily: 'Poppins',
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _hotelCard(
    String imageUrl,
    String hotelName,
    double rating,
    String location,
    String price,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Image.asset(
            imageUrl,
            width: double.infinity,
            height: 150,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotelName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: 16),
                        Text(
                          '$rating (${200} ulasan)',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    Text(
                      location,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Text(
                  'Mulai dari\n$price',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
