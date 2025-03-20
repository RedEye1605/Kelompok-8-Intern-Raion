import 'package:flutter/material.dart';
import 'package:my_flutter_app/di/injection_container.dart' as di;
import 'package:my_flutter_app/features/presentation/providers/penginapan_form_provider.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/mvp/penginapan-tab/pov-warlok-tab/create_rumah_screen.dart';
import 'package:provider/provider.dart';

class DashboardWarlog extends StatefulWidget {
  const DashboardWarlog({Key? key}) : super(key: key);

  @override
  State<DashboardWarlog> createState() => _DashboardWarlogState();
}

class _DashboardWarlogState extends State<DashboardWarlog>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _tabController.animateTo(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar untuk responsivitas
    final size = MediaQuery.of(context).size;
    final height = size.height * 0.2; // 40% dari tinggi layar

    final List<Widget> screens = [
      // Penginapan Tab Content - Box lebih besar dan fleksibel
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: height, // Box yang lebih tinggi dan responsif
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: const Center(
                child: Text(
                  'Kamu belum menyewakan apapun',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18, // Ukuran font sedikit diperbesar
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Pemesan Tab Content - Emoji lebih besar dan di tengah
      Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity,
            height: height, // Box yang lebih tinggi dan responsif
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              // Tidak ada border untuk tab pemesan
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Vertikal center
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Horizontal center
              children: const [
                Icon(
                  Icons.sentiment_dissatisfied,
                  color: Colors.grey,
                  size: 0, // Emoji yang lebih besar
                ),
                SizedBox(height: 20),
                Text(
                  'Tidak ada pemesan. Ayo sewakan rumahmu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18, // Ukuran font sedikit diperbesar
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Sewakan Rumahmu',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            // Tombol add dengan ikon + dalam lingkaran biru
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 18,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  onPressed: () {
                    // Navigasi ke halaman Create Rumah Screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => ChangeNotifierProvider(
                              create: (_) => di.sl<PenginapanFormProvider>(),
                              child: const CreateRumahScreen(),
                            ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            onTap: _onItemTapped,
            indicatorColor: Colors.blue,
            labelColor: Colors.blue, // Warna teks saat tab aktif
            unselectedLabelColor:
                Colors.black, // Warna teks saat tab tidak aktif
            tabs: const [
              Tab(
                child: Text(
                  'Penginapan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Tab(
                child: Text(
                  'Pemesan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(controller: _tabController, children: screens),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 17, right: 17),
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/hotelPage');
            },
            child: Image.asset(
              'assets/icons/Hotel_icon.png',
              width: 75,
              height: 75,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
