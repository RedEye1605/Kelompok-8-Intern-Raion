import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/presentation/widgets/card_widget.dart';

class TransportasiTab extends StatelessWidget {
  const TransportasiTab({super.key});

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CardWidget(imageUrl: 'https://picsum.photos/350/250', title: "Kak Ros Car and Bike", alamat: "Malang", price: "Rp 12.000", rating: 5, ulasan: 5), 
             CardWidget(imageUrl: 'https://picsum.photos/350/250', title: "Tacibay Travel", alamat: "Malang", price: "Rp. 10.000", rating: 5, ulasan: 5), 
             CardWidget(imageUrl: 'https://picsum.photos/350/250', title: "KopStud 24 Bus", alamat: "Malang", price: "Rp. 2.000", rating: 5, ulasan: 5), 
             CardWidget(imageUrl: 'https://picsum.photos/350/250', title: "Naoki Mini Bus", alamat: "Malang", price: "Rp. 15.000", rating: 5, ulasan: 5), 
          ],
        ),
      ),
    );
  }
}