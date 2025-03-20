import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_flutter_app/features/data/models/penginapan_model.dart';
import 'cloudinary_service.dart';

abstract class FirebasePenginapanRemoteDataSource {
  Future<PenginapanModel> createPenginapan(
    PenginapanModel penginapanModel,
    dynamic imageFile,
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
    dynamic imageFile,
  ) async {
    try {
      String? imageUrl = await cloudinaryService.uploadImage(imageFile);

      // Safely convert model to JSON with type safety
      final penginapanData = _ensureCorrectDataTypes(penginapanModel.toJson());
      penginapanData['fotoPenginapan'] = imageUrl;

      final docRef = await firestore
          .collection('penginapan')
          .add(penginapanData);
      final docSnapshot = await docRef.get();
      final data = docSnapshot.data()!;
      data['id'] = docSnapshot.id;
      return PenginapanModel.fromJson(data);
    } catch (e) {
      print("Error during createPenginapan: $e");
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
      final querySnapshot =
          await firestore
              .collection('penginapan')
              .where('userID', isEqualTo: userId)
              .get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return PenginapanModel.fromJson(data);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}
