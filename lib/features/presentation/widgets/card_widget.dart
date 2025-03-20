import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:my_flutter_app/features/presentation/widgets/detail_page.dart';

class CardWidget extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String alamat;
  final String price;
  final double rating;
  final int ulasan;

  const CardWidget({
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
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(
              imageUrl: imageUrl,
              title: title,
              alamat: alamat,
              price: price,
              rating: rating,
              ulasan: ulasan,
            ),
          ),
        );
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            width: double.infinity,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.network(imageUrl, fit: BoxFit.cover),
                  ),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: IconButton(
                      onPressed: () {},
                      icon: Image.asset('assets/icons/Bookmark_Button.png'),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    left: 0,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(20),
                        ),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(rating.toStringAsPrecision(2)),
                                        const SizedBox(width: 5),
                                        RatingBarIndicator(
                                          rating: rating,
                                          itemBuilder: (context, index) =>
                                              const Icon(
                                            Icons.star,
                                            color: Colors.yellow,
                                          ),
                                          itemCount: 5,
                                          itemSize: 18,
                                          direction: Axis.horizontal,
                                        ),
                                        const SizedBox(width: 5),
                                        Text("($ulasan Ulasan)"),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.location_pin, size: 14),
                                        Text(
                                          alamat,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                _price(price),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// Fungsi untuk menampilkan harga
Widget _price(String? price) {
  if (price != "Gratis" && price!.isNotEmpty) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          "Mulai Dari",
          style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
        ),
        Text(
          "Rp $price",
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  if (price == "Gratis" || price == null) {
    return const Text(
      "Gratis",
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 18,
        color: Colors.blue,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  return SizedBox();
}
