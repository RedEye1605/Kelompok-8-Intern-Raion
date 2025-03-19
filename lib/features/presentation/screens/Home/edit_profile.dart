// ignore_for_file: unused_local_variable

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_flutter_app/features/data/datasources/cloudinary_service.dart';
import 'package:http/http.dart' as http;

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _namaController = TextEditingController();
  final _nomorController = TextEditingController();
  final _negaraController = TextEditingController();
  String? _selectedNegara = "Indonesia";

  final User? user = FirebaseAuth.instance.currentUser;
  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  File? imageFile;
  String? uploadImageURL;

  // mobile picker
  Future<void> _pickAndUploadProfilePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
      );

      if (image != null) {
        setState(() {
          imageFile = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error memilih gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _uploadToCloudinary(File imageFile) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/dak6uyba7/image/upload',
    );

    var request =
        http.MultipartRequest('POST', url)
          ..fields['upload_preset'] = 'testing'
          ..files.add(
            await http.MultipartFile.fromPath('file', imageFile.path),
          );

    var response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);
      return jsonData['secure_url']; // URL gambar yang telah diunggah
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Add this method call
  }

  // Add this method to load existing user data
  Future<void> _loadUserData() async {
    try {
      if (user != null) {
        final userData =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user!.uid)
                .get();

        if (userData.exists && mounted) {
          setState(() {
            _namaController.text = userData.data()?['nama'] ?? '';
            _nomorController.text = userData.data()?['nomor'] ?? '';
            _selectedNegara = userData.data()?['negara'] ?? 'Indonesia';
            _negaraController.text = _selectedNegara!;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Widget _buildProfileImage() {
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[300]!, width: 2),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200],
            backgroundImage: _getProfileImage(),
          ),
        ),
        Positioned(
          bottom: -10,
          right: -10,
          child: IconButton(
            onPressed: _pickAndUploadProfilePhoto,
            icon: Image.asset(
              "assets/icons/edit_photo.png",
              width: 34,
              height: 34,
            ),
          ),
        ),
      ],
    );
  }

  ImageProvider _getProfileImage() {
    if (imageFile != null) {
      return FileImage(imageFile!);
    }

    if (user?.photoURL != null && user!.photoURL!.isNotEmpty) {
      return NetworkImage(user!.photoURL!);
    }

    return const AssetImage('assets/icons/profile-icon.png');
  }

  @override
  Widget build(BuildContext context) {
    void negaraChanged(String? newValue) {
      setState(() {
        _selectedNegara = newValue;
        _negaraController.text = newValue!;
      });
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Akun dan Profil',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 80,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/profile_page.png"),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 100),
                _buildProfileImage(),
                SizedBox(height: 24),
                Column(
                  children: [
                    TextField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                        labelText: "Nama",
                        labelStyle: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.normal,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        labelText: user?.email ?? "Email tidak ditemukan.",
                        labelStyle: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.normal,
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        enabled: false,
                      ),
                      // controller: TextEditingController(text: user?.email ?? "Email tidak ditemukan"),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Pilih negara",
                        labelStyle: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.normal,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'Indonesia',
                          child: Row(
                            children: [
                              Image.asset('assets/icons/indonesia.png'),
                              SizedBox(width: 10),
                              Text("Indonesia"),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Malaysia',
                          child: Row(
                            children: [
                              Image.asset('assets/icons/Malaysia.png'),
                              SizedBox(width: 10),
                              Text("Malaysia"),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Singapura',
                          child: Row(
                            children: [
                              Image.asset('assets/icons/Singapore.png'),
                              SizedBox(width: 10),
                              Text("Singapura"),
                            ],
                          ),
                        ),
                      ],
                      onChanged: negaraChanged,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        prefixText: _getNomorNegara(_selectedNegara),
                        labelText: "Telepon ",
                        labelStyle: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.normal,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      controller: _nomorController,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _editHandle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Simpan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _editHandle() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pengguna tidak ditemukan"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Upload image if selected
      if (imageFile != null) {
        uploadImageURL = await _uploadToCloudinary(imageFile!);
        // Update user profile photo in Firebase Auth
        if (uploadImageURL != null) {
          await user.updatePhotoURL(uploadImageURL);
        }
      }

      // Update Firestore data
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'nama': _namaController.text.trim(),
        'email': user.email,
        'negara': _selectedNegara,
        'nomor':
            _getNomorNegara(_selectedNegara) + _nomorController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (uploadImageURL != null) 'photoURL': uploadImageURL,
      }, SetOptions(merge: true));

      // Close loading dialog and show success message
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        Navigator.pop(context); // Return to previous screen

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil berhasil diperbarui"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog and show error
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menyimpan data: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getNomorNegara(String? negara) {
    if (negara == "Indonesia") {
      return "+62 | ";
    }
    if (negara == "Malaysia") {
      return "+60 | ";
    }
    if (negara == "Singapura") {
      return "+65 | ";
    }

    return "";
  }
}
