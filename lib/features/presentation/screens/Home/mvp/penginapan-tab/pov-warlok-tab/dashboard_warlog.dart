import 'package:flutter/material.dart';
import 'package:my_flutter_app/di/injection_container.dart' as di;
import 'package:my_flutter_app/features/domain/entities/penginapan.dart';
import 'package:my_flutter_app/features/presentation/providers/penginapan_form_provider.dart';
import 'package:my_flutter_app/features/presentation/providers/penginapan_provider.dart'; // Add this
import 'package:my_flutter_app/features/presentation/screens/Home/mvp/penginapan-tab/pov-warlok-tab/create_rumah_screen.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/mvp/penginapan-tab/pov-warlok-tab/edit_rumah_screen.dart';
import 'package:my_flutter_app/features/presentation/widgets/card_widget.dart'; // Add this
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this

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

    // Add debugging for authentication and data loading
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<PenginapanProvider>(context, listen: false);

      // Debug current user
      final user = FirebaseAuth.instance.currentUser;
      print('Current user: ${user?.uid}');

      if (user != null) {
        try {
          await provider.loadCurrentUserPenginapan();
          print(
            'Loaded user penginapan: ${provider.userPenginapanList.length} items',
          );

          // Debug first item if available
          if (provider.userPenginapanList.isNotEmpty) {
            final first = provider.userPenginapanList.first;
            print('First item: ${first.namaRumah}, UserID: ${first.userID}');
          }
        } catch (e) {
          print('Error loading penginapan: $e');
        }
      } else {
        print('No user is logged in');
      }
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
    final size = MediaQuery.of(context).size;
    final height = size.height * 0.2;

    return Consumer<PenginapanProvider>(
      builder: (context, penginapanProvider, _) {
        final userPenginapanList = penginapanProvider.userPenginapanList;

        final List<Widget> screens = [
          // Penginapan Tab Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                penginapanProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : userPenginapanList.isEmpty
                    ? Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: height,
                          padding: const EdgeInsets.symmetric(
                            vertical: 30,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: const Center(
                            child: Text(
                              'Kamu belum menyewakan apapun',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    )
                    : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              'Penginapan Anda',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...userPenginapanList.map((penginapan) {
                            // Get first kategori details if available
                            String harga = "0";
                            String namaKategori = "Kamar";

                            if (penginapan.kategoriKamar.isNotEmpty) {
                              final entry =
                                  penginapan.kategoriKamar.entries.first;
                              final firstKategori = entry.value;
                              namaKategori = entry.key;
                              harga = firstKategori.harga;
                            }

                            // Simplified alamat format: "Kecamatan - Malang"
                            String alamat = '';
                            if (penginapan.kecamatan?.isNotEmpty == true) {
                              alamat = "${penginapan.kecamatan} - Malang";
                            } else {
                              alamat = "Malang";
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: CardWidget(
                                imageUrl:
                                    penginapan.fotoPenginapan.isNotEmpty
                                        ? penginapan.fotoPenginapan.first
                                        : 'https://picsum.photos/400/250',
                                title:
                                    penginapan.namaRumah.isNotEmpty
                                        ? penginapan.namaRumah
                                        : 'Rumah Sewa',
                                alamat: alamat,
                                price: '${harga}',
                                rating: 4.0,
                                ulasan: 0,
                                additionalImages:
                                    penginapan.fotoPenginapan.length > 1
                                        ? penginapan.fotoPenginapan.sublist(1)
                                        : null,
                                deskripsi:
                                    penginapan.kategoriKamar.isNotEmpty
                                        ? penginapan
                                            .kategoriKamar
                                            .values
                                            .first
                                            .deskripsi
                                        : null,
                                fasilitas:
                                    penginapan.kategoriKamar.isNotEmpty
                                        ? penginapan
                                            .kategoriKamar
                                            .values
                                            .first
                                            .fasilitas
                                        : null,
                                kategoriKamar: penginapan.kategoriKamar,
                                linkMaps: penginapan.linkMaps,
                                isInDashboardWarlok: true,
                                onCustomTap: () {
                                  final Map<String, dynamic>
                                  penginapanDataMap = {
                                    'namaRumah': penginapan.namaRumah,
                                    'alamatJalan': penginapan.alamatJalan,
                                    'kecamatan': penginapan.kecamatan,
                                    'kelurahan': penginapan.kelurahan,
                                    'kodePos': penginapan.kodePos,
                                    'linkMaps': penginapan.linkMaps,
                                    'kategoriKamar': _convertKategoriToMap(
                                      penginapan.kategoriKamar,
                                    ),
                                    'fotoPenginapan':
                                        penginapan
                                            .fotoPenginapan, // Pass the image URLs
                                  };

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ChangeNotifierProvider(
                                            create:
                                                (_) =>
                                                    di
                                                        .sl<
                                                          PenginapanFormProvider
                                                        >(),
                                            child: EditRumahScreen(
                                              penginapanId: penginapan.id ?? '',
                                              penginapanData: penginapanDataMap,
                                            ),
                                          ),
                                    ),
                                  ).then((_) {
                                    // Refresh data after returning from edit screen
                                    penginapanProvider
                                        .loadCurrentUserPenginapan();
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
          ),

          // Pemesan Tab Content (unchanged)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.sentiment_dissatisfied,
                      color: Colors.grey,
                      size: 0,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Tidak ada pemesan. Ayo sewakan rumahmu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              actions: [
                // Tombol pertama (baru) di sebelah kiri tombol add
                Padding(
                  padding: const EdgeInsets.only(
                    right: 8.0,
                  ), // Jarak dengan tombol add
                  child: CircleAvatar(
                    backgroundColor:
                        Colors.green, // Warna berbeda untuk membedakan
                    radius: 18, // Ukuran yang sama dengan tombol add
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons
                            .refresh, // Icon refresh, bisa diganti dengan icon lain
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        // Fungsi refresh data
                        final provider = Provider.of<PenginapanProvider>(
                          context,
                          listen: false,
                        );
                        provider.loadPenginapan();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Memuat ulang data penginapan...'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Tombol add yang sudah ada
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.blue,
                    radius: 18,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder:
                                    (context) => ChangeNotifierProvider(
                                      create:
                                          (_) =>
                                              di.sl<PenginapanFormProvider>(),
                                      child: const CreateRumahScreen(),
                                    ),
                              ),
                            )
                            .then((_) {
                              // Refresh data after returning from create screen
                              penginapanProvider.loadCurrentUserPenginapan();
                            });
                      },
                    ),
                  ),
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                onTap: _onItemTapped,
                indicatorColor: Colors.blue,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.black,
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
      },
    );
  }

  // Add this helper method to your _DashboardWarlogState class
  Map<String, dynamic> _convertKategoriToMap(
    Map<String, KategoriKamarEntity> kategoriMap,
  ) {
    final result = <String, dynamic>{};
    kategoriMap.forEach((key, value) {
      result[key] = {
        'deskripsi': value.deskripsi,
        'harga': value.harga,
        'jumlah': value.jumlah,
        'fasilitas': value.fasilitas,
      };
    });
    return result;
  }
}
