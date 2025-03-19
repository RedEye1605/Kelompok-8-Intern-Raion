import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class AdsBanner extends StatelessWidget {
  AdsBanner({super.key});

  final List<String> imageUrl = [
    'https://picsum.photos/id/200/1000/300',
    'https://picsum.photos/id/220/1000/300',
    'https://picsum.photos/id/240/1000/300',
    'https://picsum.photos/id/270/1000/300',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: CarouselSlider(
        items:
            imageUrl
                .map(
                  (item) => ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
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
