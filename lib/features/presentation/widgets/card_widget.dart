import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String alamat;
  final String price;
  const CardWidget({super.key, required this.imageUrl, required this.title, required this.alamat, required this.price});

  final double _lebar = double.infinity;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          width: _lebar,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 5, // Increased elevation for shadow
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(imageUrl, fit: BoxFit.cover),
                ),
                Positioned(
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
                                  Image.asset("assets/icons/star.png"),
                                  Text(
                                    "5/5 (170 ulasan)",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    price,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 18,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  Text(alamat, style: TextStyle(fontFamily: 'Poppins', fontSize: 14),)
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  right: 0,
                  bottom: 0,
                  left: 0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
