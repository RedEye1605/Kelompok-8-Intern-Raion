import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_flutter_app/core/usecases/usecases.dart';
import 'package:my_flutter_app/features/data/datasources/cloudinary_service.dart';
import 'package:my_flutter_app/features/domain/entities/road_status.dart';
import 'package:my_flutter_app/features/domain/usecases/create_road_status.dart';
import 'package:my_flutter_app/features/domain/usecases/get_road_statuses.dart';
import 'package:my_flutter_app/features/domain/usecases/delete_road_status.dart';
import 'package:my_flutter_app/features/domain/usecases/update_road_status.dart';
import 'package:my_flutter_app/features/domain/usecases/upload_road_status.dart';

class RoadStatusProvider with ChangeNotifier {
  final CreateRoadStatus createRoadStatus;
  final GetRoadStatuses getRoadStatuses;
  final DeleteRoadStatus deleteRoadStatus;
  final UpdateRoadStatus updateRoadStatus;
  final UploadRoadStatus uploadRoadStatus;
  final CloudinaryService cloudinaryService;

  RoadStatusProvider({
    required this.createRoadStatus,
    required this.getRoadStatuses,
    required this.deleteRoadStatus,
    required this.updateRoadStatus,
    required this.uploadRoadStatus,
    required this.cloudinaryService,
  });

  List<RoadStatusEntity> _roadStatuses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<RoadStatusEntity> get roadStatuses => _roadStatuses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadRoadStatuses() async {
    _isLoading = true;
    try {
      _roadStatuses = await getRoadStatuses(NoParams());
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  Future<void> addRoadStatus(RoadStatusEntity roadStatus) async {
    _isLoading = true;
    try {
      final newRoadStatus = await createRoadStatus(roadStatus);
      _roadStatuses.add(newRoadStatus);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
    }
  }

  Future<void> addRoadStatusWithImage(
    RoadStatusEntity roadStatus,
    File imageFile,
  ) async {
    try {
      await uploadRoadStatus(roadStatus, imageFile);
      notifyListeners();
    } catch (e) {
      print("Error adding road status: $e");
      throw Exception("Failed to add road status");
    }
  }

  Future<void> addRoadStatusWithImages(
    RoadStatusEntity roadStatus,
    List<File> imageFiles,
  ) async {
    _isLoading = true;
    try {
      print("Provider: Memulai proses upload gambar...");

      // Upload gambar ke Cloudinary
      List<String> imageUrls = [];
      for (var imageFile in imageFiles) {
        print("Provider: Uploading file: ${imageFile.path}");
        final imageUrl = await cloudinaryService.uploadImage(imageFile);
        if (imageUrl != null) {
          imageUrls.add(imageUrl);
          print("Provider: Uploaded image URL: $imageUrl");
        } else {
          print("Provider: Failed to upload image, skipping...");
        }
      }

      // Buat road status baru dengan URL gambar
      final roadStatusToSave = RoadStatusEntity(
        id: roadStatus.id,
        userId: roadStatus.userId,
        description: roadStatus.description,
        linkMaps: roadStatus.linkMaps,
        images: imageUrls,
        createdAt: roadStatus.createdAt,
      );

      print(
        "Provider: Menyimpan data ke Firestore - ID: ${roadStatusToSave.id}, " +
            "Images: ${roadStatusToSave.images.join(', ')}, " +
            "Description: ${roadStatusToSave.description}",
      );

      // Simpan ke Firestore dan gunakan nilai yang dikembalikan
      final savedRoadStatus = await createRoadStatus(roadStatusToSave);
      _roadStatuses.add(savedRoadStatus); // Gunakan nilai yang dikembalikan
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      print("Provider: Error in addRoadStatusWithImages: $_errorMessage");
      throw Exception("Failed to upload images and save road status: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateExistingRoadStatus(RoadStatusEntity roadStatus) async {
    _isLoading = true;
    try {
      final updatedRoadStatus = await updateRoadStatus(roadStatus);
      final index = _roadStatuses.indexWhere(
        (r) => r.id == updatedRoadStatus.id,
      );
      if (index != -1) {
        _roadStatuses[index] = updatedRoadStatus;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
    }
  }

  Future<void> removeRoadStatus(String roadStatusId) async {
    _isLoading = true;
    try {
      await deleteRoadStatus(roadStatusId);
      _roadStatuses.removeWhere((roadStatus) => roadStatus.id == roadStatusId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
    }
  }
}
