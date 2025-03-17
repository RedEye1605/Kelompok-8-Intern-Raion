import 'package:flutter/material.dart';

class HotelPage extends StatelessWidget {
  const HotelPage ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hotel Page'),
      ),
      body: Center(
        child: Text('Hotel Page'),
      ),
    );
  }
}