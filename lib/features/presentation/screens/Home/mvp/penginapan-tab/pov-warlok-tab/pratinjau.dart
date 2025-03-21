import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_flutter_app/features/presentation/providers/penginapan_provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PratinjauScreen extends StatefulWidget {
  final Map<String, dynamic> rumahData;

  const PratinjauScreen({Key? key, required this.rumahData}) : super(key: key);

  @override
  State<PratinjauScreen> createState() => _PratinjauScreenState();
}

class _PratinjauScreenState extends State<PratinjauScreen> {
  int _currentImageIndex = 0;
  String? _selectedKategori;
  List<File> _images = [];

  // Tambahkan data dummy untuk ulasan
  final List<Map<String, dynamic>> _dummyReviews = [
    {
      'name': 'Budi Santoso',
      'rating': 5.0,
      'comment': 'Kamar bersih dan nyaman, pelayanan ramah',
      'date': '15 Maret 2023',
      'image': 'https://randomuser.me/api/portraits/men/1.jpg',
    },
    {
      'name': 'Siti Nurmala',
      'rating': 4.5,
      'comment': 'Lokasinya strategis, dekat dengan kampus',
      'date': '2 April 2023',
      'image': 'https://randomuser.me/api/portraits/women/2.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // Mengambil data kategori kamar yang aktif/pertama (jika ada)
    if (widget.rumahData['kategoriKamar'] != null &&
        (widget.rumahData['kategoriKamar'] as Map).isNotEmpty) {
      setState(() {
        _selectedKategori =
            (widget.rumahData['kategoriKamar'] as Map).keys.first;
      });
    }

    // Mengambil gambar
    if (widget.rumahData['mainImages'] != null &&
        (widget.rumahData['mainImages'] as List).isNotEmpty) {
      setState(() {
        _images = List<File>.from(widget.rumahData['mainImages']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil data kategori yang dipilih
    Map<String, dynamic>? kategoriData;
    if (_selectedKategori != null &&
        widget.rumahData['kategoriKamar'] != null) {
      kategoriData = widget.rumahData['kategoriKamar'][_selectedKategori];
    }

    return Scaffold(
      body: Stack(
        children: [
          // Carousel image slider
          CarouselSlider(
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height * 0.8,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              autoPlay: _images.length > 1,
              autoPlayInterval: const Duration(seconds: 5),
            ),
            items:
                _images.isEmpty
                    ? [_buildEmptyImagePlaceholder()]
                    : _images.map((file) => _buildImageItem(file)).toList(),
          ),

          // Image indicator dots
          if (_images.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.22,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    _images.asMap().entries.map((entry) {
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              _currentImageIndex == entry.key
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                        ),
                      );
                    }).toList(),
              ),
            ),

          // Edit button
          Positioned(
            top: 40,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 24,
                ),
                tooltip: 'Edit data',
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Draggable Sheet for Details
          DraggableScrollableSheet(
            initialChildSize: 0.37, // Sesuaikan ukuran sesuai permintaan
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Pull handle indicator
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // Nama Rumah
                    Text(
                      widget.rumahData['namaRumah'] ?? "Belum ada nama",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Alamat
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "${widget.rumahData['alamatJalan'] ?? ''}, ${widget.rumahData['kelurahan'] ?? ''}, ${widget.rumahData['kecamatan'] ?? ''}, Kota Malang",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Kategori Kamar - jika ada
                    if (widget.rumahData['kategoriKamar'] != null &&
                        (widget.rumahData['kategoriKamar'] as Map)
                            .isNotEmpty) ...[
                      const Text(
                        "Kategori Kamar",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _buildKategoriChips(),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Deskripsi Kamar
                    const Text(
                      "Deskripsi Kamar",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      kategoriData != null
                          ? kategoriData['deskripsi'] ?? "Belum ada deskripsi"
                          : "Belum ada deskripsi",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontFamily: 'Poppins',
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Fasilitas Kamar
                    const Text(
                      "Fasilitas Kamar",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    kategoriData != null &&
                            kategoriData['fasilitas'] != null &&
                            (kategoriData['fasilitas'] as List).isNotEmpty
                        ? Wrap(
                          spacing: 10.0,
                          runSpacing: 8.0,
                          children: _buildFasilitasItems(
                            kategoriData['fasilitas'],
                          ),
                        )
                        : const Text("Belum ada fasilitas terpilih"),

                    const SizedBox(height: 24),

                    // Lokasi di Maps
                    const Text(
                      "Lokasi",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[200],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.map, size: 32),
                            const SizedBox(height: 8),
                            if (widget.rumahData['linkMaps'] != null &&
                                widget.rumahData['linkMaps'].isNotEmpty)
                              Text(
                                widget.rumahData['linkMaps'],
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontFamily: 'Poppins',
                                ),
                              )
                            else
                              const Text(
                                "Belum ada link maps",
                                style: TextStyle(fontFamily: 'Poppins'),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Tambahkan bagian ulasan
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Ulasan",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Action untuk lihat semua ulasan (tidak diimplementasikan)
                          },
                          child: const Text(
                            "Lihat semua",
                            style: TextStyle(
                              color: Colors.blue,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._dummyReviews.map((review) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(review['image']),
                          ),
                          title: Text(
                            review['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < review['rating']
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 16,
                                  );
                                }),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                review['comment'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                review['date'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                    // Padding untuk floating bar
                    const SizedBox(height: 80),
                  ],
                ),
              );
            },
          ),

          // Floating Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Rp${kategoriData != null ? kategoriData['harga'] ?? '0' : '0'} / malam",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        "Tersedia ${kategoriData != null ? kategoriData['jumlah'] ?? '0' : '0'} kamar",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  Consumer<PenginapanProvider>(
                    builder: (context, provider, child) {
                      return ElevatedButton(
                        onPressed:
                            provider.isLoading
                                ? null
                                : () async {
                                  try {
                                    List<File> imageFiles = [];

                                    if (widget.rumahData['mainImagePaths'] !=
                                            null &&
                                        widget
                                            .rumahData['mainImagePaths']
                                            .isNotEmpty) {
                                      for (String path
                                          in widget
                                              .rumahData['mainImagePaths']) {
                                        File file = File(path);
                                        if (await file.exists()) {
                                          imageFiles.add(file);
                                        }
                                      }
                                    } else if (widget.rumahData['mainImages'] !=
                                            null &&
                                        widget
                                            .rumahData['mainImages']
                                            .isNotEmpty) {
                                      imageFiles = List<File>.from(
                                        widget.rumahData['mainImages'],
                                      );
                                    }

                                    final Map<String, dynamic> sanitizedData =
                                        Map.from(widget.rumahData);

                                    if (sanitizedData.containsKey(
                                      'kategoriKamar',
                                    )) {
                                      final Map<String, dynamic>
                                      sanitizedKategoriMap = {};

                                      (sanitizedData['kategoriKamar'] as Map)
                                          .forEach((key, value) {
                                            sanitizedKategoriMap[key] = {
                                              'deskripsi':
                                                  value['deskripsi'] ?? '',
                                              'harga': value['harga'] ?? '0',
                                              'jumlah': value['jumlah'] ?? '0',
                                              'fasilitas':
                                                  value['fasilitas'] is List
                                                      ? List<String>.from(
                                                        value['fasilitas'],
                                                      )
                                                      : (value['fasilitas'] !=
                                                              null &&
                                                          value['fasilitas']
                                                              .toString()
                                                              .isNotEmpty)
                                                      ? [
                                                        value['fasilitas']
                                                            .toString(),
                                                      ]
                                                      : <String>[],
                                            };
                                          });

                                      sanitizedData['kategoriKamar'] =
                                          sanitizedKategoriMap;
                                    }

                                    final result = await provider
                                        .createPenginapan(
                                          sanitizedData,
                                          imageFiles,
                                        );

                                    if (result != null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Data rumah berhasil disimpan",
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.popUntil(
                                        context,
                                        (route) => route.isFirst,
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            provider.errorMessage ??
                                                "Gagal menyimpan data",
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Error: ${e.toString()}"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child:
                            provider.isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  "Unggah",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyImagePlaceholder() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(color: Colors.grey[300]),
      child: const Center(
        child: Text(
          "Tidak ada foto",
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildImageItem(File file) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.1),
              Colors.black.withOpacity(0.6),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildKategoriChips() {
    final List kategoriList =
        (widget.rumahData['kategoriKamar'] as Map).keys.toList();

    return kategoriList.map((kategori) {
      final isSelected = _selectedKategori == kategori;
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedKategori = kategori;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            kategori,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.blue,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildFasilitasItems(List fasilitas) {
    return fasilitas.map<Widget>((item) {
      return Container(
        width: MediaQuery.of(context).size.width / 2 - 30,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
