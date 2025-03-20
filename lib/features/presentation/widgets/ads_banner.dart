import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class AdsBanner extends StatelessWidget {
  AdsBanner({super.key});

  final List<String> imagePath = [
    'assets/images/1_poster_iklan.png',
    'assets/images/2_poster_iklan.png',
    'assets/images/3_poster_iklan.png',
    'assets/images/4_poster_iklan.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: CarouselSlider(
        items:
            imagePath
                .map(
                  (item) => ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      item,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                )
                .toList(),
        options: CarouselOptions(
          autoPlay: true,
          autoPlayInterval: Duration(seconds: 3),
          autoPlayAnimationDuration: Duration( microseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: false,
          viewportFraction: 1
        ),
      ),
    );
  }
}
