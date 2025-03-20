import 'package:flutter/material.dart';

class SearchHotel extends StatefulWidget {
  const SearchHotel({super.key});

  @override
  State<SearchHotel> createState() => _SearchHotelState();
}

class _SearchHotelState extends State<SearchHotel> {
  List<String> _allHotel = [
      "Enny's Guest House",
      "Enny's House",
      "Guest House",
      "Enny's",
  ];

  List<String> _hasilSearchHotel = [];
  TextEditingController _searchHotelController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _hasilSearchHotel = _allHotel;
  }

  void _search(String query) {
    setState(() {
      if (query.isEmpty) {
        _hasilSearchHotel = _allHotel;
      } else {
        _hasilSearchHotel = _allHotel
            .where((hotel) => hotel.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
      appBar: AppBar( 
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: Image.asset('assets/icons/Back-Button.png')),
        toolbarHeight: 60,
        title: Expanded(
          child: SizedBox(
            height: 30,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari apapun di sini',
                hintStyle: TextStyle(color: Colors.black54,),
                hintTextDirection: TextDirection.ltr,
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
      body: _hasilSearchHotel.isNotEmpty
          ? ListView.builder(
              itemCount: _hasilSearchHotel.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.hotel),
                  title: Text(_hasilSearchHotel[index]),
                  onTap: () {
                    // Aksi ketika item diklik
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Kamu memilih ${_hasilSearchHotel[index]}")),
                    );
                  },
                );
              },
            )
          : const Center(child: Text("Tidak ada hasil ditemukan", style: TextStyle(fontSize: 16))),
      );
  }
}