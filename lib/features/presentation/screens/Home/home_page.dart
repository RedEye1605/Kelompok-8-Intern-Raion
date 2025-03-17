import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/hotel_page.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/home.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/profile_page.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/bookmark_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final screens = [
    const Home(),
    BookmarkPage(),
    const HotelPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      Image.asset(
        "assets/icons/home.png",
        color: _selectedIndex == 0 ? Colors.white : Colors.grey,
        width: 25,
      ),
      Image.asset(
        "assets/icons/bookmark.png",
        color: _selectedIndex == 1 ? Colors.white : Colors.grey,
        width: 25,
      ),
      Image.asset(
        "assets/icons/hotel.png",
        color: _selectedIndex == 2 ? Colors.white : Colors.grey,
        width: 25,
      ),
      Image.asset(
        "assets/icons/Profile.png",
        color: _selectedIndex == 3 ? Colors.white : Colors.grey,
        width: 25,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        items: items,
        index: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.grey[100]!,
        color: Colors.white,
        buttonBackgroundColor: Colors.blue,
        height: 70,
        
      ),
    );
  }
}
