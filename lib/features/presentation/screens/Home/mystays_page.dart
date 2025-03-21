import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:my_flutter_app/features/presentation/widgets/card_widget.dart';

class MystaysPage extends StatefulWidget {
  const MystaysPage({super.key});

  @override
  State<MystaysPage> createState() => _MystaysPageState();
}

class _MystaysPageState extends State<MystaysPage> {
  final searchController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;

  // Store orders data
  List<Map<String, dynamic>> _currentOrders = [];
  List<Map<String, dynamic>> _pastOrders = [];

  // For filtering
  List<Map<String, dynamic>> _filteredCurrentOrders = [];
  List<Map<String, dynamic>> _filteredPastOrders = [];

  @override
  void initState() {
    super.initState();
    _loadOrderData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Improved method for loading order data with proper relationships
  Future<void> _loadOrderData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Query without orderBy to avoid index requirements
      final QuerySnapshot orderSnapshot =
          await FirebaseFirestore.instance
              .collection('orders')
              .where('userId', isEqualTo: user.uid)
              .get();

      final List<Map<String, dynamic>> currentOrders = [];
      final List<Map<String, dynamic>> pastOrders = [];
      final DateTime now = DateTime.now();

      // Process each order
      for (var doc in orderSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        try {
          // Parse checkout date to determine if it's current or past
          final checkOutStr = data['checkOut'] as String? ?? '';
          DateTime checkOut;

          try {
            checkOut = DateFormat('yyyy-MM-dd').parse(checkOutStr);
          } catch (e) {
            checkOut = now.subtract(Duration(days: 1));
          }

          // Create base order object
          final order = {
            'id': doc.id,
            'hotelName': data['hotelName'] ?? 'Unknown',
            'tipeKamar': data['tipeKamar'] ?? '',
            'checkIn': data['checkIn'] ?? '',
            'checkOut': checkOutStr,
            'price': data['price'] ?? '0',
            'status': data['status'] ?? false,
            'jumlahKamar': data['jumlahKamar'] ?? 1,
            'dateRange': "${data['checkIn']} - ${data['checkOut']}",
            'createdAt': data['createdAt'],
            'penginapanId': data['penginapanId'] ?? '',
            'imageUrl': 'assets/images/placeholder.png', // Default placeholder
            'kecamatan': 'Malang', // Default location
          };

          // Enhanced: Try to fetch penginapan data (image, location)
          if (order['penginapanId'].toString().isNotEmpty) {
            try {
              final penginapanDoc =
                  await FirebaseFirestore.instance
                      .collection('penginapan')
                      .doc(order['penginapanId'].toString())
                      .get();

              if (penginapanDoc.exists) {
                final penginapanData = penginapanDoc.data();
                if (penginapanData != null) {
                  // Get image URL (first image from the array)
                  if (penginapanData['fotoPenginapan'] != null &&
                      penginapanData['fotoPenginapan'] is List &&
                      (penginapanData['fotoPenginapan'] as List).isNotEmpty) {
                    order['imageUrl'] =
                        (penginapanData['fotoPenginapan'] as List)[0];
                  }

                  // Get proper location data
                  if (penginapanData['kecamatan'] != null &&
                      penginapanData['kecamatan'].toString().isNotEmpty) {
                    order['kecamatan'] =
                        "${penginapanData['kecamatan']} - Malang";
                  }
                }
              }
            } catch (e) {
              print('Error fetching penginapan data: $e');
            }
          }

          // Sort into current or past based on checkout date
          if (checkOut.isAfter(now)) {
            currentOrders.add(order);
          } else {
            pastOrders.add(order);
          }
        } catch (e) {
          print("Error processing order document: $e");
        }
      }

      // Manual sorting by createdAt (newest first)
      currentOrders.sort((a, b) {
        final aTimestamp = a['createdAt'] as Timestamp?;
        final bTimestamp = b['createdAt'] as Timestamp?;

        if (aTimestamp == null && bTimestamp == null) return 0;
        if (aTimestamp == null) return 1;
        if (bTimestamp == null) return -1;

        return bTimestamp.compareTo(aTimestamp);
      });

      pastOrders.sort((a, b) {
        final aTimestamp = a['createdAt'] as Timestamp?;
        final bTimestamp = b['createdAt'] as Timestamp?;

        if (aTimestamp == null && bTimestamp == null) return 0;
        if (aTimestamp == null) return 1;
        if (bTimestamp == null) return -1;

        return bTimestamp.compareTo(aTimestamp);
      });

      setState(() {
        _currentOrders = currentOrders;
        _pastOrders = pastOrders;
        _filteredCurrentOrders = List.from(currentOrders);
        _filteredPastOrders = List.from(pastOrders);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error: $e";
      });
      print("Error loading orders: $e");
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Urutkan Berdasarkan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Tanggal (Terbaru)'),
                onTap: () {
                  _sortOrders('date', true);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Tanggal (Terlama)'),
                onTap: () {
                  _sortOrders('date', false);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.price_change),
                title: const Text('Harga (Tertinggi)'),
                onTap: () {
                  _sortOrders('price', true);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.price_change_outlined),
                title: const Text('Harga (Terendah)'),
                onTap: () {
                  _sortOrders('price', false);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Sort orders based on selected criteria
  void _sortOrders(String criteria, bool descending) {
    setState(() {
      void sortList(List<Map<String, dynamic>> list) {
        if (criteria == 'date') {
          list.sort((a, b) {
            try {
              final aDate = DateFormat('yyyy-MM-dd').parse(a['checkIn'] ?? '');
              final bDate = DateFormat('yyyy-MM-dd').parse(b['checkIn'] ?? '');
              return descending
                  ? bDate.compareTo(aDate)
                  : aDate.compareTo(bDate);
            } catch (e) {
              return 0;
            }
          });
        } else if (criteria == 'price') {
          list.sort((a, b) {
            final aPrice = double.tryParse(a['price'] ?? '0') ?? 0;
            final bPrice = double.tryParse(b['price'] ?? '0') ?? 0;
            return descending
                ? bPrice.compareTo(aPrice)
                : aPrice.compareTo(bPrice);
          });
        }
      }

      sortList(_filteredCurrentOrders);
      sortList(_filteredPastOrders);
    });
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Cari Reservasi'),
            content: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Masukkan nama penginapan...',
              ),
              onChanged: (searchText) {
                if (searchText.isEmpty) {
                  setState(() {
                    _filteredCurrentOrders = List.from(_currentOrders);
                    _filteredPastOrders = List.from(_pastOrders);
                  });
                  return;
                }

                final searchLower = searchText.toLowerCase();

                setState(() {
                  _filteredCurrentOrders =
                      _currentOrders
                          .where(
                            (order) =>
                                order['hotelName']
                                    .toString()
                                    .toLowerCase()
                                    .contains(searchLower) ||
                                order['tipeKamar']
                                    .toString()
                                    .toLowerCase()
                                    .contains(searchLower),
                          )
                          .toList();

                  _filteredPastOrders =
                      _pastOrders
                          .where(
                            (order) =>
                                order['hotelName']
                                    .toString()
                                    .toLowerCase()
                                    .contains(searchLower) ||
                                order['tipeKamar']
                                    .toString()
                                    .toLowerCase()
                                    .contains(searchLower),
                          )
                          .toList();
                });
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Tutup'),
              ),
            ],
          ),
    );
  }

  // Improved card widget builder with proper layout and data
  Widget _buildOrderCardWithCardWidget(
    Map<String, dynamic> order,
    bool isActive,
  ) {
    // Format price properly without decimals
    final double rawPrice = double.tryParse(order['price'] ?? '0') ?? 0;
    final String formattedPrice = rawPrice.toInt().toString();

    // Use the properly fetched location from penginapan
    // This should be displaying the kecamatan, not the room type
    final String location = order['kecamatan'] ?? "Malang";

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: SizedBox(
          // Updated size to match the requested dimensions
          width: 390,
          height: 269,
          child: CardWidget(
            imageUrl: order['imageUrl'],
            title: order['hotelName'],
            alamat: location, // Use only location data, not room info
            price: formattedPrice,
            rating: 4, // Hide rating
            ulasan: 200, // Hide reviews
            onCustomTap: () => _viewOrderDetail(order),
            isInDashboardWarlok: true,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        title: Row(
          children: [
            // Search Bar
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.black54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  backgroundColor: Colors.white,
                ),
                onPressed: _showSearchDialog,
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey, size: 25),
                    SizedBox(width: 10),
                    Text(
                      'Cari riwayat',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Filter icon
            GestureDetector(
              onTap: _showFilterOptions,
              child: CircleAvatar(
                backgroundColor: Colors.grey[300],
                radius: 20,
                child: Image.asset("assets/icons/filter-btn.png"),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
    ? Center(child: CircularProgressIndicator())
    : _errorMessage != null
        ? Center(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red),
            ),
          )
        : SingleChildScrollView( // Tambahkan SingleChildScrollView di sini
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Reservasi Saya",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 20),
                  // Current reservations
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: _filteredCurrentOrders.isEmpty
                          ? Border.all(color: Colors.grey, width: 2)
                          : null,
                    ),
                    height: _filteredCurrentOrders.isEmpty ? 220 : null,
                    child: _filteredCurrentOrders.isEmpty
                        ? Center(
                            child: Text(
                              "Kamu belum memesan hotel apapun",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _filteredCurrentOrders.length,
                            itemBuilder: (context, index) {
                              return _buildOrderCardWithCardWidget(
                                _filteredCurrentOrders[index],
                                true,
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Riwayat pemesanan",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Past reservations
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: _filteredPastOrders.isEmpty
                          ? Border.all(color: Colors.grey, width: 2)
                          : null,
                    ),
                    child: _filteredPastOrders.isEmpty
                        ? Center(
                            child: Text(
                              "Kamu belum pernah melakukan pemesanan",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _filteredPastOrders.length,
                            itemBuilder: (context, index) {
                              return _buildOrderCardWithCardWidget(
                                _filteredPastOrders[index],
                                false,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadOrderData,
        child: Icon(Icons.refresh),
        tooltip: 'Refresh Orders',
      ),
    );
  }

  void _viewOrderDetail(Map<String, dynamic> order) {
    // Format price for display
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    final price = double.tryParse(order['price'] ?? '0') ?? 0;
    final formattedPrice = formatter.format(price);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.hotel_outlined, color: Colors.blue, size: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Detail Reservasi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Hotel name
                  Text(
                    order['hotelName'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Divider(),

                  // Payment status indicator
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color:
                          order['status']
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: order['status'] ? Colors.green : Colors.orange,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          order['status']
                              ? Icons.check_circle
                              : Icons.pending_outlined,
                          color: order['status'] ? Colors.green : Colors.orange,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          order['status']
                              ? "Pembayaran Selesai"
                              : "Menunggu Pembayaran",
                          style: TextStyle(
                            color:
                                order['status'] ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12),

                  // Room details with icons
                  _buildDetailRow(
                    Icons.meeting_room_outlined,
                    'Tipe Kamar:',
                    order['tipeKamar'],
                  ),
                  _buildDetailRow(
                    Icons.person_outline,
                    'Jumlah Kamar:',
                    '${order['jumlahKamar']} kamar',
                  ),
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Check-in:',
                    order['checkIn'],
                  ),
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Check-out:',
                    order['checkOut'],
                  ),
                  _buildDetailRow(
                    Icons.payments_outlined,
                    'Harga:',
                    formattedPrice,
                  ),

                  SizedBox(height: 8),

                  // Order ID at bottom
                  Text(
                    'ID Pesanan: ${order['id']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Tutup'),
              ),
              if (!order['status'])
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Add navigation to payment page here
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text('Bayar Sekarang'),
                ),
            ],
          ),
    );
  }

  // Helper method for building detail rows
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          SizedBox(width: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.black87),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}


