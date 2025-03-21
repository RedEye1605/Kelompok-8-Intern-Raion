import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/domain/entities/penginapan.dart';
import 'package:my_flutter_app/features/domain/usecases/create_penginapan.dart';
import 'package:my_flutter_app/features/domain/usecases/get_all_penginapan.dart';
import 'package:my_flutter_app/features/domain/usecases/get_penginapan_details.dart';
import 'package:my_flutter_app/features/domain/usecases/update_penginapan.dart';
import 'package:my_flutter_app/features/domain/usecases/delete_penginapan.dart';
import 'package:my_flutter_app/features/domain/usecases/get_penginapan_by_user.dart';
import 'package:my_flutter_app/core/usecases/usecases.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PenginapanProvider with ChangeNotifier {
  // Use cases
  final CreatePenginapan _createPenginapanUseCase;
  final GetAllPenginapan _getAllPenginapanUseCase;
  final GetPenginapanDetails _getPenginapanDetailsUseCase;
  final UpdatePenginapan _updatePenginapanUseCase;
  final DeletePenginapan _deletePenginapanUseCase;
  final GetPenginapanByUser _getPenginapanByUserUseCase;

  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  List<PenginapanEntity> _penginapanList = [];
  PenginapanEntity? _selectedPenginapan;
  List<PenginapanEntity> _userPenginapanList = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<PenginapanEntity> get penginapanList => _penginapanList;
  PenginapanEntity? get selectedPenginapan => _selectedPenginapan;
  List<PenginapanEntity> get userPenginapanList => _userPenginapanList;

  // Constructor
  PenginapanProvider({
    required CreatePenginapan createPenginapanUseCase,
    required GetAllPenginapan getAllPenginapanUseCase,
    required GetPenginapanDetails getPenginapanDetailsUseCase,
    required UpdatePenginapan updatePenginapanUseCase,
    required DeletePenginapan deletePenginapanUseCase,
    required GetPenginapanByUser getPenginapanByUserUseCase,
  }) : _createPenginapanUseCase = createPenginapanUseCase,
       _getAllPenginapanUseCase = getAllPenginapanUseCase,
       _getPenginapanDetailsUseCase = getPenginapanDetailsUseCase,
       _updatePenginapanUseCase = updatePenginapanUseCase,
       _deletePenginapanUseCase = deletePenginapanUseCase,
       _getPenginapanByUserUseCase = getPenginapanByUserUseCase;

  // 1. Load all penginapan
  Future<void> loadPenginapan() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _penginapanList = await _getAllPenginapanUseCase(const NoParams());
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memuat data penginapan: ${e.toString()}';
      notifyListeners();
    }
  }

  // 2. Get penginapan details
  Future<void> getPenginapanDetails(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedPenginapan = await _getPenginapanDetailsUseCase(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memuat detail penginapan: ${e.toString()}';
      notifyListeners();
    }
  }

  // 3. Create penginapan
  Future<PenginapanEntity?> createPenginapan(
    Map<String, dynamic> formData,
    dynamic fotoFiles, // Bisa File tunggal atau List<File>
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Konversi ke List<File> jika itu file tunggal
      List<File> files = [];
      if (fotoFiles is File) {
        files.add(fotoFiles);
        print("📸 Menerima 1 file tunggal");
      } else if (fotoFiles is List) {
        for (var file in fotoFiles) {
          if (file is File) {
            files.add(file);
          }
        }
        print("📸 Menerima ${files.length} files");
      } else {
        print("⚠️ Format fotoFiles tidak didukung: ${fotoFiles?.runtimeType}");
      }

      // Convert form data ke entitas
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final now = DateTime.now();

      // Proses data kategori kamar
      final Map<String, KategoriKamarEntity> kategoriKamarMap = {};

      if (formData['kategoriKamar'] != null) {
        (formData['kategoriKamar'] as Map<String, dynamic>).forEach((
          key,
          value,
        ) {
          // Properly handle fasilitas regardless of type
          List<String> fasilitas;
          if (value['fasilitas'] is String) {
            // If it's a string, convert to a single-item list
            fasilitas = [value['fasilitas']];
          } else if (value['fasilitas'] is List) {
            // If it's already a list, ensure it's List<String>
            fasilitas = List<String>.from(value['fasilitas']);
          } else {
            // Default to empty list if null or other type
            fasilitas = [];
          }

          kategoriKamarMap[key] = KategoriKamarEntity(
            nama: key,
            deskripsi: value['deskripsi'] ?? '',
            fasilitas: fasilitas,
            harga: value['harga'] ?? '0',
            jumlah: value['jumlah'] ?? '0',
            fotoKamar: [], // Will be filled later if needed
          );
        });
      }

      // Create penginapan entity
      final penginapan = PenginapanEntity(
        namaRumah: formData['namaRumah'],
        alamatJalan: formData['alamatJalan'],
        kecamatan: formData['kecamatan'],
        kelurahan: formData['kelurahan'],
        kodePos: formData['kodePos'],
        linkMaps: formData['linkMaps'],
        kategoriKamar: kategoriKamarMap,
        fotoPenginapan: [], // Will be filled by Cloudinary service
        userID: userId,
        createdAt: now,
        updatedAt: now,
      );

      // Save to database via use case
      final result = await _createPenginapanUseCase(
        CreatePenginapanParams(penginapan: penginapan, fotoFiles: files),
      );

      // Refresh user's penginapan list if successful
      if (result != null) {
        await loadUserPenginapan(userId);
      }

      _isLoading = false;
      notifyListeners();

      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal menyimpan data: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  // 4. Update penginapan
  Future<void> updatePenginapan({
    required String id,
    required Map<String, dynamic> formData,
    required List<File> images,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Get existing image URLs to keep
      List<String> existingImageUrls = [];
      if (formData['existingImageUrls'] != null) {
        existingImageUrls = List<String>.from(formData['existingImageUrls']);
      }

      // Process category room data
      final Map<String, KategoriKamarEntity> kategoriKamarMap = {};
      if (formData['kategoriKamar'] != null) {
        (formData['kategoriKamar'] as Map<String, dynamic>).forEach((
          key,
          value,
        ) {
          // Handle fasilitas as before
          List<String> fasilitas;
          if (value['fasilitas'] is String) {
            fasilitas = [value['fasilitas']];
          } else if (value['fasilitas'] is List) {
            fasilitas = List<String>.from(value['fasilitas']);
          } else {
            fasilitas = [];
          }

          kategoriKamarMap[key] = KategoriKamarEntity(
            nama: key,
            deskripsi: value['deskripsi'] ?? '',
            fasilitas: fasilitas,
            harga: value['harga'] ?? '0',
            jumlah: value['jumlah'] ?? '0',
            fotoKamar: [], // To be implemented later
          );
        });
      }

      // Create updated penginapan entity
      final penginapan = PenginapanEntity(
        id: id,
        namaRumah: formData['namaRumah'],
        alamatJalan: formData['alamatJalan'],
        kecamatan: formData['kecamatan'],
        kelurahan: formData['kelurahan'],
        kodePos: formData['kodePos'],
        linkMaps: formData['linkMaps'],
        kategoriKamar: kategoriKamarMap,
        fotoPenginapan: existingImageUrls,
        userID: FirebaseAuth.instance.currentUser?.uid ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Use the UpdatePenginapan use case
      await _updatePenginapanUseCase(
        UpdatePenginapanParams(id: id, penginapan: penginapan),
      );

      // Reload data
      await loadPenginapan();
      await loadCurrentUserPenginapan();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print("Error updating penginapan: $_errorMessage");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 5. Delete penginapan
  Future<void> deletePenginapan(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Ensure the ID is valid
      if (id.isEmpty) {
        throw Exception('Invalid penginapan ID');
      }

      // Use the DeletePenginapan use case
      await _deletePenginapanUseCase(id);

      // Remove from local lists
      _userPenginapanList.removeWhere((penginapan) => penginapan.id == id);
      _penginapanList.removeWhere((penginapan) => penginapan.id == id);

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print("Error deleting penginapan: $_errorMessage");
      throw e; // Re-throw to handle in UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 6. Get penginapan by user
  Future<void> loadUserPenginapan(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Loading penginapan for user: $userId');
      _userPenginapanList = await _getPenginapanByUserUseCase(userId);
      print('Loaded ${_userPenginapanList.length} penginapan for user');

      // Add debug info for each item
      for (var penginapan in _userPenginapanList) {
        print('Penginapan: ${penginapan.namaRumah}, ID: ${penginapan.id}');
        print('UserID in penginapan: ${penginapan.userID}');
        print('Kategori count: ${penginapan.kategoriKamar.length}');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error in loadUserPenginapan: $e');
      _isLoading = false;
      _errorMessage = 'Gagal memuat penginapan pengguna: ${e.toString()}';
      notifyListeners();
    }
  }

  // Helper method to load current user's penginapan
  Future<void> loadCurrentUserPenginapan() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null && userId.isNotEmpty) {
      await loadUserPenginapan(userId);
    } else {
      _errorMessage = 'User tidak login';
      notifyListeners();
    }
  }

  // Reset state (useful when logging out)
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _penginapanList = [];
    _selectedPenginapan = null;
    _userPenginapanList = [];
    notifyListeners();
  }
}
