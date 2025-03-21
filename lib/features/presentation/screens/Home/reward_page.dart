import 'package:flutter/material.dart';

class RewardPage extends StatelessWidget {
  const RewardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Pointku', style: TextStyle(fontFamily: 'Poppins'),),
      ),
      body: Container(
        child: Image.asset('assets/images/reward_page.png', fit: BoxFit.cover,),
      ),
    );
  }}