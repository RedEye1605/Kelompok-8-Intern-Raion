import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/presentation/widgets/ads_banner.dart';
import 'package:my_flutter_app/features/presentation/widgets/card_widget.dart';

class Home extends StatelessWidget {
  const Home({super.key});
  final double _lebar = double.infinity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        title: Row(
          children: [
            // Search Bar
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.black54), // Outline color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  backgroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pushNamed(context, '/search'),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey, size: 25),
                    SizedBox(width: 10),
                    Text(
                      'Cari apapun di sini',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Icon lingkaran 1
            GestureDetector(
              onTap: () {},
              child: CircleAvatar(
                backgroundColor: Colors.grey[300],
                radius: 20,
                child: Image.asset("assets/icons/reward.png"),
              ),
            ),
            const SizedBox(width: 10),
            // Icon lingkaran 2
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/settings'),
              child: CircleAvatar(
                backgroundColor: Colors.grey[300],
                radius: 20,
                child: Image.asset("assets/icons/setting.png"),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.all(16.0), child: AdsBanner()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Image.asset("assets/icons/explore-btn.png"),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/hotelPage');
                  },
                  icon: Image.asset("assets/icons/hotel-btn.png"),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/road_status');
                  },
                  icon: Image.asset("assets/icons/road-btn.png"),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Image.asset("assets/icons/transport-btn.png"),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Sedang Tren",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            CardWidget(
              imageUrl: 'https://picsum.photos/id/200/1000/400',
              title: 'Kampung Warna Warni',
              alamat: 'Sidoarjo',
              price: "Gratis",
            ),
            CardWidget(
              imageUrl: 'https://picsum.photos/id/200/1000/400',
              title: 'Kampung Warna Warni',
              alamat: 'Sidoarjo',
              price: "Gratis",
            ),
            CardWidget(
              imageUrl: 'https://picsum.photos/id/200/1000/400',
              title: 'Kampung Warna Warni',
              alamat: 'Sidoarjo',
              price: "Gratis",
            ),
            CardWidget(imageUrl: 'https://picsum.photos/id/200/1000/400',title:'Kampung Warna Warni', alamat: 'Sidoarjo', price: "Gratis",rating: 5, ulasan: 5,),
            CardWidget(imageUrl: 'https://picsum.photos/id/200/1000/400',title:'Kampung Warna Warni', alamat: 'Sidoarjo', price: "Gratis",rating: 5, ulasan: 5),
            CardWidget(imageUrl: 'https://picsum.photos/id/200/1000/400',title:'Kampung Warna Warni', alamat: 'Sidoarjo', price: "Gratis",rating: 5, ulasan: 5),
            CardWidget(imageUrl: 'https://picsum.photos/id/200/1000/400',title:'Kamping Warna Warni', alamat: 'Sidoarjo', price: "Gratis",rating: 5, ulasan: 5),
            ],
        ),
      ),
    );
  }
}
