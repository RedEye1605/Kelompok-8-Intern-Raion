import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/domain/entities/penginapan.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/mvp/payment_page.dart';
import 'package:my_flutter_app/features/presentation/widgets/date_picker.dart';
import 'package:intl/intl.dart';

class OrderPage extends StatefulWidget {
  final PenginapanEntity
  penginapan; // Ganti menjadi objek PenginapanEntity lengkap

  const OrderPage({super.key, required this.penginapan});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _namaController = TextEditingController();
  final _nomorController = TextEditingController();
  final _negaraController = TextEditingController();
  final _emailController = TextEditingController();
  final _jumlahKamarController = TextEditingController();
  final _checkInController = TextEditingController();
  final _checkOutController = TextEditingController();

  String? _selectedNegara = "Indonesia";
  String? _selectedKategoriKamar; // Untuk dropdown tipe kamar

  // Data kategori kamar dari penginapan
  Map<String, KategoriKamarEntity> _kategoriKamar = {};
  String _currentPrice =
      '0'; // Harga yang akan diupdate berdasarkan kategori terpilih
  int _maksimumKamar = 0; // Jumlah maksimum kamar yang tersedia
  String? _errorJumlahKamar; // Pesan error validasi

  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _negaraController.text = _selectedNegara!;
    _initializeKategoriKamar();

