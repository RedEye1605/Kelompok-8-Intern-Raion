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
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this

class DashboardWarlog extends StatefulWidget {
  const DashboardWarlog({Key? key}) : super(key: key);

  @override
  State<DashboardWarlog> createState() => _DashboardWarlogState();
}

class _DashboardWarlogState extends State<DashboardWarlog>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;

  // Add a new list to store the original data
  List<Map<String, String>> _originalBookingsList = [];

  // This will store the filtered results
  List<Map<String, String>> _bookingsList = [];

  // Add these variables to your _DashboardWarlogState class
  String _selectedCategory = "Semua";
  String _selectedDateFilter = "Semua";
  bool _isFilterExpanded = false;

  // Update this to match your actual room categories
  List<String> _categoryOptions = [
    "Semua",
    // Add actual categories from your data
  ];
  final List<String> _dateFilterOptions = [
    "Semua",
    "Hari ini",
    "Minggu ini",
    "Bulan ini",
  ];

  // Add these variables to your class
  bool _isAscending = true; // Controls sort direction
  String _sortBy = "name"; // What field to sort by (name, date)

  // Add to class variables
  bool _isOrdersLoading = false;
  String? _orderError;

  // Add these variables to your _DashboardWarlogState class
  bool _filterByDate = true; // Default to date filter
  bool _filterByCategory = false;
  Map<String, List<Map<String, String>>> _groupedBookings = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;

        // Load orders when switching to the Pemesanan tab
        if (_selectedIndex == 1) {
          _loadBookingData().then((_) {
            // Initialize with date grouping by default
            _groupBookingsByDate();
          });
        }
      });
    });

    // Initialize with dummy data (will be replaced)
    _bookingsList = List.from(_originalBookingsList);

    // Add the rest of your existing initState code...

    // Initialize bookingsList with all data
    _bookingsList = List.from(_originalBookingsList);

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

    // Initial data load
    _loadBookingData().then((_) {
      _updateCategoryOptions();
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

          // Pemesan Tab Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                _isOrdersLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _originalBookingsList.isEmpty
                    ? Container(
                      // Show this when there are NO bookings at all
                      width: double.infinity,
                      height: height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sentiment_dissatisfied,
                            color: Colors.grey,
                            size: 48,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Tidak ada pemesan. Ayo sewakan rumahmu.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          if (_orderError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                _orderError!,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _loadBookingData,
                            icon: Icon(Icons.refresh),
                            label: Text("Reload Data"),
                          ),
                        ],
                      ),
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Daftar Pemesan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Filter Bar
                        _buildFilterBar(),
                        const SizedBox(height: 16),

                        // Show content or "no results" message
                        Expanded(
                          child:
                              _bookingsList.isEmpty
                                  ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.filter_list_off,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Tidak ada hasil yang cocok dengan filter',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Coba ubah filter untuk melihat lebih banyak hasil',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  : (_filterByDate || _filterByCategory)
                                  ? ListView.builder(
                                    itemCount: _groupedBookings.length,
                                    itemBuilder: (context, index) {
                                      // Get the group key and items for this section
                                      final groupKey =
                                          _groupedBookings.keys.toList()[index];
                                      final groupItems =
                                          _groupedBookings[groupKey]!;

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Section header
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12.0,
                                            ),
                                            child: Text(
                                              groupKey,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.blue[800],
                                              ),
                                            ),
                                          ),
                                          // List items in this group
                                          ...groupItems.map((booking) {
                                            return _buildSimpleBookingCard(
                                              booking["name"]!,
                                              booking["hotelName"]!,
                                              booking["dateRange"]!,
                                              userId: booking["userId"],
                                            );
                                          }).toList(),
                                          // Add divider between groups
                                          if (index <
                                              _groupedBookings.length - 1)
                                            Divider(thickness: 1, height: 32),
                                        ],
                                      );
                                    },
                                  )
                                  : ListView.builder(
                                    itemCount: _bookingsList.length,
                                    itemBuilder: (context, index) {
                                      final booking = _bookingsList[index];
                                      return _buildSimpleBookingCard(
                                        booking["name"]!,
                                        booking["hotelName"]!,
                                        booking["dateRange"]!,
                                        userId: booking["userId"],
                                      );
                                    },
                                  ),
                        ),
                      ],
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
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.green,
                    radius: 18,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
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

  Widget _buildBookingCard(
    String name,
    String hotelName,
    String dateRange, {
    String status = 'pending',
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/icons/profile-icon.png'),
                  radius: 25,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                // Add status badge
                _buildStatusBadge(status),
              ],
            ),
            // Rest of your existing card code...
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.home, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hotelName,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  dateRange,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const Spacer(),
                Container(
                  alignment: Alignment.bottomRight,
                  child: InkWell(
                    onTap: () {}, // Navigate to booking detail page
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 14, color: Colors.blue),
                        SizedBox(width: 4),
                        Text(
                          'Detail',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'confirmed':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case 'completed':
        color = Colors.blue;
        icon = Icons.task_alt;
        break;
      case 'pending':
      default:
        color = Colors.orange;
        icon = Icons.pending;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Date filter toggle button with sort icon
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Image.asset('assets/icons/sort-btn.png', width: 40, height: 40),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildFilterToggle(
                    label: "Tanggal",
                    isSelected: _filterByDate,
                    onTap: () {
                      setState(() {
                        _filterByDate = true;
                        _filterByCategory = false;
                        _groupBookingsByDate();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Category filter toggle button
          Expanded(
            flex: 1,
            child: _buildFilterToggle(
              label: "Kategori Kamar",
              isSelected: _filterByCategory,
              onTap: () {
                setState(() {
                  _filterByDate = false;
                  _filterByCategory = true;
                  _groupBookingsByCategory();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterToggle({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        alignment: Alignment.center, // This will center the text
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center, // Ensure text is centered
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blue,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // Add these two new methods to group bookings
  void _groupBookingsByDate() {
    // Sort bookings by date
    List<Map<String, String>> sortedList = List.from(_originalBookingsList);

    // Group by createdAt - we're using this for headers
    Map<String, List<Map<String, String>>> grouped = {};

    for (var booking in sortedList) {
      // Use the createdAt field for grouping with the proper format
      String dateKey = booking["createdAt"] ?? "Unknown";

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(booking);
    }

    setState(() {
      _groupedBookings = grouped;
    });
  }

  void _groupBookingsByCategory() {
    // Group by category
    Map<String, List<Map<String, String>>> grouped = {};

    for (var booking in _originalBookingsList) {
      String categoryKey = booking["category"] ?? "Tidak Dikategorikan";
      if (!grouped.containsKey(categoryKey)) {
        grouped[categoryKey] = [];
      }
      grouped[categoryKey]!.add(booking);
    }

    setState(() {
      _groupedBookings = grouped;
    });
  }

  // Apply filters and sorting
  void _applyFiltersAndSort() {
    // Always start with the original list
    List<Map<String, String>> filteredList = List.from(_originalBookingsList);

    // Filter by category if needed
    if (_selectedCategory != "Semua") {
      filteredList =
          filteredList.where((booking) {
            final category = booking["category"] ?? "";
            return category == _selectedCategory;
          }).toList();
    }

    // Filter by date if needed
    if (_selectedDateFilter != "Semua") {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      filteredList =
          filteredList.where((booking) {
            try {
              final dateRange = booking["dateRange"] ?? "";
              final checkInStr = dateRange.split(" - ").first;
              final checkIn = _parseDate(checkInStr);

              if (_selectedDateFilter == "Hari ini") {
                return checkIn.year == today.year &&
                    checkIn.month == today.month &&
                    checkIn.day == today.day;
              } else if (_selectedDateFilter == "Minggu ini") {
                final weekStart = today.subtract(
                  Duration(days: today.weekday - 1),
                );
                final weekEnd = weekStart.add(const Duration(days: 6));
                return checkIn.isAfter(
                      weekStart.subtract(const Duration(days: 1)),
                    ) &&
                    checkIn.isBefore(weekEnd.add(const Duration(days: 1)));
              } else if (_selectedDateFilter == "Bulan ini") {
                return checkIn.year == today.year &&
                    checkIn.month == today.month;
              }
            } catch (e) {
              print("Date parsing error: $e");
            }
            return false;
          }).toList();
    }

    // Sort the list based on direction
    filteredList.sort((a, b) {
      final aValue = _sortBy == "name" ? a["name"] ?? "" : a["dateRange"] ?? "";
      final bValue = _sortBy == "name" ? b["name"] ?? "" : b["dateRange"] ?? "";
      return _isAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });

    setState(() {
      _bookingsList = filteredList;
    });
  }

  // Method to load booking data from Firestore
  Future<void> _loadBookingData() async {
    if (_isOrdersLoading) return;

    setState(() {
      _isOrdersLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _orderError = "Pengguna tidak ditemukan";
          _isOrdersLoading = false;
        });
        return;
      }

      // Add debug prints
      print("👤 Loading orders for user ID: ${user.uid}");

      // Option 1: Only filter, no sort (temporary until index is created)
      final QuerySnapshot orderSnapshot =
          await FirebaseFirestore.instance
              .collection('orders')
              .where('ownerId', isEqualTo: user.uid)
              .get();

      // Add debug print
      print("📋 Firestore returned ${orderSnapshot.docs.length} orders");

      if (orderSnapshot.docs.isEmpty) {
        setState(() {
          _bookingsList = [];
          _originalBookingsList = [];
          _isOrdersLoading = false;
        });
        return;
      }

      List<Map<String, String>> orders = [];

      for (var doc in orderSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Format date range with our new formatter
        final checkIn = data['checkIn'] ?? '';
        final checkOut = data['checkOut'] ?? '';
        final dateRange = _formatDateRange(checkIn, checkOut);

        // Format hotel name with room type
        final hotelName = "${data['hotelName']} - ${data['tipeKamar']}";

        // Get createdAt timestamp
        final createdAt = data['createdAt'] as Timestamp?;
        final formattedCreatedAt =
            createdAt != null ? _formatTimestamp(createdAt) : 'Unknown date';

        orders.add({
          "name": data['nama'] ?? 'Unknown',
          "hotelName": hotelName,
          "dateRange": dateRange,
          "category": data['tipeKamar'] ?? '',
          "orderId": doc.id,
          "createdAt": formattedCreatedAt,
          "userId": data['userId'] ?? '',
        });
      }

      // Sort by createdAt (newest first)
      orders.sort((a, b) {
        final aDate = a["createdAt"] ?? "";
        final bDate = b["createdAt"] ?? "";
        return bDate.compareTo(aDate); // Descending order
      });

      setState(() {
        _originalBookingsList = orders;
        _bookingsList = List.from(orders);
        _isOrdersLoading = false;

        // Debug the list that will be displayed
        print("📊 Displaying ${_bookingsList.length} orders in UI");
      });
    } catch (e) {
      setState(() {
        _orderError = "Error loading orders: $e";
        _isOrdersLoading = false;
      });
      print("❌ Error loading orders: $e");
    }
  }

  // Helper method to parse dates from string
  DateTime _parseDate(String dateStr) {
    try {
      // First try parsing as yyyy-MM-dd (standard format)
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        // If that fails, try the Indonesian format
      }

      // Assuming format: "13 Maret 2025"
      final parts = dateStr.split(" ");
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]) ?? 1;
        final year = int.tryParse(parts[2]) ?? DateTime.now().year;

        // Convert month name to number
        int month = 1;
        const monthNames = {
          "Januari": 1, "Februari": 2, "Maret": 3, "April": 4,
          "Mei": 5, "Juni": 6, "Juli": 7, "Agustus": 8,
          "September": 9, "Oktober": 10, "November": 11, "Desember": 12,
          // Add English month names for good measure
          "January": 1, "February": 2, "March": 3,
          "May": 5, "June": 6, "July": 7, "August": 8,
          "October": 10, "December": 12,
        };

        if (monthNames.containsKey(parts[1])) {
          month = monthNames[parts[1]]!;
        }

        return DateTime(year, month, day);
      }
    } catch (e) {
      print("Error parsing date '$dateStr': $e");
    }
    return DateTime.now(); // Default to today if parsing fails
  }

  // Add this method to update categories based on real data
  void _updateCategoryOptions() {
    Set<String> categories = {"Semua"};
    for (var booking in _originalBookingsList) {
      if (booking["category"] != null && booking["category"]!.isNotEmpty) {
        categories.add(booking["category"]!);
      }
    }

    setState(() {
      _categoryOptions = categories.toList();
    });
  }

  // Add this new method for the simplified booking card
  Widget _buildSimpleBookingCard(
    String name,
    String hotelName,
    String dateRange, {
    String? userId,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side - profile image
            FutureBuilder<DocumentSnapshot>(
              future:
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId ?? '')
                      .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    radius: 18,
                    child: Icon(Icons.person, size: 18, color: Colors.grey),
                  );
                }

                if (snapshot.hasData && snapshot.data!.exists) {
                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>?;
                  final photoUrl = userData?['userPhoto'] as String?;

                  if (photoUrl != null && photoUrl.isNotEmpty) {
                    return CircleAvatar(
                      backgroundImage: NetworkImage(photoUrl),
                      radius: 18,
                    );
                  }
                }

                // Fallback
                return CircleAvatar(
                  backgroundImage: AssetImage('assets/icons/profile-icon.png'),
                  radius: 18,
                );
              },
            ),
            const SizedBox(width: 12),

            // Right side - all text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name row
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Hotel row
                  Row(
                    children: [
                      const Icon(Icons.home, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          hotelName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Date row
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                dateRange,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            // Detail link
                            InkWell(
                              onTap: () {}, // Navigate to booking detail page
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 14,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Lihat Detail',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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

  // Add helper method for timestamp formatting
  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final day = date.day.toString();
    final year = date.year.toString();

    const monthNames = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ];
    final month = monthNames[date.month - 1];

    return "$day $month $year";
  }

  // Add this helper method to format date ranges properly
  String _formatDateRange(String checkIn, String checkOut) {
    try {
      // Parse the dates (assuming yyyy-MM-dd format)
      DateTime? startDate = _parseStandardDate(checkIn);
      DateTime? endDate = _parseStandardDate(checkOut);

      if (startDate == null || endDate == null) {
        return "$checkIn - $checkOut"; // Return original if parsing fails
      }

      // Use same month/year if they match
      bool sameMonth =
          startDate.month == endDate.month && startDate.year == endDate.year;

      const monthNames = [
        "Januari",
        "Februari",
        "Maret",
        "April",
        "Mei",
        "Juni",
        "Juli",
        "Agustus",
        "September",
        "Oktober",
        "November",
        "Desember",
      ];

      final startDay = startDate.day.toString();
      final endDay = endDate.day.toString();
      final month = monthNames[startDate.month - 1];
      final year = startDate.year.toString();

      if (sameMonth) {
        return "$startDay-$endDay $month $year";
      } else {
        final endMonth = monthNames[endDate.month - 1];
        final endYear = endDate.year.toString();

        if (startDate.year == endDate.year) {
          return "$startDay $month - $endDay $endMonth $year";
        } else {
          return "$startDay $month $year - $endDay $endMonth $endYear";
        }
      }
    } catch (e) {
      print("Error formatting date range: $e");
      return "$checkIn - $checkOut"; // Return original on error
    }
  }

  // Helper to parse standard date format
  DateTime? _parseStandardDate(String dateStr) {
    try {
      // Try parsing ISO format
      return DateTime.parse(dateStr);
    } catch (e) {
      print("Error parsing standard date '$dateStr': $e");
      return null;
    }
  }
}
