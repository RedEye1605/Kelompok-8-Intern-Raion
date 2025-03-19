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

  // Future<void> _pickAndUploadProfilePhoto() async {
  //   final html.FileUploadInputElement uploadInput =
  //       html.FileUploadInputElement();
  //   uploadInput.accept = 'image/*';
  //   uploadInput.click();

  //   uploadInput.onChange.listen((event) async {
  //     final files = uploadInput.files;
  //     if (files!.isEmpty) return;

  //     final html.File file = files.first;
  //     final imageUrl = await _uploadToCloudinary(file);

  //     setState(() {
  //       uploadImageURL = imageUrl;
  //     });
  //   });
  // }

  // Future<String?> _uploadToCloudinary(html.File imageFile) async {
  //   final reader = html.FileReader();
  //   reader.readAsArrayBuffer(imageFile);

  //   await reader.onLoadEnd.first;
  //   final Uint8List bytes = reader.result as Uint8List;

  //   final url = Uri.parse(
  //     'https://api.cloudinary.com/v1_1/dak6uyba7/image/upload',
  //   );

  //   var request =
  //       http.MultipartRequest('POST', url)
  //         ..fields['upload_preset'] = 'testing'
  //         ..files.add(
  //           http.MultipartFile.fromBytes(
  //             'file',
  //             bytes,
  //             filename: imageFile.name,
  //           ),
  //         );

  //   var response = await request.send();

  //   if (response.statusCode == 200) {
  //     final responseData = await response.stream.bytesToString();
  //     final jsonData = json.decode(responseData);
  //     return jsonData['secure_url']; // URL gambar yang telah diunggah
  //   } else {
  //     return null;
  //   }
  // }

  // mobile picker
  Future<void> _pickAndUploadProfilePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (image != null) imageFile = File(image.path);
      });
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
  Widget build(BuildContext context) {
    @override
    void initState() {
      super.initState();
      _negaraController.text = _selectedNegara!;
    }

    void _negaraChanged(String? newValue) {
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 100),
                Stack(
                  alignment: AlignmentDirectional(1.35, 1.35),
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          imageFile != null
                              ? FileImage(imageFile!)
                              : (user?.photoURL != null
                                      ? NetworkImage(user!.photoURL!)
                                      : AssetImage(
                                        'assets/icons/profile-icon.png',
                                      ))
                                  as ImageProvider,
                      backgroundColor: Colors.grey,
                      radius: 50,
                    ),
                    IconButton(
                      onPressed: _pickAndUploadProfilePhoto,
                      icon: Image.asset(
                        "assets/icons/edit_photo.png",
                        width: 34,
                        height: 34,
                      ),
                    ),
                  ],
                ),
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
                SizedBox(height: 100),
                ElevatedButton(onPressed: _editHandle, child: Text("Simpan")),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Pengguna tidak ditemukan")));
      return;
    }

    try {
      if (imageFile != null) {
        uploadImageURL = await _uploadToCloudinary(imageFile!);
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'nama': _namaController.text,
        'email': user.email,
        'negara': _selectedNegara,
        'nomor': _nomorController.text,
        if (uploadImageURL != null) 'userPhoto': uploadImageURL,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Profil berhasil diperbarui")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menyimpan data: $e")));
    }
    Navigator.pop(context);
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
