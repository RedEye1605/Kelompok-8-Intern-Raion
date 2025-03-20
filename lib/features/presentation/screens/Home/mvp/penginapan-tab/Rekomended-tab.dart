import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/presentation/widgets/card_widget.dart';

class RekomendedTab extends StatelessWidget {
  const RekomendedTab({super.key});

  @override
  Widget build(BuildContext context) {
   return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
           CardWidget(imageUrl: 'https://picsum.photos/400/250',rating: 5, title: "Enny's", alamat: "Malang", price: "Gratis", ulasan: 5), 
          ],
        ),
      ),
    );
  }
}