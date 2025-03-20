import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/presentation/widgets/date_picker.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _namaController = TextEditingController();
  final _nomorController = TextEditingController();
  final _negaraController = TextEditingController();
  final _emailController = TextEditingController();
  final _tipeKamarController = TextEditingController();
  final _jumlahKamarController = TextEditingController();
  final _checkInController = TextEditingController();
  final _checkOutController = TextEditingController();
  
  String? _selectedNegara = "Indonesia";

  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    void initState() {
      super.initState();
      _negaraController.text = _selectedNegara!;
    }

    void _negaraChanged(String? newValue) {
      setState(() {
        _selectedNegara = newValue;
        _negaraController.text = newValue!;
      });
    }

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
                Expanded(child: PilihTanggal(hintTanggal: "Check In", controller: _checkInController,)),
                const SizedBox(width: 10),
                Expanded(child: PilihTanggal(hintTanggal: "Check Out", controller: _checkOutController,)),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tipeKamarController,
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
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _jumlahKamarController,
                    decoration: InputDecoration(
                      labelText: "Jumlah Kamar",
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
                    ),
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
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.normal,
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
                filled: true,
                fillColor: Colors.white,
                enabled: true,
              ),
              // controller: TextEditingController(text: user?.email ?? "Email tidak ditemukan"),
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
              items: [
                DropdownMenuItem(
                  value: 'Indonesia',
                  child: Row(
                    children: [
                      Image.asset('assets/icons/indonesia.png'),
                      SizedBox(width: 10),
                      Text("Indonesia"),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'Malaysia',
                  child: Row(
                    children: [
                      Image.asset('assets/icons/Malaysia.png'),
                      SizedBox(width: 10),
                      Text("Malaysia"),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'Singapura',
                  child: Row(
                    children: [
                      Image.asset('assets/icons/Singapore.png'),
                      SizedBox(width: 10),
                      Text("Singapura"),
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
              controller: _nomorController,
            ),
            Expanded(child: SizedBox(height: 10)),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _editHandle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue
                      ),
                      child: Text(
                        "Lanjutkan Pembayaran",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
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
      ).showSnackBar(SnackBar(content: Text("Pengguna tidak ditemukan")));
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('orders').doc(user.uid).set({
      'nama': _namaController.text,
      'email': _emailController.text,
      'negara': _selectedNegara,
      'nomor': _getNomorNegara(_selectedNegara) + _nomorController.text,
      'checkIn': _checkInController.text,
      'checkOut': _checkOutController.text,
      'tipeKamar': _tipeKamarController.text,
      'jumlahKamar': int.tryParse(_jumlahKamarController.text) ?? 1,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Order Berhasil dibuat")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menyimpan data: $e")));
    }
    Navigator.pushNamed(context, '/payment');
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
}
