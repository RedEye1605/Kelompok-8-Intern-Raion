import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/presentation/widgets/card_widget.dart';

class SemuaTab extends StatelessWidget {
  const SemuaTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
           CardWidget(imageUrl: 'https://picsum.photos/400/250', title: "Enny's Guest House", alamat: "Malang", price: "Gratis", rating: 4, ulasan: 5), 
          ],
        ),
      ),
    );
  }
}