    // Pre-fill email from user if available
    if (user != null && user!.email != null) {
      _emailController.text = user!.email!;
    }
  }

  // Inisialisasi data kategori kamar
  void _initializeKategoriKamar() {
    _kategoriKamar = widget.penginapan.kategoriKamar;

    // Pilih kategori pertama sebagai default jika ada
    if (_kategoriKamar.isNotEmpty) {
      _selectedKategoriKamar = _kategoriKamar.keys.first;
      _updateHargaDanKetersediaan();
    }
  }

  // Update harga dan ketersediaan berdasarkan kategori yang dipilih
  void _updateHargaDanKetersediaan() {
    if (_selectedKategoriKamar != null &&
        _kategoriKamar.containsKey(_selectedKategoriKamar)) {
      setState(() {
        final kategori = _kategoriKamar[_selectedKategoriKamar]!;
        _currentPrice = kategori.harga;
        _maksimumKamar = int.tryParse(kategori.jumlah) ?? 0;

        // Reset jumlah kamar jika melebihi maksimum baru
        final currentJumlah = int.tryParse(_jumlahKamarController.text) ?? 0;
        if (currentJumlah > _maksimumKamar) {
          _jumlahKamarController.text = _maksimumKamar.toString();
        }
      });
    }
  }

  // Validasi jumlah kamar
  bool _validateJumlahKamar(String value) {
    final jumlahKamar = int.tryParse(value) ?? 0;

    if (jumlahKamar <= 0) {
      setState(() {
        _errorJumlahKamar = "Minimal pesan 1 kamar";
      });
      return false;
    } else if (jumlahKamar > _maksimumKamar) {
      setState(() {
        _errorJumlahKamar = "Maksimal tersedia $_maksimumKamar kamar";
      });
      return false;
    }

    setState(() {
      _errorJumlahKamar = null;
    });
    return true;
  }

  void _negaraChanged(String? newValue) {
    setState(() {
      _selectedNegara = newValue;
      _negaraController.text = newValue!;
    });
  }

  // Handler untuk perubahan kategori kamar
  void _kategoriKamarChanged(String? newValue) {
    setState(() {
      _selectedKategoriKamar = newValue;
      _updateHargaDanKetersediaan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final formattedPrice = _formatRupiah(_currentPrice);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Lengkapi Data Pemesanan",
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image.asset('assets/icons/Back-Button.png'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Detail Menginap",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: PilihTanggal(
                    hintTanggal: "Check In",
                    controller: _checkInController,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PilihTanggal(
                    hintTanggal: "Check Out",
                    controller: _checkOutController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: _selectedKategoriKamar,
                    ),
                    decoration: InputDecoration(
                      labelText: "Tipe Kamar",
                      labelStyle: const TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.normal,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      suffixIcon: Icon(Icons.lock_outline, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _jumlahKamarController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Jumlah Kamar (Max: $_maksimumKamar)",
                      labelStyle: const TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.normal,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      errorText: _errorJumlahKamar,
                    ),
                    onChanged: (value) {
                      _validateJumlahKamar(value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              "Detail Pemesan",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start,
            ),
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: "Nama",
                labelStyle: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.normal,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.normal,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
                filled: true,
                fillColor: Colors.white,
                enabled: true,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Pilih negara",
                labelStyle: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.normal,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              value: _selectedNegara,
              items: [
                DropdownMenuItem(
                  value: 'Indonesia',
                  child: Row(
                    children: [
                      Image.asset('assets/icons/indonesia.png'),
                      const SizedBox(width: 10),
                      const Text("Indonesia"),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'Malaysia',
                  child: Row(
                    children: [
                      Image.asset('assets/icons/Malaysia.png'),
                      const SizedBox(width: 10),
                      const Text("Malaysia"),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'Singapura',
                  child: Row(
                    children: [
                      Image.asset('assets/icons/Singapore.png'),
                      const SizedBox(width: 10),
                      const Text("Singapura"),
                    ],
                  ),
                ),
              ],
              onChanged: _negaraChanged,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                prefixText: _getNomorNegara(_selectedNegara),
                labelText: "Telepon ",
                labelStyle: const TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.normal,
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              controller: _nomorController,
            ),
            const Expanded(child: SizedBox(height: 10)),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _editHandle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        "Lanjutkan Pembayaran",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Future<void> _editHandle() async {
    
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Pengguna tidak ditemukan")));
      return;
    }

    // Add debug to verify values
    print("Penginapan ID: ${widget.penginapan.id}");
    print("Owner ID: ${widget.penginapan.userID}");

    // Fix: If penginapanId is null or empty, fetch it properly
    String penginapanId = widget.penginapan.id ?? '';
    String ownerId = widget.penginapan.userID;
   
    // If we don't have valid IDs, try to look up the actual accommodation
    if (penginapanId.isEmpty || ownerId.isEmpty) {
      try {
        // Search for the penginapan by name as a fallback
        final querySnapshot =
            await FirebaseFirestore.instance
                .collection('penginapan')
                .where('namaRumah', isEqualTo: widget.penginapan.namaRumah)
                .limit(1)
                .get();

        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          penginapanId = doc.id;
          ownerId = doc.data()['userID'] ?? '';
          print("Found penginapan by name. ID: $penginapanId, Owner: $ownerId");
        }
      } catch (e) {
        print("Error looking up penginapan: $e");
      }
    }
    
     try {
      final docRef = await FirebaseFirestore.instance.collection('orders').add({
        'userId': user.uid,
        'nama': _namaController.text,
        'email': _emailController.text,
        'negara': _selectedNegara,
        'nomor': _getNomorNegara(_selectedNegara) + _nomorController.text,
        'checkIn': _checkInController.text,
        'checkOut': _checkOutController.text,
        'tipeKamar': _selectedKategoriKamar,
        'jumlahKamar': int.tryParse(_jumlahKamarController.text) ?? 1,
        'hotelName': widget.penginapan.namaRumah,
        'price': _currentPrice,
        'penginapanId': penginapanId, // Use our fixed value
        'ownerId': ownerId, // Use our fixed value
        'status': false,
        'createdAt': FieldValue.serverTimestamp(),
        'expiredAt': DateTime.now().add(Duration(minutes: 30)),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Order Berhasil dibuat")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menyimpan data: $e")));
    }


    // Rest of your code...
    final DateTime checkInDate = DateFormat(
      'yyyy-MM-dd',
    ).parse(_checkInController.text);
    final DateTime checkOutDate = DateFormat(
      'yyyy-MM-dd',
    ).parse(_checkOutController.text);

    // Hitung jumlah hari
    final int jumlahHari = checkOutDate.difference(checkInDate).inDays;

    // Navigasi ke PaymentPage dengan order ID
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          orderID: docRef.id.toString(),
          hotelName: widget.penginapan.namaRumah,
          jumlahHari: jumlahHari,
          tipeKamar: _selectedKategoriKamar!,
          pemesan: _namaController.text,
          price: _currentPrice,
        ),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan data: $e")));
  }
}


  String _getNomorNegara(String? negara) {
    if (negara == "Indonesia") {
      return "+62 | ";
    }
    if (negara == "Malaysia") {
      return "+60 | ";
    }
    if (negara == "Singapura") {
      return "+65 | ";
    }

    return "";
  }

  String _formatRupiah(String price) {
    try {
      final priceInt = int.parse(price);
      final formatter = NumberFormat.currency(
        locale: 'id',
        symbol: 'Rp',
        decimalDigits: 0,
      );
      return formatter.format(priceInt);
    } catch (e) {
      return "Rp$price";
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nomorController.dispose();
    _negaraController.dispose();
    _emailController.dispose();
    _jumlahKamarController.dispose();
    _checkInController.dispose();
    _checkOutController.dispose();
    super.dispose();
  }
}
