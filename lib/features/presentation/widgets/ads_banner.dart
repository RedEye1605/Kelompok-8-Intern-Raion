import 'package:flutter/material.dart';

class AdsBanner extends StatelessWidget {
  AdsBanner({super.key});

  final List<String> imageUrl = [
    'https://picsum.photos/id/200/1000/500',
    'https://picsum.photos/id/220/1000/500',
    'https://picsum.photos/id/240/1000/500',
    'https://picsum.photos/id/270/1000/500',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: ListView.builder(
          itemCount: imageUrl.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
      
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl[index],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}