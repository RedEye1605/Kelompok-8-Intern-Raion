import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/mvp/penginapan-tab/pov-warlok-tab/pratinjau.dart';
import 'package:provider/provider.dart';
import 'package:my_flutter_app/features/presentation/providers/penginapan_form_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateRumahScreen extends StatefulWidget {
  const CreateRumahScreen({super.key});

  @override
  State<CreateRumahScreen> createState() => _CreateRumahScreenState();
}

class _CreateRumahScreenState extends State<CreateRumahScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  // Text controllers untuk form fields
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();

  // Form values
  String alamatJalan = '';
  String kecamatan = 'Lowokwaru'; // Default value
  String kelurahan = 'Jatimulyo'; // Default value
  String kodePos = '65141'; // Default value
  String linkMaps = '';

  // Options untuk dropdowns
  final List<String> _kecamatanOptions = [
    'Lowokwaru',
    'Sukun',
    'Klojen',
    'Blimbing',
    'Kedungkandang',
  ];

  final Map<String, List<String>> _kelurahanOptions = {
    'Lowokwaru': [
      'Jatimulyo',
      'Landungsari',
      'Dinoyo',
      'Merjosari',
      'Tlogomas',
    ],
    'Sukun': ['Sukun', 'Ciptomulyo', 'Bandungrejosari', 'Tanjungrejo'],
    'Klojen': ['Klojen', 'Oro-oro Dowo', 'Samaan', 'Rampal Celaket'],
  };

  final List<String> _kodePosOptions = [
    '65141',
    '65142',
    '65143',
    '65144',
    '65145',
  ];

  final List<String> _kategoriKamarOptions = [
    'Kamar Atas',
    'Kamar Bawah',
    'Kamar Utama',
    'Kamar Samping',
  ];

  final List<String> _fasilitasOptions = [
    'Kamar mandi dalam',
    'Wi-Fi',
    'Pendingin Ruangan',
    'TV',
    'Kulkas',
    'Tempat Parkir',
    'Dapur Bersama',
    'Akses 24 Jam',
  ];

  @override
  void initState() {
    super.initState();
    // Pastikan controller bersih saat layar dimuat
    final formProvider = Provider.of<PenginapanFormProvider>(
      context,
      listen: false,
    );
    formProvider.deskripsiController.clear();
    formProvider.hargaController.clear();
    formProvider.jumlahController.clear();
  }

  @override
  void dispose() {
    // Provider akan menangani dispose controller-nya sendiri
    // melalui dispose() di PenginapanFormProvider
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final imageFile = File(image.path);

      // Gunakan metode baru untuk menambahkan foto
      Provider.of<PenginapanFormProvider>(
        context,
        listen: false,
      ).addMainImage(imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<PenginapanFormProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Isi Informasi Rumahmu",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto Samping Rumah
              Row(
                children: [
                  Text(
                    "Foto Sampul Rumah ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "wajib",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Menampilkan foto yang sudah dipilih
                  if (formProvider.mainImagesCount > 0)
                    Container(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: formProvider.mainImagesCount,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Stack(
                              children: [
                                Container(
                                  width: 200,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(
                                        formProvider.mainImages[index],
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: InkWell(
                                    onTap:
                                        () =>
                                            formProvider.removeMainImage(index),
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  // Tombol untuk menambah foto
                  if (formProvider.canAddMoreMainImages)
                    InkWell(
                      onTap: _pickImage,
                      child: Container(
                        width: 200,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Tambah foto",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Counter untuk foto
                  const SizedBox(height: 8),
                  Text(
                    "${formProvider.mainImagesCount}/${formProvider.maxMainImages}",
                    style: TextStyle(color: Colors.grey),
                  ),

                  if (formProvider.imageError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        formProvider.imageError!,
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),

              // Nama Rumah
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    "Nama Rumah ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "wajib",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: formProvider.namaRumah,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorStyle: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                onChanged: (value) => formProvider.setNamaRumah(value),
                validator:
                    (value) =>
                        value?.isEmpty ?? true
                            ? 'Nama rumah harus diisi'
                            : null,
              ),
              const SizedBox(height: 24),

              // Alamat Lengkap Rumah
              Row(
                children: [
                  Text(
                    "Alamat Lengkap Rumah ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "wajib",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Alamat Jalan
              TextFormField(
                initialValue: formProvider.alamatJalan,
                decoration: InputDecoration(
                  hintText: "Alamat Jalan (termasuk No. Rumah, RT, RW)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) => formProvider.setAlamatJalan(value),
                validator:
                    (value) =>
                        value?.isEmpty ?? true
                            ? 'Alamat jalan harus diisi'
                            : null,
              ),
              const SizedBox(height: 16),

              // Kecamatan dan Kelurahan
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Kecamatan",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      value: formProvider.kecamatan,
                      items:
                          _kecamatanOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          formProvider.setKecamatan(newValue);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Kelurahan",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      value: formProvider.kelurahan,
                      items:
                          (_kelurahanOptions[formProvider.kecamatan] ?? []).map(
                            (String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            },
                          ).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          formProvider.setKelurahan(newValue);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Kota, Provinsi dan Kode Pos dalam satu row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: "Malang",
                      decoration: InputDecoration(
                        labelText: "Kota",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      enabled: false, // Kota fixed - tidak bisa diedit
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: "Jawa Timur",
                      decoration: InputDecoration(
                        labelText: "Provinsi",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      enabled: false, // Provinsi fixed - tidak bisa diedit
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Kode Pos",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                value: formProvider.kodePos,
                items:
                    _kodePosOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    formProvider.setKodePos(newValue);
                  }
                },
              ),
              const SizedBox(height: 24),

              // Kategori Kamar
              Row(
                children: [
                  Text(
                    "Kategori Kamar ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "wajib",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Selected categories display
              formProvider.selectedKategori.isEmpty
                  ? Text(
                    "Belum ada kategori dipilih",
                    style: TextStyle(color: Colors.grey),
                  )
                  : Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children:
                        formProvider.selectedKategori.map((option) {
                          bool isActive =
                              option == formProvider.currentKategori;
                          return GestureDetector(
                            onTap: () => formProvider.switchKategori(option),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isActive
                                        ? Colors.blue
                                        : Colors.blue.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(30),
                                border:
                                    isActive
                                        ? Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        )
                                        : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    option,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight:
                                          isActive
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  InkWell(
                                    onTap:
                                        () =>
                                            formProvider.removeKategori(option),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
              const SizedBox(height: 10),

              // Add custom category button
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text("Pilih Kategori Kamar"),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children:
                                  _kategoriKamarOptions.map((option) {
                                    final bool isSelected = formProvider
                                        .selectedKategori
                                        .contains(option);
                                    return ListTile(
                                      title: Text(option),
                                      trailing:
                                          isSelected
                                              ? Icon(
                                                Icons.check,
                                                color: Colors.blue,
                                              )
                                              : null,
                                      onTap: () {
                                        if (isSelected) {
                                          formProvider.removeKategori(option);
                                        } else {
                                          formProvider.addKategori(option);
                                        }
                                        Navigator.pop(context);
                                      },
                                    );
                                  }).toList(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Tutup"),
                            ),
                          ],
                        ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.blue, size: 16),
                      SizedBox(width: 4),
                      Text("Tambahkan", style: TextStyle(color: Colors.blue)),
                    ],
                  ),
                ),
              ),

              // Show additional fields only if a category is active
              if (formProvider.currentKategori.isNotEmpty) ...[
                const SizedBox(height: 24),

                // Indikator kategori yang sedang diedit
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue, size: 16),
                      SizedBox(width: 8),
                      Text(
                        "Mengisi detail untuk: ${formProvider.currentKategori}",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Deskripsi Kamar
                Row(
                  children: [
                    Text(
                      "Deskripsi Kamar ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "wajib",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // TextField untuk Deskripsi Kamar
                TextField(
                  controller:
                      formProvider.deskripsiController, // GUNAKAN CONTROLLER
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Contoh: Kamar nyaman dengan ukuran 3x4...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    // TETAP PANGGIL SETTER untuk memperbarui data model
                    formProvider.setDeskripsiKamar(value);
                  },
                ),
                const SizedBox(height: 16),

                // Fasilitas Kamar
                Row(
                  children: [
                    Text(
                      "Fasilitas ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "wajib",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Selected facilities display
                formProvider.getCurrentKategoriFasilitas().isEmpty
                    ? Text(
                      "Belum ada fasilitas dipilih",
                      style: TextStyle(color: Colors.grey),
                    )
                    : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          formProvider.getCurrentKategoriFasilitas().map((
                            fasilitas,
                          ) {
                            return Chip(
                              label: Text(fasilitas),
                              backgroundColor: Colors.blue.shade50,
                              labelStyle: TextStyle(color: Colors.blue),
                              deleteIcon: Icon(Icons.close, size: 16),
                              onDeleted: () {
                                formProvider.removeFasilitas(fasilitas);
                              },
                            );
                          }).toList(),
                    ),
                const SizedBox(height: 8),

                // Add facility button
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text(
                              "Pilih Fasilitas untuk ${formProvider.currentKategori}",
                            ),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children:
                                    _fasilitasOptions.map((option) {
                                      final bool isSelected = formProvider
                                          .getCurrentKategoriFasilitas()
                                          .contains(option);
                                      return ListTile(
                                        title: Text(option),
                                        trailing:
                                            isSelected
                                                ? Icon(
                                                  Icons.check,
                                                  color: Colors.blue,
                                                )
                                                : null,
                                        onTap: () {
                                          if (isSelected) {
                                            formProvider.removeFasilitas(
                                              option,
                                            );
                                          } else {
                                            formProvider.addFasilitas(option);
                                          }
                                          Navigator.pop(context);
                                        },
                                      );
                                    }).toList(),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Tutup"),
                              ),
                            ],
                          ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.blue, size: 16),
                        SizedBox(width: 4),
                        Text("Tambahkan", style: TextStyle(color: Colors.blue)),
                      ],
                    ),
                  ),
                ),

                // Jumlah Kamar dan Harga
                const SizedBox(height: 16),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Jumlah ",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "wajib",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.black54,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 80,
                              child: TextField(
                                controller:
                                    formProvider
                                        .jumlahController, // GUNAKAN CONTROLLER
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onChanged: (value) {
                                  // TETAP PANGGIL SETTER untuk memperbarui data model
                                  formProvider.setJumlahKamar(value);
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            Text("kamar"),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Harga ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "wajib",
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller:
                                      formProvider
                                          .hargaController, // GUNAKAN CONTROLLER
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    prefixText: "Rp ",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    // TETAP PANGGIL SETTER untuk memperbarui data model
                                    formProvider.setHargaKamar(value);
                                  },
                                ),
                              ),
                              SizedBox(width: 8),
                              Text("/malam"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Foto Kamar
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      "Foto Tambahan ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Opsional",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 150,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          "Klik untuk memilih foto",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text("0/10", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],

              // Link Maps
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    "Link Maps ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "wajib",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: formProvider.linkMaps,
                decoration: InputDecoration(
                  hintText: "Contoh: https://maps.google.com/?q=...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) => formProvider.setLinkMaps(value),
                validator:
                    (value) =>
                        value?.isEmpty ?? true ? 'Link Maps harus diisi' : null,
              ),
              const SizedBox(height: 32),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    print("Button clicked");
                    
                    // Simpan data kategori yang aktif terlebih dahulu
                    if (formProvider.currentKategori.isNotEmpty) {
                      print("Saving current kategori data");
                      formProvider.saveCurrentKategoriData();
                      print("Current kategori data saved");
                    }
                  
                    // Validasi semua data
                    print("Starting form validation");
                    bool isValid = _formKey.currentState?.validate() ?? false;
                    print("Form validation result: $isValid");
                    
                    if (isValid) {
                      _formKey.currentState?.save();
                  
                      // Validasi gambar
                      print("Checking images: ${formProvider.hasMainImages}");
                      if (!formProvider.hasMainImages) {
                        formProvider.setImageError('Minimal satu foto rumah harus diupload');
                        return;
                      }
                  
                      // Validasi kategori kamar
                      print("Checking categories: ${formProvider.selectedKategori}");
                      if (formProvider.selectedKategori.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Minimal satu kategori kamar harus dipilih')),
                        );
                        return;
                      }
                  
                      // Get data and navigate
                      try {
                        print("Getting all data");
                        final data = formProvider.getAllData();
                        print("Data retrieved successfully");
                        
                        print("Attempting navigation to PratinjauScreen");
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PratinjauScreen(rumahData: data),
                          ),
                        );
                      } catch (e) {
                        print("Error during navigation: $e");
                      }
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
                  child: const Text(
                    "Lihat Pratinjau",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
