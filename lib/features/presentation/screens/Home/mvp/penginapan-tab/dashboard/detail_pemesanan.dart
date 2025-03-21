import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/mvp/penginapan-tab/dashboard/detail_pembayaran.dart';

class DetailPemesananPage extends StatelessWidget {
  const DetailPemesananPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Detail Pemesanan',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Main scrollable content area
          Expanded(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Image that fills the width
                    Image.asset(
                      'assets/images/detail_pemesanan.png',
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.fitWidth,
                    ),

                    // Add padding at the bottom for better scrolling experience
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Add large button at the bottom
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to payment details page or show action
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DetailPembayaranPage()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Menampilkan detail pembayaran...')),
                );
                // Add actual navigation when the payment details page is created
                // Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentDetailsPage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment, size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Lihat Detail Pembayaran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
