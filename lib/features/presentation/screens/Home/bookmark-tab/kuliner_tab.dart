import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/presentation/widgets/card_widget.dart';

class KulinerTab extends StatelessWidget {
  const KulinerTab({super.key});

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CardWidget(imageUrl: 'https://picsum.photos/350/250', title: "Kak Ros", alamat: "Malang", price: "Rp 12.000", rating: 5, ulasan: 5), 
             CardWidget(imageUrl: 'https://picsum.photos/350/250', title: "Tacibay", alamat: "Malang", price: "Rp. 10.000", rating: 5, ulasan: 5), 
             CardWidget(imageUrl: 'https://picsum.photos/350/250', title: "KopStud 24", alamat: "Malang", price: "Rp. 2.000", rating: 5, ulasan: 5), 
             CardWidget(imageUrl: 'https://picsum.photos/350/250', title: "Naoki", alamat: "Malang", price: "Rp. 15.000", rating: 5, ulasan: 5), 
          ],
        ),
      ),
    );
  }
}