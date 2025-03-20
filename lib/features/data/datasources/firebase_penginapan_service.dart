import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_flutter_app/features/data/models/penginapan_model.dart';
import 'cloudinary_service.dart';

abstract class FirebasePenginapanRemoteDataSource {
  Future<PenginapanModel> createPenginapan(
    PenginapanModel penginapanModel,
    List<File> imageFiles, // Ubah dari dynamic ke List<File>
  );
  Future<PenginapanModel> updatePenginapan(
    String id,
    PenginapanModel penginapanModel,
  );
  Future<void> deletePenginapan(String id);
  Future<PenginapanModel> getPenginapanDetails(String id);
  Future<List<PenginapanModel>> getAllPenginapan();
  Future<List<PenginapanModel>> getPenginapanByUser(String userId);
}

class FirebasePenginapanRemoteDataSourceImpl
    implements FirebasePenginapanRemoteDataSource {
  final FirebaseFirestore firestore;
  final CloudinaryService cloudinaryService;

  FirebasePenginapanRemoteDataSourceImpl({
    required this.firestore,
    required this.cloudinaryService,
  });

  @override
  Future<PenginapanModel> createPenginapan(
    PenginapanModel penginapanModel,
    List<File> imageFiles, // Sekarang tipe sudah sesuai
  ) async {
    try {
      // Debug print awal
      print("⭐ Memulai createPenginapan");
      print("📸 Jumlah file untuk diupload: ${imageFiles.length}");

      // Upload semua gambar ke Cloudinary
      List<String> imageUrls = [];

      for (var imageFile in imageFiles) {
        try {
          print("📸 Mencoba upload file: ${imageFile.path}");
          String? imageUrl = await cloudinaryService.uploadImage(imageFile);
          if (imageUrl != null) {
            imageUrls.add(imageUrl);
            print("🌐 Image URL dari Cloudinary: $imageUrl");
          }
        } catch (e) {
          print("❌ Error saat upload ke Cloudinary: $e");
          // Lanjutkan ke file berikutnya
        }
      }

      // Safely convert model to JSON with type safety
      final penginapanData = _ensureCorrectDataTypes(penginapanModel.toJson());

      // PERBAIKAN: Pastikan fotoPenginapan selalu array dan tidak null
      if (imageUrls.isNotEmpty) {
        penginapanData['fotoPenginapan'] = imageUrls; // Simpan semua URL
        print("📸 Foto URLs disimpan: $imageUrls");
      } else {
        penginapanData['fotoPenginapan'] = [];
        print("⚠️ Tidak ada foto yang disimpan");
      }

      // Verifikasi data sebelum disimpan ke Firestore
      print("📋 Data yang akan disimpan ke Firestore:");
      print("   - namaRumah: ${penginapanData['namaRumah']}");
      print("   - fotoPenginapan: ${penginapanData['fotoPenginapan']}");
      print("   - userID: ${penginapanData['userID']}");

      // Simpan ke Firestore
      final docRef = await firestore
          .collection('penginapan')
          .add(penginapanData);
      print("✅ Data berhasil disimpan dengan ID: ${docRef.id}");

      // Ambil data yang tersimpan untuk verifikasi
      final docSnapshot = await docRef.get();
      final data = docSnapshot.data()!;
      data['id'] = docRef.id;

      // Verifikasi data tersimpan
      print("📄 Data tersimpan di Firestore:");
      print("   - fotoPenginapan: ${data['fotoPenginapan']}");

      return PenginapanModel.fromJson(data);
    } catch (e) {
      print("❌ ERROR during createPenginapan: $e");
      rethrow;
    }
  }

  // Add this helper method to your class
  Map<String, dynamic> _ensureCorrectDataTypes(Map<String, dynamic> data) {
    // Make sure kategoriKamar data has fasilitas as List<String>
    if (data.containsKey('kategoriKamar')) {
      final kategoriMap = data['kategoriKamar'] as Map<String, dynamic>;
      kategoriMap.forEach((key, value) {
        if (value is Map<String, dynamic> && value.containsKey('fasilitas')) {
          if (value['fasilitas'] is String) {
            value['fasilitas'] = [value['fasilitas']];
          } else if (!(value['fasilitas'] is List)) {
            value['fasilitas'] = [];
          }
        }
      });
    }
    return data;
  }

  @override
  Future<PenginapanModel> updatePenginapan(
    String id,
    PenginapanModel penginapanModel,
  ) async {
    try {
      await firestore
          .collection('penginapan')
          .doc(id)
          .update(penginapanModel.toJson());
      final updatedDoc = await firestore.collection('penginapan').doc(id).get();
      final data = updatedDoc.data()!;
      data['id'] = updatedDoc.id;
      return PenginapanModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deletePenginapan(String id) async {
    try {
      await firestore.collection('penginapan').doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PenginapanModel> getPenginapanDetails(String id) async {
    try {
      final docSnapshot =
          await firestore.collection('penginapan').doc(id).get();
      final data = docSnapshot.data()!;
      data['id'] = docSnapshot.id;
      return PenginapanModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PenginapanModel>> getAllPenginapan() async {
    try {
      final querySnapshot = await firestore.collection('penginapan').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return PenginapanModel.fromJson(data);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PenginapanModel>> getPenginapanByUser(String userId) async {
    try {
      print('Querying Firestore for userId: $userId');

      final querySnapshot =
          await firestore
              .collection('penginapan')
              .where('userID', isEqualTo: userId)
              .get();

      print('Query returned ${querySnapshot.docs.length} documents');

      final results = <PenginapanModel>[];

      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          final model = PenginapanModel.fromJson(data);
          results.add(model);
        } catch (e, stackTrace) {
          print('Error converting document ${doc.id}: $e');
          print('Document data: ${doc.data()}');
          print('Stack trace: $stackTrace');
          // Continue processing other documents
        }
      }

      return results;
    } catch (e) {
      print('Error in getPenginapanByUser: $e');
      rethrow;
    }
  }
}
