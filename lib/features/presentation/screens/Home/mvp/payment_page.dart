import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/presentation/widgets/timer_widget.dart';

class PaymentPage extends StatefulWidget {
  final String hotelName;
  final int jumlahHari;
  final String tipeKamar;
  final String pemesan;
  final String price;

  const PaymentPage({
    super.key,
    required this.hotelName,
    required this.jumlahHari,
    required this.tipeKamar,
    required this.pemesan,
    required this.price,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Pembayaran"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kartu Hotel
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "🏨 ${widget.hotelName}",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "${widget.jumlahHari} hari  •  Tipe ${widget.tipeKamar}",
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 10),
                  Image.asset('assets/icons/garis.png'),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${widget.pemesan}",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: CountdownWidget(seconds: 60*30)
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Metode Pembayaran
            ListTile(
              title: Text("Metode Pembayaran"),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            // Gunakan Voucher
            ListTile(
              title: Text("Gunakan Voucher"),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
              child: Text("atau", style: TextStyle(fontFamily: 'Poppins', ) ,),
            ),
            SizedBox(height: 10),

            // Input Voucher
            TextField(
              decoration: InputDecoration(
                hintText: "Masukkan kode voucher",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),

            SizedBox(height: 20),

            // Rincian Harga
            Text(
              "Rincian Harga",
              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins', fontSize: 24),
            ), 
            SizedBox(height: 10),
            Image.asset('assets/icons/garis.png', color: Colors.black,),
            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text("Harga hotel x ${widget.jumlahHari}"), Text("Rp ${widget.price}")],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Text("Pajak 10%"),
              Text("Rp ${(double.parse(widget.price) * 0.1).toStringAsFixed(2)}"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Text("Biaya admin 5%"),
              Text("Rp ${(double.parse(widget.price) * 0.05).toStringAsFixed(2)}"),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                Text(
                    "Rp ${(double.parse(widget.price) * widget.jumlahHari + (double.parse(widget.price) * 0.1) + (double.parse(widget.price) * 0.05)).toStringAsFixed(2)}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ],
            ),

            Spacer(),

            // Tombol Konfirmasi
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  "Konfirmasi Pembayaran",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
