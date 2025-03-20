import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/presentation/widgets/card_widget.dart';

class PopulerTab extends StatelessWidget {
  const PopulerTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
           CardWidget(imageUrl: 'https://picsum.photos/500/250',rating: 4, title: "Enny's House", alamat: "Malang", price: "Gratis", ulasan: 5), 
           CardWidget(imageUrl: 'https://picsum.photos/500/250',rating: 4, title: "Enny's House", alamat: "Malang", price: "50.000", ulasan: 5), 
          ],
        ),
      ),
    );
  }
}