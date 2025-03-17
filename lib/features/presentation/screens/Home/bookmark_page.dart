import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/bookmark-tab/budaya_tab.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/bookmark-tab/destinasi_tab.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/bookmark-tab/kuliner_tab.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/bookmark-tab/penginapan_tab.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/bookmark-tab/transportasi_tab.dart';

class BookmarkPage extends StatefulWidget {
  BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {

  final screens = [
    DestinasiTab(),
    KulinerTab(),
    BudayaTab(),
    TransportasiTab(),
    PenginapanTab()
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 60,
          title: SizedBox(
            height: 35,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari hotel termurah',
                hintStyle: TextStyle(color: Colors.black54, ),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey, width: 2),
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
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: Container(
              color: Colors.white, // Warna background untuk semua tab
              child: Builder(
                builder: (context) {
                  final TabController tabController = DefaultTabController.of(
                    context,
                  );
                  return AnimatedBuilder(
                    animation: tabController!,
                    builder: (context, child) {
                      return TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        indicator: BoxDecoration(),
                        labelPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        tabs: List.generate(5, (index) {
                          final isSelected = tabController.index == index;
                          return _buildTab(
                            ["Destinasi", "Kuliner", "Budaya", "Transportasi", "Penginapan"][index],
                            isSelected,
                          );
                        }),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
        body: 
       TabBarView(children: screens)
      ),
    );
  }

  Widget _buildTab(String text, bool isSelected) {
    return Tab(
      child: Container(
        width: 130,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color:isSelected? Colors.blue: Colors.blueGrey[100], // Background abu-abu untuk tab yang tidak dipilih
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 14, fontWeight: isSelected? FontWeight.bold:FontWeight.w500, color: isSelected? Colors.white: Colors.blue, fontFamily: 'Poppins'),
          textAlign: TextAlign.center,
          
        ),
      ),
    );
  }
}
