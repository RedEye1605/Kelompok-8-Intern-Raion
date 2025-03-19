import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/presentation/widgets/card_widget.dart';

class DestinasiTab extends StatelessWidget {
  const DestinasiTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
           CardWidget(imageUrl: 'https://picsum.photos/400/250', title: "Taman Merjo", alamat: "Malang", price: "Gratis",), 
           CardWidget(imageUrl: 'https://picsum.photos/400/250', title: "Alun-alun Malang", alamat: "Malang", price: "Gratis"), 
           CardWidget(imageUrl: 'https://picsum.photos/400/250', title: "Candi Singosari", alamat: "Malang", price: "Gratis"), 
           CardWidget(imageUrl: 'https://picsum.photos/400/250', title: "Jatim park", alamat: "Malang", price: "Gratis"), 
          ],
        ),
      ),
    );
  }
}