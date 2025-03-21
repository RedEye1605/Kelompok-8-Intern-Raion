import 'package:flutter/material.dart';

class VoucherPage extends StatelessWidget {
  const VoucherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Voucher Saya"),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Image.asset('assets/images/notFound.png', fit: BoxFit.cover,),
      ),
    );
  }
}