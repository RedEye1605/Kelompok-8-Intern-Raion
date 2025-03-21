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

  // Updated to store orders by payment status
  List<Map<String, dynamic>> _paidOrders = []; // Orders that have been paid
  List<Map<String, dynamic>> _pendingOrders = []; // Orders awaiting payment
  List<Map<String, dynamic>> _pastOrders = []; // Past orders (completed stays)

  // For filtering
  List<Map<String, dynamic>> _filteredPaidOrders = [];
  List<Map<String, dynamic>> _filteredPendingOrders = [];
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

  // Improved method for loading order data with proper payment status separation
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

      // Get user's orders - try both field names used in your app
      QuerySnapshot? orderSnapshot;
      try {
        orderSnapshot =
            await FirebaseFirestore.instance
                .collection('orders')
                .where('userId', isEqualTo: user.uid)
                .get();

        // If no results, try the other field name
        if (orderSnapshot.docs.isEmpty) {
          orderSnapshot =
              await FirebaseFirestore.instance
                  .collection('orders')
                  .where('ownerId', isEqualTo: user.uid)
                  .get();
        }
      } catch (e) {
        print('Error querying orders: $e');
        // Fallback to get all orders and filter manually
        orderSnapshot =
            await FirebaseFirestore.instance.collection('orders').get();
      }

      // Get payment records to check which orders are paid
      final QuerySnapshot paymentsSnapshot =
          await FirebaseFirestore.instance.collection('payments').get();


      // Create a set of paid order IDs for quick lookup
      final Set<String> paidOrderIds = {};
      for (var doc in paymentsSnapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          // Try different field names that might be used
          String? orderId;
          if (data.containsKey('orderID')) {
            orderId = data['orderID'] as String?;
          } else if (data.containsKey('orderId')) {
            orderId = data['orderId'] as String?;
          } else if (data.containsKey('order_id')) {
            orderId = data['order_id'] as String?;
          }

          // Sometimes the document ID itself is the order ID
          if (orderId == null) {
            // Check if this document ID matches any order IDs
            if (orderSnapshot.docs.any((orderDoc) => orderDoc.id == doc.id)) {
              orderId = doc.id;
            }
          }

          if (orderId != null) {
            paidOrderIds.add(orderId);
          }
        } catch (e) {
          print('Error processing payment document: $e');
        }
      }

      // Create separate lists for each order category
      final List<Map<String, dynamic>> paidOrders = [];
      final List<Map<String, dynamic>> pendingOrders = [];
      final List<Map<String, dynamic>> pastOrders = [];
      final DateTime now = DateTime.now();

      // Process each order
      for (var doc in orderSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Skip orders that don't belong to this user (if we fetched all)
        final String? userId =
            data['userId'] as String? ?? data['ownerId'] as String?;
        if (userId != user.uid) {
          continue;
        }

        try {
          // Parse checkout date to determine if it's current or past
          final checkOutStr = data['checkOut'] as String? ?? '';
          DateTime checkOut;

          try {
            checkOut = DateFormat('yyyy-MM-dd').parse(checkOutStr);
          } catch (e) {
            // Default to future date to prevent wrong categorization
            checkOut = now.add(const Duration(days: 1));
          }

          // Create base order object
          final order = {
            'id': doc.id,
            'hotelName': data['hotelName'] ?? 'Unknown',
            'tipeKamar': data['tipeKamar'] ?? '',
            'checkIn': data['checkIn'] ?? '',
            'checkOut': checkOutStr,
            'price': data['price'] ?? '0',
            'status':
                data['status'] ?? false, // Keep this for backward compatibility
            'isPaid': paidOrderIds.contains(
              doc.id,
            ), // New field to track payment
            'jumlahKamar': data['jumlahKamar'] ?? 1,
            'dateRange': "${data['checkIn']} - ${data['checkOut']}",
            'createdAt': data['createdAt'],
            'penginapanId': data['penginapanId'] ?? '',
            'imageUrl': 'assets/images/placeholder.png', // Default placeholder
            'kecamatan': 'Malang', // Default location
          };

          // Try to fetch penginapan data (image, location)
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

          // Categorize order based on payment status
          if (order['isPaid']) {
            // All paid reservations go to "Reservasi Saya"
            paidOrders.add(order);
          } else {
            // All unpaid reservations go to "Menunggu Pembayaran"
            pendingOrders.add(order);
          }
        } catch (e) {
          print("Error processing order document: $e");
        }
      }

      // Sort by createdAt (newest first)
      final sortByTimestamp = (List<Map<String, dynamic>> list) {
        list.sort((a, b) {
          final aTimestamp = a['createdAt'] as Timestamp?;
          final bTimestamp = b['createdAt'] as Timestamp?;

          if (aTimestamp == null && bTimestamp == null) return 0;
          if (aTimestamp == null) return 1;
          if (bTimestamp == null) return -1;

          return bTimestamp.compareTo(aTimestamp);
        });
      };

      sortByTimestamp(paidOrders);
      sortByTimestamp(pendingOrders);
      sortByTimestamp(pastOrders);

      setState(() {
        _paidOrders = paidOrders;
        _pendingOrders = pendingOrders;
        _pastOrders = pastOrders;
        _filteredPaidOrders = List.from(paidOrders);
        _filteredPendingOrders = List.from(pendingOrders);
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

      sortList(_filteredPaidOrders);
      sortList(_filteredPendingOrders);
      sortList(_filteredPastOrders);
    });
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cari Reservasi'),
            content: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Masukkan nama penginapan...',
              ),
              onChanged: (searchText) {
                if (searchText.isEmpty) {
                  setState(() {
                    _filteredPaidOrders = List.from(_paidOrders);
                    _filteredPendingOrders = List.from(_pendingOrders);
                    _filteredPastOrders = List.from(_pastOrders);
                  });
                  return;
                }

                final searchLower = searchText.toLowerCase();

                // Helper function to filter orders
                final filterBySearch =
                    (List<Map<String, dynamic>> list) =>
                        list
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

                setState(() {
                  _filteredPaidOrders = filterBySearch(_paidOrders);
                  _filteredPendingOrders = filterBySearch(_pendingOrders);
                  _filteredPastOrders = filterBySearch(_pastOrders);
                });
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
    );
  }

  // Card widget builder for orders
  Widget _buildOrderCardWithCardWidget(
    Map<String, dynamic> order,
    bool isActive,
  ) {
    // Format price properly without decimals
    final double rawPrice = double.tryParse(order['price'] ?? '0') ?? 0;
    final String formattedPrice = rawPrice.toInt().toString();

    // Use the properly fetched location from penginapan
    final String location = order['kecamatan'] ?? "Malang";

    return SizedBox(
      // Updated size to match the requested dimensions
      width: double.infinity,
      height: 269,
      child: CardWidget(
        imageUrl: order['imageUrl'],
        title: order['hotelName'],
        alamat: location,
        price: formattedPrice,
        rating: 4, // Hide rating
        ulasan: 200, // Hide reviews
        onCustomTap: () => _viewOrderDetail(order),
        isInDashboardWarlok: true,
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
                  side: const BorderSide(color: Colors.black54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  backgroundColor: Colors.white,
                ),
                onPressed: _showSearchDialog,
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey, size: 25),
                    const SizedBox(width: 10),
                    const Text(
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SECTION 1: PAID RESERVATIONS - Add padding here
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        top: 16.0,
                        right: 16.0,
                        bottom: 8.0,
                      ),
                      child: const Text(
                        "Reservasi Saya",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),

                    // Paid reservations container
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border:
                            _filteredPaidOrders.isEmpty
                                ? Border.all(color: Colors.grey, width: 2)
                                : null,
                      ),
                      constraints: const BoxConstraints(minHeight: 220),
                      child:
                          _filteredPaidOrders.isEmpty
                              ? const Center(
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
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _filteredPaidOrders.length,
                                itemBuilder: (context, index) {
                                  return _buildOrderCardWithCardWidget(
                                    _filteredPaidOrders[index],
                                    true,
                                  );
                                },
                              ),
                    ),

                    // SECTION 2: PENDING PAYMENT RESERVATIONS - Add padding here
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        top: 16.0,
                        right: 16.0,
                        bottom: 8.0,
                      ),
                      child: const Text(
                        "Menunggu Pembayaran",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),

                    // Pending payment container
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border:
                            _filteredPendingOrders.isEmpty
                                ? Border.all(color: Colors.grey, width: 2)
                                : null,
                      ),
                      constraints: const BoxConstraints(minHeight: 220),
                      child:
                          _filteredPendingOrders.isEmpty
                              ? const Center(
                                child: Text(
                                  "Tidak ada pemesanan yang menunggu pembayaran",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              )
                              : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _filteredPendingOrders.length,
                                itemBuilder: (context, index) {
                                  return _buildOrderCardWithCardWidget(
                                    _filteredPendingOrders[index],
                                    false,
                                  );
                                },
                              ),
                    ),
                  ],
                ),
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
                const Icon(Icons.hotel_outlined, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Detail Reservasi',
                    style: const TextStyle(
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),

                  // Payment status indicator
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color:
                          order['isPaid']
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: order['isPaid'] ? Colors.green : Colors.orange,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          order['isPaid']
                              ? Icons.check_circle
                              : Icons.pending_outlined,
                          color: order['isPaid'] ? Colors.green : Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          order['isPaid']
                              ? "Pembayaran Selesai"
                              : "Menunggu Pembayaran",
                          style: TextStyle(
                            color:
                                order['isPaid'] ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

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

                  const SizedBox(height: 8),

                  // Order ID at bottom
                  Text(
                    'ID Pesanan: ${order['id']}',
                    style: const TextStyle(
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
                child: const Text('Tutup'),
              ),
              if (!order['isPaid'])
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Add navigation to payment page here
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Bayar Sekarang'),
                ),
            ],
          ),
    );
  }

  // Helper method for building detail rows
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
