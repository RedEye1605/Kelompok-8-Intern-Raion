import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_flutter_app/features/presentation/providers/penginapan_provider.dart';
import 'package:my_flutter_app/features/presentation/widgets/card_widget.dart';
import 'package:my_flutter_app/core/usecases/usecases.dart';

class SemuaTab extends StatefulWidget {
  const SemuaTab({super.key});

  @override
  State<SemuaTab> createState() => _SemuaTabState();
}

class _SemuaTabState extends State<SemuaTab> {
  @override
  void initState() {
    super.initState();
    // Load all penginapan data when the tab is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PenginapanProvider>(context, listen: false).loadPenginapan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PenginapanProvider>(
        builder: (context, penginapanProvider, _) {
          // Show loading indicator while data is being fetched
          if (penginapanProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // If the list is empty, show a sample widget
          if (penginapanProvider.penginapanList.isEmpty) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  CardWidget(
                    imageUrl: 'https://picsum.photos/400/250',
                    title: "Enny's Guest House",
                    alamat: "Malang",
                    price: "Gratis",
                    rating: 4,
                    ulasan: 5,
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text("Belum ada data penginapan dari owner."),
                  ),
                  // Add refresh button
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      penginapanProvider.loadPenginapan();
                    },
                    child: const Text("Refresh Data"),
                  ),
                ],
              ),
            );
          }

          // Display all penginapan from various owners
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Semua Penginapan (${penginapanProvider.penginapanList.length})",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...penginapanProvider.penginapanList.map((penginapan) {
                  // Format alamat
                  String alamat = '';
                  if (penginapan.kecamatan?.isNotEmpty == true) {
                    alamat =
                        "${penginapan.kecamatan} - ${penginapan.alamatJalan}";
                  } else {
                    alamat = penginapan.alamatJalan ?? "Malang";
                  }

                  // Get price from first kategori if available
                  String harga = "0";
                  if (penginapan.kategoriKamar.isNotEmpty) {
                    final firstKategori = penginapan.kategoriKamar.values.first;
                    harga = firstKategori.harga;
                  }

                  return CardWidget(
                    imageUrl:
                        penginapan.fotoPenginapan.isNotEmpty
                            ? penginapan.fotoPenginapan.first
                            : 'https://picsum.photos/400/250',
                    title: penginapan.namaRumah,
                    alamat: alamat,
                    price: harga,
                    rating: 4.0, // Default value since rating might not exist
                    ulasan: 0, // Default value since ulasan might not exist
                    additionalImages:
                        penginapan.fotoPenginapan.length > 1
                            ? penginapan.fotoPenginapan.sublist(1)
                            : null,
                    deskripsi:
                        penginapan.kategoriKamar.isNotEmpty
                            ? penginapan.kategoriKamar.values.first.deskripsi
                            : null,
                    fasilitas:
                        penginapan.kategoriKamar.isNotEmpty
                            ? penginapan.kategoriKamar.values.first.fasilitas
                            : null,
                    kategoriKamar: penginapan.kategoriKamar,
                    linkMaps: penginapan.linkMaps,
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
