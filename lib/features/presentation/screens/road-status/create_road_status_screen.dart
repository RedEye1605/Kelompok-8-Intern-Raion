import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_flutter_app/features/domain/entities/road_status.dart';
import 'package:provider/provider.dart';
import 'package:my_flutter_app/features/presentation/providers/road_status_provider.dart';
import 'package:my_flutter_app/di/injection_container.dart' as di;
import 'package:my_flutter_app/features/data/datasources/cloudinary_service.dart';

class CreateRoadStatusScreen extends StatefulWidget {
  final bool isEditing;
  final RoadStatusEntity? roadStatusToEdit;

  const CreateRoadStatusScreen({
    Key? key,
    this.isEditing = false,
    this.roadStatusToEdit,
  }) : super(key: key);

  @override
  _CreateRoadStatusScreenState createState() => _CreateRoadStatusScreenState();
}

class _CreateRoadStatusScreenState extends State<CreateRoadStatusScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _linkMapsController = TextEditingController();
  List<XFile>? _images = [];
  List<String> _existingImages =
      []; // Untuk menyimpan URL gambar yang sudah ada
  bool _isLoading = false;
  final int _maxImages = 5;
  late RoadStatusProvider _roadStatusProvider;
  late CloudinaryService _cloudinaryService;

  @override
  void initState() {
    super.initState();
    _roadStatusProvider = Provider.of<RoadStatusProvider>(
      context,
      listen: false,
    );
    _cloudinaryService = di.sl<CloudinaryService>();

    // Pre-fill data jika dalam mode edit
    if (widget.isEditing && widget.roadStatusToEdit != null) {
      _descriptionController.text = widget.roadStatusToEdit!.description;
      _linkMapsController.text = widget.roadStatusToEdit!.linkMaps;

      // Simpan URL gambar yang sudah ada
      _existingImages = List<String>.from(widget.roadStatusToEdit!.images);
      print("Gambar yang ada: ${_existingImages.join(', ')}");
    }
  }

  Future<void> _pickImage() async {
    if (_images!.length >= _maxImages) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Maksimal 5 foto')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage();
      setState(() {
        if (pickedFiles != null) {
          if (_images!.length + pickedFiles.length > _maxImages) {
            _images = [..._images!, ...pickedFiles].sublist(0, _maxImages);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Maksimal 5 foto')));
          } else {
            _images = [..._images!, ...pickedFiles];
          }
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitReport() async {
    print("Memulai proses submit report...");
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deskripsi tidak boleh kosong')),
      );
      return;
    }

    if (_linkMapsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link Maps tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Anda harus login untuk membuat laporan');
      }

      List<File> imageFiles = [];
      if (_images != null && _images!.isNotEmpty) {
        imageFiles = _images!.map((xFile) => File(xFile.path)).toList();
      }

      // BAGIAN YANG DIUBAH - Mode Edit
      if (widget.isEditing && widget.roadStatusToEdit != null) {
        // MODE EDIT - Gunakan ID yang sudah ada
        print("Mode edit dengan ID: ${widget.roadStatusToEdit!.id}");

        final RoadStatusEntity updatedRoadStatus = RoadStatusEntity(
          id: widget.roadStatusToEdit!.id,
          userId: widget.roadStatusToEdit!.userId,
          description: _descriptionController.text.trim(),
          linkMaps: _linkMapsController.text.trim(),
          // Gabungkan gambar yang sudah ada dan gambar baru (jika ada)
          images: _existingImages,
          createdAt: widget.roadStatusToEdit!.createdAt,
        );

        if (imageFiles.isNotEmpty) {
          // Upload gambar baru dan update data dengan semua URL
          print(
            "Edit dengan gambar baru. Total gambar lama: ${_existingImages.length}",
          );

          // Tambahkan URLs gambar baru ke existing images
          List<String> newImageUrls = [];
          for (var file in imageFiles) {
            final url = await _cloudinaryService.uploadImage(file);
            if (url != null) {
              newImageUrls.add(url);
              print("Uploaded new image: $url");
            }
          }

          // Buat entity dengan semua URLs gambar
          final entityWithAllImages = RoadStatusEntity(
            id: updatedRoadStatus.id,
            userId: updatedRoadStatus.userId,
            description: updatedRoadStatus.description,
            linkMaps: updatedRoadStatus.linkMaps,
            images: [..._existingImages, ...newImageUrls],
            createdAt: updatedRoadStatus.createdAt,
          );

          // Update data di Firestore
          await _roadStatusProvider.updateExistingRoadStatus(
            entityWithAllImages,
          );

          // Kembali ke layar sebelumnya
          Navigator.pop(context, entityWithAllImages);
        } else {
          // Tidak ada gambar baru, update data dengan gambar yang sudah ada
          print(
            "Edit tanpa gambar baru, menggunakan ${_existingImages.length} gambar lama",
          );
          await _roadStatusProvider.updateExistingRoadStatus(updatedRoadStatus);
          Navigator.pop(context, updatedRoadStatus);
        }
      } else {
        // MODE CREATE - kode tidak berubah
        final RoadStatusEntity newRoadStatus = RoadStatusEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: currentUser.uid,
          description: _descriptionController.text.trim(),
          linkMaps: _linkMapsController.text.trim(),
          images: [],
          createdAt: DateTime.now(),
        );

        if (imageFiles.isNotEmpty) {
          print("Membuat baru dengan gambar");
          await _roadStatusProvider.addRoadStatusWithImages(
            newRoadStatus,
            imageFiles,
          );
        } else {
          print("Membuat baru tanpa gambar");
          await _roadStatusProvider.addRoadStatus(newRoadStatus);
        }

        Navigator.pop(context, true);
      }
    } catch (e) {
      print("Error saat submit report: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengunggah laporan: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Kondisi' : 'Tulis Kondisi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: Column(
                  children: [
                    // Content area with scrolling
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Deskripsi Laporan dengan label wajib
                            Row(
                              children: const [
                                Text(
                                  'Deskripsi Laporan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Wajib',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 14,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _descriptionController,
                              maxLines: 5,
                              decoration: InputDecoration(
                                hintText: 'Ada berita apa hari ini?',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                contentPadding: const EdgeInsets.all(12),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Link Maps dengan label wajib
                            Row(
                              children: const [
                                Text(
                                  'Link Maps',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Wajib',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 14,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _linkMapsController,
                              decoration: InputDecoration(
                                hintText: 'Masukkan link maps',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                contentPadding: const EdgeInsets.all(12),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Tambahkan foto dengan label opsional
                            Row(
                              children: const [
                                Text(
                                  'Tambahkan foto',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Opsional',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Tombol kamera berbentuk persegi
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[400]!,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          size: 30,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_images!.length}/$_maxImages',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'Tambahkan hingga $_maxImages foto untuk membantu menjelaskan kondisi jalan',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Display selected images
                            if (_images!.isNotEmpty)
                              Container(
                                height: 120,
                                margin: const EdgeInsets.only(bottom: 16),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _images!.length,
                                  itemBuilder: (context, index) {
                                    return Stack(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                            right: 8.0,
                                          ),
                                          width: 120,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                            image: DecorationImage(
                                              image: FileImage(
                                                File(_images![index].path),
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _images!.removeAt(index);
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
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
                                    );
                                  },
                                ),
                              ),

                            // Display existing images when in edit mode
                            if (widget.isEditing && _existingImages.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Gambar yang sudah ada:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 120,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _existingImages.length,
                                      itemBuilder: (context, index) {
                                        return Stack(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                right: 8.0,
                                              ),
                                              width: 120,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                    _existingImages[index],
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              right: 0,
                                              top: 0,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _existingImages.removeAt(
                                                      index,
                                                    );
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Colors.red,
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
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Button always at the bottom
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: _submitReport,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white, // Warna teks putih
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // Border radius pada tombol
                          ),
                        ),
                        child: const Text('UNGGAH'),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _linkMapsController.dispose();
    super.dispose();
  }
}
