import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/presentation/widgets/card_widget.dart';

class BudayaTab extends StatelessWidget {
  const BudayaTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CardWidget(
              imageUrl: 'https://picsum.photos/350/250',
              title: "Museum Mpu Warna",
              alamat: "Malang",
              price: "Rp 12.000",
              rating: 5, ulasan: 5
            ),
            CardWidget(
              imageUrl: 'https://picsum.photos/350/250',
              title: "Kampung Batik",
              alamat: "Malang",
              price: "Rp. 10.000",
              rating: 5, ulasan: 5
            ),
          ],
        ),
      ),
    );
  }
}
