import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_flutter_app/features/presentation/providers/penginapan_provider.dart';

class PratinjauScreen extends StatelessWidget {
  final Map<String, dynamic> rumahData;

  const PratinjauScreen({Key? key, required this.rumahData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mengambil data kategori kamar yang aktif/pertama (jika ada)
    String? currentKategori;
    Map<String, dynamic>? kategoriData;

    if (rumahData['kategoriKamar'] != null &&
        (rumahData['kategoriKamar'] as Map).isNotEmpty) {
      currentKategori = (rumahData['kategoriKamar'] as Map).keys.first;
      kategoriData = rumahData['kategoriKamar'][currentKategori];
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Pratinjau Penginapan"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto Rumah
            const Text(
              "Foto Sampul Rumah",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              height: 320, // Tinggi yang cukup untuk beberapa foto vertikal
              child:
                  rumahData['mainImages'] != null &&
                          (rumahData['mainImages'] as List).isNotEmpty
                      ? ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: (rumahData['mainImages'] as List).length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Container(
                              width: double.infinity,
                              height: 180,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(
                                    rumahData['mainImages'][index],
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      )
                      : Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            "Tidak ada foto",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ),
            ),
            const SizedBox(height: 16),

            // Nama Rumah
            const Text(
              "Nama Rumah",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(rumahData['namaRumah'] ?? "Belum ada nama rumah"),
            const SizedBox(height: 16),

            // Alamat
            const Text(
              "Alamat Rumah",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "${rumahData['alamatJalan'] ?? ''}, ${rumahData['kelurahan'] ?? ''}, ${rumahData['kecamatan'] ?? ''}, Kota Malang",
            ),
            const SizedBox(height: 16),

            // Deskripsi Kamar
            const Text(
              "Deskripsi Kamar",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              kategoriData != null
                  ? kategoriData['deskripsi'] ?? "Belum ada deskripsi"
                  : "Belum ada deskripsi",
            ),
            const SizedBox(height: 16),

            // Fasilitas Kamar
            const Text(
              "Fasilitas Kamar",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            kategoriData != null &&
                    kategoriData['fasilitas'] != null &&
                    (kategoriData['fasilitas'] as List).isNotEmpty
                ? Wrap(
                  spacing: 10,
                  children:
                      (kategoriData['fasilitas'] as List)
                          .map((fasilitas) => Chip(label: Text(fasilitas)))
                          .toList(),
                )
                : Text("Belum ada fasilitas terpilih"),
            const SizedBox(height: 16),

            // Foto Kamar
            const Text(
              "Foto Kamar",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[300],
                  child: Center(
                    child: Text(
                      "Foto 1",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[300],
                  child: Center(
                    child: Text(
                      "Foto 2",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Maps
            const Text(
              "Lokasi di Maps",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey[300],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Lokasi Maps",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    if (rumahData['linkMaps'] != null &&
                        rumahData['linkMaps'].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          rumahData['linkMaps'],
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Harga per Malam
            const Text(
              "Harga Per Malam",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Rp${kategoriData != null ? kategoriData['harga'] ?? '0' : '0'} / malam",
            ),
            const SizedBox(height: 16),

            // Jumlah Kamar
            const Text(
              "Jumlah Kamar Tersedia",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Tersedia ${kategoriData != null ? kategoriData['jumlah'] ?? '0' : '0'} kamar",
            ),
            const SizedBox(height: 16),

            // Tombol Unggah
            Center(
              child: Consumer<PenginapanProvider>(
                builder: (context, provider, child) {
                  return ElevatedButton(
                    onPressed:
                        provider.isLoading
                            ? null
                            : () async {
                              try {
                                // Rekonstruksi file dari path
                                File? imageFile;
                                if (rumahData['mainImagePaths'] != null &&
                                    rumahData['mainImagePaths'].isNotEmpty) {
                                  // Rekonstruksi File dari path yang disimpan
                                  String imagePath =
                                      rumahData['mainImagePaths'][0];
                                  imageFile = File(imagePath);
                                  print(
                                    "📂 Menggunakan file dari path: $imagePath",
                                  );
                                  print(
                                    "📂 File exists: ${await imageFile.exists()}",
                                  );
                                  print(
                                    "📂 File size: ${await imageFile.length()} bytes",
                                  );
                                } else if (rumahData['mainImages'] != null &&
                                    rumahData['mainImages'].isNotEmpty) {
                                  // Backup: Gunakan File object langsung jika tersedia
                                  imageFile = rumahData['mainImages'][0];
                                  print("📂 Menggunakan file object langsung");
                                } else {
                                  print("⚠️ Tidak ada gambar yang tersedia");
                                }

                                // Sanitize the data before submitting
                                final Map<String, dynamic> sanitizedData =
                                    Map.from(rumahData);

                                // Ensure kategoriKamar data has correct structure
                                if (sanitizedData.containsKey(
                                  'kategoriKamar',
                                )) {
                                  final Map<String, dynamic>
                                  sanitizedKategoriMap = {};

                                  (sanitizedData['kategoriKamar'] as Map)
                                      .forEach((key, value) {
                                        sanitizedKategoriMap[key] = {
                                          'deskripsi': value['deskripsi'] ?? '',
                                          'harga': value['harga'] ?? '0',
                                          'jumlah': value['jumlah'] ?? '0',
                                          // Ensure fasilitas is a List<String>
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

                                // Debugging data
                                print("===== DEBUG DATA =====");
                                (sanitizedData['kategoriKamar'] as Map).forEach((
                                  key,
                                  value,
                                ) {
                                  print("Category: $key");
                                  print(
                                    "  Deskripsi: ${value['deskripsi']} (${value['deskripsi'].runtimeType})",
                                  );
                                  print(
                                    "  Fasilitas: ${value['fasilitas']} (${value['fasilitas'].runtimeType})",
                                  );
                                  print(
                                    "  Harga: ${value['harga']} (${value['harga'].runtimeType})",
                                  );
                                  print(
                                    "  Jumlah: ${value['jumlah']} (${value['jumlah'].runtimeType})",
                                  );
                                });
                                print("======================");

                                // Use provider to save data
                                final result = await provider.createPenginapan(
                                  sanitizedData,
                                  imageFile, // Gunakan file yang direkonstruksi
                                );

                                // Handle result
                                if (result != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
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
                                  ScaffoldMessenger.of(context).showSnackBar(
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
                        horizontal: 50,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child:
                        provider.isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : const Text(
                              "Unggah",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
