import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/presentation/widgets/card_widget.dart';

class TerdekatTab extends StatelessWidget {
  const TerdekatTab({super.key});

  @override
  Widget build(BuildContext context) {
   return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
           CardWidget(imageUrl: 'https://picsum.photos/400/250', title: "Guest House", alamat: "Malang", price: "Gratis",rating: 3, ulasan: 5), 
          ],
        ),
      ),
    );
  }
}