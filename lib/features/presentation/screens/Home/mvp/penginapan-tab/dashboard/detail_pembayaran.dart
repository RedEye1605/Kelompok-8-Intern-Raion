import 'package:flutter/material.dart';

class DetailPembayaranPage extends StatelessWidget {
  const DetailPembayaranPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Detail Pembayaran',
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
                      'assets/images/detail_pembayaran.jpg',
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
          ),
        ],
      ),
    );
  }
}
