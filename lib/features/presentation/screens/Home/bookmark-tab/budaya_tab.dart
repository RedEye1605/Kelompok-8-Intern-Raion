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
            ),
            CardWidget(
              imageUrl: 'https://picsum.photos/350/250',
              title: "Kampung Batik",
              alamat: "Malang",
              price: "Rp. 10.000",
            ),
            CardWidget(
              imageUrl: 'https://picsum.photos/350/250',
              title: "Kampung budaya",
              alamat: "Malang",
              price: "Rp. 2.000",
            ),
            CardWidget(
              imageUrl: 'https://picsum.photos/350/250',
              title: "Kampung Warna Warni",
              alamat: "Malang",
              price: "Rp. 15.000",
            ),
          ],
        ),
      ),
    );
  }
}
