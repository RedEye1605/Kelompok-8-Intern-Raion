import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_flutter_app/features/presentation/providers/penginapan_form_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_flutter_app/features/presentation/providers/penginapan_provider.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class EditRumahScreen extends StatefulWidget {
  final String penginapanId;
  final Map<String, dynamic> penginapanData;

  const EditRumahScreen({
    Key? key,
    required this.penginapanId,
    required this.penginapanData,
  }) : super(key: key);

  @override
  State<EditRumahScreen> createState() => _EditRumahScreenState();
}

class _EditRumahScreenState extends State<EditRumahScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isDeleteLoading = false;

  // Text controllers untuk form fields
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _namaRumahController = TextEditingController();
  final TextEditingController _alamatJalanController = TextEditingController();
  final TextEditingController _linkMapsController = TextEditingController();

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPenginapanData();
    });
  }

  void _loadPenginapanData() {
    final formProvider = Provider.of<PenginapanFormProvider>(
      context,
      listen: false,
    );
    formProvider.loadFromExistingData(widget.penginapanData);

    // Set values for all controllers
    _namaRumahController.text = formProvider.namaRumah;
    _alamatJalanController.text = formProvider.alamatJalan;
    _linkMapsController.text = formProvider.linkMaps;
    _deskripsiController.text = formProvider.deskripsiController.text;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final imageFile = File(image.path);
      Provider.of<PenginapanFormProvider>(
        context,
        listen: false,
      ).addMainImage(imageFile);
    }
  }

  // Add this method to pick additional photos for a room category
  Future<void> _pickAdditionalImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final imageFile = File(image.path);
      Provider.of<PenginapanFormProvider>(
        context,
        listen: false,
      ).addFotoKamar(imageFile);
    }
  }

  void _showDeleteConfirmationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              const Text(
                'Konfirmasi Password',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Untuk keamanan, masukkan password Anda untuk menghapus penginapan ini',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _showFinalDeleteConfirmation();
                  },
                  child: const Text(
                    'Selanjutnya',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showFinalDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Hapus'),
            content: const Text(
              'Anda yakin ingin menghapus penginapan ini? Tindakan ini tidak dapat dibatalkan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _performDelete,
                child:
                    _isDeleteLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          'Hapus',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ],
          ),
    );
  }

  Future<void> _performDelete() async {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password tidak boleh kosong')),
      );
      return;
    }

    try {
      setState(() => _isDeleteLoading = true);

      // Re-authenticate user
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        try {
          final credential = EmailAuthProvider.credential(
            email: user.email!,
            password: _passwordController.text,
          );

          await user.reauthenticateWithCredential(credential);

          // Delete accommodation
          final provider = Provider.of<PenginapanProvider>(
            context,
            listen: false,
          );

          // Debug print untuk melihat ID yang dikirimkan
          print(
            'Attempting to delete penginapan with ID: ${widget.penginapanId}',
          );

          // Pastikan method di provider menerima parameter dengan benar
          await provider.deletePenginapan(widget.penginapanId);

          if (mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Penginapan berhasil dihapus'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (authError) {
          print('Authentication error: $authError');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Password salah atau autentikasi gagal'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('General delete error: $e');
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleteLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    final formProvider = Provider.of<PenginapanFormProvider>(
      context,
      listen: false,
    );

    // Always save current category data before validating
    if (formProvider.currentKategori.isNotEmpty) {
      formProvider.saveCurrentKategoriData();
      print("Saved current category: ${formProvider.currentKategori}");
    }

    // Make sure all required fields for all categories are filled
    for (String kategori in formProvider.selectedKategori) {
      formProvider.switchKategori(kategori);
      // Validate this category's data here if needed
    }

    bool isValid = _formKey.currentState?.validate() ?? false;

    if (isValid) {
      _formKey.currentState?.save();

      // Check for required data
      if (!formProvider.hasMainImages &&
          formProvider.existingImageUrls.isEmpty) {
        formProvider.setImageError('Minimal satu foto rumah harus diupload');
        return;
      }

      if (formProvider.selectedKategori.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Minimal satu kategori kamar harus dipilih'),
          ),
        );
        return;
      }

      // Print category data for debugging
      final categoryData =
          formProvider.getAllData()['kategoriKamar'] as Map<String, dynamic>;
      categoryData.forEach((key, value) {
        print('Category: $key');
        print('Description: ${value['deskripsi']}');
        print('Price: ${value['harga']}');
        print('Quantity: ${value['jumlah']}');
        print('Facilities count: ${(value['fasilitas'] as List).length}');
      });

      // Update data
      setState(() => _isLoading = true);

      try {
        final data = formProvider.getAllData();
        final penginapanProvider = Provider.of<PenginapanProvider>(
          context,
          listen: false,
        );

        print('Updating penginapan with ID: ${widget.penginapanId}');
        print('Category count: ${(data['kategoriKamar'] as Map).length}');

        await penginapanProvider.updatePenginapan(
          id: widget.penginapanId,
          formData: data,
          images: formProvider.mainImages,
          existingImageUrls: formProvider.existingImageUrls,
        );

        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memperbarui: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<PenginapanFormProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Informasi Rumah",
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
              // Foto Sampul Rumah (keep as is)
              Row(
                children: const [
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
              // Photo selection section (keep as is)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Menampilkan foto yang sudah dipilih (local files)
                  if (formProvider.mainImages.isNotEmpty)
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount:
                            formProvider
                                .mainImages
                                .length, // Only local images count
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
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
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

                  // Display existing remote images separately
                  if (formProvider.existingImageUrls.isNotEmpty)
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: formProvider.existingImageUrls.length,
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
                                      image: NetworkImage(
                                        formProvider.existingImageUrls[index],
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
                                        () => formProvider.removeExistingImage(
                                          index,
                                        ),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
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
                    "${formProvider.mainImagesCount}/${formProvider.maxMainImages} foto",
                    style: const TextStyle(color: Colors.grey),
                  ),

                  if (formProvider.imageError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        formProvider.imageError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),

              // Nama Rumah
              const SizedBox(height: 24),
              Row(
                children: const [
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
                controller: _namaRumahController,
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

              // Add your form sections from create_rumah_screen.dart here

              // Alamat Lengkap Rumah
              const SizedBox(height: 24),
              Row(
                children: const [
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
                controller: _alamatJalanController,
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

              // Kode Pos
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

              // Kategori Kamar section
              const SizedBox(height: 24),
              Row(
                children: const [
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
                  ? const Text(
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
                              padding: const EdgeInsets.symmetric(
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
                                  const SizedBox(width: 4),
                                  InkWell(
                                    onTap:
                                        () =>
                                            formProvider.removeKategori(option),
                                    child: const Icon(
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
                          title: const Text("Pilih Kategori Kamar"),
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
                                              ? const Icon(
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
                              child: const Text("Tutup"),
                            ),
                          ],
                        ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit, color: Colors.blue, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        "Mengisi detail untuk: ${formProvider.currentKategori}",
                        style: const TextStyle(
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
                  children: const [
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
                  children: const [
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
                    ? const Text(
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
                              labelStyle: const TextStyle(color: Colors.blue),
                              deleteIcon: const Icon(Icons.close, size: 16),
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
                                                ? const Icon(
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
                                child: const Text("Tutup"),
                              ),
                            ],
                          ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
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
                          children: const [
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
                            SizedBox(
                              width: 80,
                              child: TextField(
                                controller:
                                    formProvider
                                        .jumlahController, // USE PROVIDER'S CONTROLLER
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onChanged: (value) {
                                  formProvider.setJumlahKamar(value);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text("kamar"),
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
                            children: const [
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
                                          .hargaController, // USE PROVIDER'S CONTROLLER
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    prefixText: "Rp ",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    formProvider.setHargaKamar(value);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text("/malam"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Foto Tambahan for current category
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

                // Display selected additional photos
                formProvider.getCurrentKategoriFoto().isNotEmpty
                    ? SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: formProvider.getCurrentKategoriFoto().length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Stack(
                              children: [
                                Container(
                                  width: 150,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(
                                        formProvider
                                            .getCurrentKategoriFoto()[index],
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
                                            formProvider.removeFotoKamar(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
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
                    )
                    : InkWell(
                      onTap: _pickAdditionalImage,
                      child: Container(
                        width: 150,
                        height: 120,
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
              ],

              // Link Maps
              const SizedBox(height: 24),
              Row(
                children: const [
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
                controller: _linkMapsController,
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

              // Bottom padding to ensure form is fully visible
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      // Bottom action buttons
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Save Changes Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 8),
            // Delete Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _isLoading ? null : _showDeleteConfirmationSheet,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Hapus Rumah',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaRumahController.dispose();
    _alamatJalanController.dispose();
    _linkMapsController.dispose();
    _deskripsiController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
