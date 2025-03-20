import 'package:flutter/material.dart';





class DetailPage extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String alamat;
  final String price;
  final double rating;
  final int ulasan;

  const DetailPage({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.alamat,
    required this.price,
    required this.rating,
    required this.ulasan,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gambar di bagian atas
          Positioned.fill(child: Image.network(imageUrl, fit: BoxFit.cover)),
          // Background overlay agar teks terlihat jelas
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          // Tombol back
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: Image.asset('assets/icons/detailBack.png'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              icon: Image.asset('assets/icons/Bookmark_Button.png'),
              onPressed: () {},
            ),
          ),
          // Informasi hotel di bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
              ),
              height: 250, // Menutupi sebagian gambar
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.yellow),
                            const SizedBox(width: 5),
                            Text(rating.toStringAsPrecision(2)),
                            Text(
                              "($ulasan Ulasan)",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.black),
                        Text(alamat),
                      ],
                    ),
                    const SizedBox(height: 10),
                  
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _price(price),
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/order_page'),
                          child: Text("Pesan", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.normal, fontFamily: 'Poppins'),),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(Colors.blue),
                            minimumSize: WidgetStateProperty.all(Size(200, 50)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _price(String? price) {
  if (price != "Gratis" && price!.isNotEmpty) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Rp $price",
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("/malam"),
              ],
            ),
            Text(
              "Tersisa 2 Kamar",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ],
    );
  }
  if (price == "Gratis" || price == null) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Gratis",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text("Tersisa 2 Kamar"),
      ],
    );
  }

  return SizedBox();
}
