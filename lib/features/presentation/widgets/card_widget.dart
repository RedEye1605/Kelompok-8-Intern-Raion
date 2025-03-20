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
  // Optional properties
  final List<String>? additionalImages;
  final String? deskripsi;
  final List<String>? fasilitas;
  final Map<String, dynamic>? kategoriKamar;
  final String? linkMaps;

  const CardWidget({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.alamat,
    required this.price,
    required this.rating,
    required this.ulasan,
    this.additionalImages,
    this.deskripsi,
    this.fasilitas,
    this.kategoriKamar,
    this.linkMaps,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => DetailPage(
                  imageUrl: imageUrl,
                  title: title,
                  alamat: alamat,
                  price: price,
                  rating: rating,
                  ulasan: ulasan,
                  additionalImages: additionalImages,
                  deskripsi: deskripsi,
                  fasilitas: fasilitas,
                  kategoriKamar: kategoriKamar,
                  linkMaps: linkMaps,
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
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/placeholder.png',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              rating.toStringAsPrecision(2),
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          RatingBarIndicator(
                                            rating: rating,
                                            itemBuilder:
                                                (context, index) => const Icon(
                                                  Icons.star,
                                                  color: Colors.yellow,
                                                ),
                                            itemCount: 5,
                                            itemSize: 18,
                                            direction: Axis.horizontal,
                                          ),
                                          const SizedBox(width: 5),
                                          Flexible(
                                            child: Text(
                                              "($ulasan Ulasan)",
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                              overflow:
                                                  TextOverflow
                                                      .ellipsis, // Prevent overflow
                                              maxLines: 1, // Limit to one line
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_pin,
                                            size: 14,
                                          ),
                                          Flexible(
                                            child: Text(
                                              alamat,
                                              style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Flexible(child: _price(price)),
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
