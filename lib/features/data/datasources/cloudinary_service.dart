import 'dart:convert';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class CloudinaryService {
  final cloudinary = CloudinaryPublic(
    'dak6uyba7', // Cloud name
    'testing', // Upload preset
  );

  Future<String?> uploadImage(dynamic imageFile) async {
    try {
      print("📸 Memulai upload image dengan tipe: ${imageFile.runtimeType}");

      if (imageFile is File) {
        return await _uploadMobileImage(imageFile);
      } else if (imageFile is String) {
        // Handle base64 atau URL string jika perlu
        print("⚠️ imageFile adalah String, bukan File");
        return null;
      } else {
        print("⚠️ Format file tidak didukung: ${imageFile.runtimeType}");
        return null;
      }
    } catch (e) {
      print("❌ Error dalam uploadImage: $e");
      return null;
    }
  }

  Future<String?> _uploadMobileImage(File imageFile) async {
    try {
      print("📸 Uploading image dari path: ${imageFile.path}");

      // Verifikasi file ada dan bisa diakses
      if (!await imageFile.exists()) {
        print("❌ File tidak ditemukan: ${imageFile.path}");
        return null;
      }

      // Upload ke Cloudinary
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      print("✅ Upload berhasil! URL: ${response.secureUrl}");
      return response.secureUrl;
    } catch (e) {
      print("❌ Error _uploadMobileImage: $e");
      return null;
    }
  }

  Future<String?> _uploadWebImage(dynamic imageFile) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/dak6uyba7/image/upload',
      );

      final request =
          http.MultipartRequest('POST', url)
            ..fields['upload_preset'] = 'ml_default'
            ..files.add(
              http.MultipartFile(
                'file',
                imageFile.readAsBytes().asStream(),
                imageFile.size,
                filename: 'image.jpg',
              ),
            );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseData);
        return jsonResponse['secure_url'];
      }
      return null;
    } catch (e) {
      print("Web Upload Error: $e");
      return null;
    }
  }
}
