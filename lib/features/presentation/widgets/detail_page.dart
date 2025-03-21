import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:my_flutter_app/features/domain/entities/penginapan.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/mvp/order_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class DetailPage extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String alamat;
  final String price;
  final double rating;
  final int ulasan;
  final List<String>? additionalImages;
  final Map<String, dynamic>? kategoriKamar;
  final String? deskripsi;
  final List<String>? fasilitas;
  final String? linkMaps;
  final PenginapanEntity? penginapan;

  const DetailPage({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.alamat,
    required this.price,
    required this.rating,
    required this.ulasan,
    this.additionalImages,
    this.kategoriKamar,
    this.deskripsi,
    this.fasilitas,
    this.linkMaps,
    this.penginapan,
  }) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int _currentImageIndex = 0;
  String? _selectedKategori;
  String _currentDeskripsi = '';
  List<String> _currentFasilitas = [];
  String _currentPrice = '';
  String _currentJumlahKamar = '0';

  // Data dummy untuk ulasan
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

  List<String> get allImages {
    List<String> images = [widget.imageUrl];
    if (widget.additionalImages != null &&
        widget.additionalImages!.isNotEmpty) {
      images.addAll(widget.additionalImages!);
    }
    return images;
  }

  @override
  void initState() {
    super.initState();
    _initializeKategoriData();
  }

  void _initializeKategoriData() {
    // Jika ada kategori kamar, pilih yang pertama sebagai default
    if (widget.kategoriKamar != null && widget.kategoriKamar!.isNotEmpty) {
      final firstKategori = widget.kategoriKamar!.keys.first;
      _switchKategori(firstKategori);
    } else if (widget.penginapan != null &&
        widget.penginapan!.kategoriKamar.isNotEmpty) {
      final firstKategori = widget.penginapan!.kategoriKamar.keys.first;
      _switchKategori(firstKategori);
    } else {
      // Fallback ke data dasar jika tidak ada kategori
      _currentDeskripsi = widget.deskripsi ?? '';
      _currentFasilitas = widget.fasilitas ?? [];
      _currentPrice = widget.price;
      _currentJumlahKamar = '0';
    }
  }

  void _switchKategori(String kategori) {
    setState(() {
      _selectedKategori = kategori;

      if (widget.penginapan != null &&
          widget.penginapan!.kategoriKamar.containsKey(kategori)) {
        // Akses data dari entity menggunakan dot notation
        final data = widget.penginapan!.kategoriKamar[kategori]!;
        _currentDeskripsi = data.deskripsi;
        _currentFasilitas = data.fasilitas;
        _currentPrice = data.harga;
        _currentJumlahKamar = data.jumlah;
      } else if (widget.kategoriKamar != null &&
          widget.kategoriKamar!.containsKey(kategori)) {
        // Akses data dari dynamic map menggunakan bracket notation
        final data = widget.kategoriKamar![kategori];
        if (data is Map<String, dynamic>) {
          // Jika data adalah Map, akses menggunakan bracket notation
          _currentDeskripsi = data['deskripsi'] ?? '';
          _currentFasilitas = List<String>.from(data['fasilitas'] ?? []);
          _currentPrice = data['harga'] ?? widget.price;
          _currentJumlahKamar = data['jumlah'] ?? '0';
        } else if (data is KategoriKamarEntity) {
          // Jika data adalah KategoriKamarEntity, akses menggunakan dot notation
          _currentDeskripsi = data.deskripsi;
          _currentFasilitas = data.fasilitas;
          _currentPrice = data.harga;
          _currentJumlahKamar = data.jumlah;
        }
      }
    });
  }

  String _formatRupiah(String price) {
    try {
      final priceInt = int.parse(price);
      final formatter = NumberFormat.currency(
        locale: 'id',
        symbol: 'Rp',
        decimalDigits: 0,
      );
      return formatter.format(priceInt);
    } catch (e) {
      return "Rp$price";
    }
  }

  Future<void> _launchMapsURL() async {
    final url = widget.linkMaps;
    if (url == null || url.isEmpty) return;

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Tidak dapat membuka maps")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format alamat lengkap
    String fullAddress = widget.alamat;
    if (widget.penginapan != null) {
      fullAddress =
          "${widget.penginapan!.alamatJalan}, "
          "${widget.penginapan!.kelurahan}, "
          "${widget.penginapan!.kecamatan}, "
          "Kota Malang, Jawa Timur ${widget.penginapan!.kodePos}";
    }

    // Format harga
    final formattedPrice = _formatRupiah(_currentPrice);

    return Scaffold(
      body: Stack(
        children: [
          // Carousel image slider - ukuran diperbesar menjadi 80% layar
          CarouselSlider(
            options: CarouselOptions(
              height:
                  MediaQuery.of(context).size.height *
                  0.8, // Diperbesar dari 0.4 menjadi 0.8
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              autoPlay: allImages.length > 1,
              autoPlayInterval: const Duration(seconds: 5),
            ),
            items:
                allImages.map((imageUrl) {
                  // Kode image carousel tetap sama
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              imageUrl +
                                  "?v=${DateTime.now().millisecondsSinceEpoch}",
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.1),
                                Colors.black.withOpacity(
                                  0.6,
                                ), // Ditingkatkan opacity agar teks lebih terlihat
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
          ),

          // Image indicator dots - posisi disesuaikan
          if (allImages.length > 1)
            Positioned(
              bottom:
                  MediaQuery.of(context).size.height *
                  0.22, // Disesuaikan dengan perubahan ukuran gambar
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    allImages.asMap().entries.map((entry) {
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

          // Back button
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          // Bookmark button
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.bookmark_border, color: Colors.white),
              onPressed: () {},
            ),
          ),

          // Draggable Sheet for Details 
          DraggableScrollableSheet(
            initialChildSize: 0.37,
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
                // Content draggable sheet tetap sama
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

                    // Konten lainnya tetap sama
                    // Title and Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.rating.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Text(
                              " (${widget.ulasan})",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Alamat Lengkap
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
                            fullAddress,
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

                    // Kategori Kamar - dengan border radius 50%
                    const Text(
                      "Kategori Kamar",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Scrollable categories
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _buildKategoriChips(),
                      ),
                    ),

                    const SizedBox(height: 24),

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
                      _currentDeskripsi,
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
                    Wrap(
                      spacing: 10.0,
                      runSpacing: 8.0,
                      children: _buildFasilitasItems(),
                    ),

                    const SizedBox(height: 24),

                    // Foto Tambahan
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Foto",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Action untuk lihat semua foto
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
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 80,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children:
                            allImages.map((imageUrl) {
                              return Container(
                                width: 80,
                                height: 80,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Maps
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
                        child: TextButton.icon(
                          onPressed: _launchMapsURL,
                          icon: const Icon(Icons.map, size: 32),
                          label: const Text(
                            "Buka di Google Maps",
                            style: TextStyle(fontFamily: 'Poppins'),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Ulasan
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
                            // Action untuk lihat semua ulasan
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

                    // Padding di bawah untuk memberikan ruang untuk floating bar
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
                        formattedPrice + " / malam",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        "Tersisa ${_currentJumlahKamar} kamar",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Cek ketersediaan data untuk membuat pesanan
                      if (widget.penginapan == null) {
                        // Jika tidak ada objek penginapan, coba buat dari properti yang tersedia
                        if (_selectedKategori != null &&
                            _currentPrice.isNotEmpty) {
                          // Data minimal yang dibutuhkan tersedia, buat objek penginapan sederhana
                          final Map<String, KategoriKamarEntity> kategori = {
                            _selectedKategori!: KategoriKamarEntity(
                              nama: _selectedKategori!,
                              deskripsi: _currentDeskripsi,
                              fasilitas: _currentFasilitas,
                              harga: _currentPrice,
                              jumlah: _currentJumlahKamar,
                              fotoKamar: [],
                            ),
                          };

                          final simplePenginapan = PenginapanEntity(
                            id: '', // ID kosong, akan diisi oleh sistem
                            namaRumah: widget.title,
                            alamatJalan: widget.alamat,
                            kecamatan: '', // Data tidak tersedia
                            kelurahan: '',
                            kodePos: '',
                            linkMaps: widget.linkMaps ?? '',
                            kategoriKamar: kategori,
                            fotoPenginapan: allImages,
                            userID: '', // Tidak tersedia
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          );

                          // Lanjutkan ke OrderPage dengan objek sederhana
                          try {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        OrderPage(penginapan: simplePenginapan),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Terjadi kesalahan: ${e.toString()}",
                                ),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Data penginapan tidak lengkap"),
                            ),
                          );
                        }
                      } else {
                        // Gunakan data penginapan yang sudah ada
                        try {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      OrderPage(penginapan: widget.penginapan!),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Terjadi kesalahan: ${e.toString()}",
                              ),
                            ),
                          );
                        }
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
                    child: const Text(
                      "Pesan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildKategoriChips() {
    final Set<String> uniqueKategoriSet = <String>{};

    // Add entries from kategoriKamar map
    if (widget.kategoriKamar != null) {
      uniqueKategoriSet.addAll(widget.kategoriKamar!.keys);
    }

    // Add entries from penginapan entity
    if (widget.penginapan != null) {
      uniqueKategoriSet.addAll(widget.penginapan!.kategoriKamar.keys);
    }

    final List<String> kategoriList = uniqueKategoriSet.toList();

    return kategoriList.map((kategori) {
      final isSelected = _selectedKategori == kategori;
      return GestureDetector(
        onTap: () => _switchKategori(kategori),
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

  List<Widget> _buildFasilitasItems() {
    return _currentFasilitas.map((fasilitas) {
      return Container(
        width:
            MediaQuery.of(context).size.width / 2 -
            30, // 2 items per row with margins
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                fasilitas,
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
