import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_flutter_app/features/data/datasources/cloudinary_service.dart';
import 'package:my_flutter_app/features/domain/entities/road_status.dart';
import 'package:my_flutter_app/features/domain/repositories/road_status_repository.dart';
import 'package:my_flutter_app/features/data/models/road_status_model.dart';
import 'package:my_flutter_app/features/data/datasources/firebase_road_status_service.dart';

class RoadStatusRepositoryImpl implements RoadStatusRepository {
  final FirebaseRoadStatusRemoteDataSource remoteDataSource;
  final CloudinaryService cloudinaryService;

  RoadStatusRepositoryImpl({
    required this.remoteDataSource,
    required this.cloudinaryService,
  });

  @override
  Future<List<RoadStatusEntity>> getRoadStatuses() async {
    final roadStatuses = await remoteDataSource.getRoadStatuses();
    return roadStatuses;
  }

  @override
  Future<RoadStatusEntity> createRoadStatus(RoadStatusEntity roadStatus) async {
    final roadStatusModel = RoadStatusModel(
      id: roadStatus.id,
      userId: roadStatus.userId,
      description: roadStatus.description,
      linkMaps: roadStatus.linkMaps,
      images: roadStatus.images,
      createdAt: roadStatus.createdAt,
    );

    final result = await remoteDataSource.createRoadStatus(roadStatusModel);

    return result;
  }

  @override
  Future<RoadStatusEntity> updateRoadStatus(
    String roadStatusId,
    RoadStatusEntity roadStatus,
  ) async {
    final roadStatusModel = RoadStatusModel(
      id: roadStatus.id,
      userId: roadStatus.userId,
      description: roadStatus.description,
      linkMaps: roadStatus.linkMaps,
      images: roadStatus.images,
      createdAt: roadStatus.createdAt,
    );
    return await remoteDataSource.updateRoadStatus(
      roadStatusId,
      roadStatusModel,
    );
  }

  @override
  Future<void> deleteRoadStatus(String roadStatusId) async {
    await remoteDataSource.deleteRoadStatus(roadStatusId);
  }

  @override
  Future<void> uploadRoadStatus(
    RoadStatusEntity roadStatus,
    File imageFile,
  ) async {
    try {
      if (cloudinaryService == null) {
        throw Exception("CloudinaryService is null in repository!");
      }

      // Upload image ke Cloudinary
      final imageUrl = await cloudinaryService.uploadImage(imageFile);
      if (imageUrl == null) {
        throw Exception("Failed to upload image to Cloudinary");
      }

      // Buat model baru dengan URL gambar hasil upload
      final roadStatusModel = RoadStatusModel(
        id: roadStatus.id,
        userId: roadStatus.userId,
        description: roadStatus.description,
        linkMaps: roadStatus.linkMaps,
        images: [imageUrl], // Simpan URL gambar ke dalam list
        createdAt: roadStatus.createdAt,
      );

      // Simpan data ke Firestore melalui remote data source
      await remoteDataSource.createRoadStatus(roadStatusModel);
    } catch (e) {
      print("Error uploading road status: $e");
      throw Exception("Failed to upload road status: $e");
    }
  }
}
