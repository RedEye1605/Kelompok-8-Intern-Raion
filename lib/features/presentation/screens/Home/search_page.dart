import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 60,
        title: Expanded(
          child: SizedBox(
            height: 30,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari apapun di sini',
                hintStyle: TextStyle(color: Colors.black54),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey, width: 2),
                ),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
                backgroundColor: Colors.grey[300],
                radius: 20,
                child: IconButton(
                  icon: Icon(Icons.sort, color: Colors.blue),
                  onPressed: () {},
                )
              ),
          ),
        ],
      ),
      body: Center(
        child: Text('Search Page'),
      ),
    );
  }
}