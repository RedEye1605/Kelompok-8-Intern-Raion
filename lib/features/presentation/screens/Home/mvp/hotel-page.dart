import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/mvp/penginapan-tab/Rekomended-tab.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/mvp/penginapan-tab/populer-tab.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/mvp/penginapan-tab/semua-tab.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/mvp/penginapan-tab/terdekat-tab.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/mvp/penginapan-tab/warlok-tab.dart';

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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: screens.length,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(165), // Tinggi AppBar diperbesar
          child: AppBar(
            title: const Text(
              "Hotel & Akomodasi",
              style: TextStyle(color: Colors.black, fontFamily: 'Poppins'),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(onPressed: () => Navigator.pop(context), icon: Image.asset('assets/icons/Back-Button.png')),
            flexibleSpace: Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                50,
                16,
                0,
              ), // Jarak dari atas
              child: Column(
                children: [
                  Row(
                    children: [
                      // Search Bar
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.black54,
                            ), // Outline color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            backgroundColor: Colors.white,
                          ),
                          onPressed:
                              () =>
                                  Navigator.pushNamed(context, '/search_hotel'),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: Colors.grey, size: 25),
                              SizedBox(width: 10),
                              Text(
                                'Cari hotel termurah',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        //  TextField(
                        //   decoration: InputDecoration(
                        //     hintText: 'Cari hotel termurah',
                        //     prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        //     filled: true,
                        //     fillColor: Colors.white,
                        //     border: OutlineInputBorder(
                        //       borderRadius: BorderRadius.circular(30),
                        //       borderSide: BorderSide(color: Colors.grey),
                        //     ),
                        //     contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        //   ),
                        // ),
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
                color: Colors.white, // Warna background untuk semua tab
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
      ),
    );
  }

  Widget _buildTab(String text, bool isSelected) {
    return Tab(
      child: Container(
        width: 130,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Colors.blue
                  : Colors
                      .blueGrey[100], // Background abu-abu untuk tab yang tidak dipilih
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
}
