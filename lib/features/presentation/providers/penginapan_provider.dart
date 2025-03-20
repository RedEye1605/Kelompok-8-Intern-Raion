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
    dynamic fotoFile,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
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
        CreatePenginapanParams(penginapan: penginapan, fotoFile: fotoFile),
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
  Future<PenginapanEntity?> updatePenginapan({
    required String id,
    required Map<String, dynamic> formData,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get existing penginapan first to preserve data not in the form
      final existingPenginapan = _selectedPenginapan;
      if (existingPenginapan == null) {
        throw Exception('No penginapan selected for update');
      }

      // Proses data kategori kamar
      final Map<String, KategoriKamarEntity> kategoriKamarMap = {};
      (formData['kategoriKamar'] as Map<String, dynamic>).forEach((key, value) {
        kategoriKamarMap[key] = KategoriKamarEntity(
          nama: key,
          deskripsi: value['deskripsi'],
          fasilitas: List<String>.from(value['fasilitas']),
          harga: value['harga'],
          jumlah: value['jumlah'],
          fotoKamar: [], // Preserve existing or empty if new
        );
      });

      // Update entity dengan data dari form
      final updatedPenginapan = PenginapanEntity(
        id: existingPenginapan.id,
        namaRumah: formData['namaRumah'] ?? existingPenginapan.namaRumah,
        alamatJalan: formData['alamatJalan'] ?? existingPenginapan.alamatJalan,
        kecamatan: formData['kecamatan'] ?? existingPenginapan.kecamatan,
        kelurahan: formData['kelurahan'] ?? existingPenginapan.kelurahan,
        kodePos: formData['kodePos'] ?? existingPenginapan.kodePos,
        linkMaps: formData['linkMaps'] ?? existingPenginapan.linkMaps,
        kategoriKamar: kategoriKamarMap,
        fotoPenginapan:
            existingPenginapan.fotoPenginapan, // Preserve existing photos
        userID: existingPenginapan.userID,
        createdAt: existingPenginapan.createdAt,
        updatedAt: DateTime.now(),
      );

      // Update via use case
      final result = await _updatePenginapanUseCase(
        UpdatePenginapanParams(id: id, penginapan: updatedPenginapan),
      );

      // Update selected penginapan if successful
      _selectedPenginapan = result;

      // Refresh lists that might contain this penginapan
      await loadUserPenginapan(existingPenginapan.userID);

      _isLoading = false;
      notifyListeners();

      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memperbarui data: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  // 5. Delete penginapan
  Future<bool> deletePenginapan(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _deletePenginapanUseCase(id);

      // Remove from lists
      _penginapanList.removeWhere((penginapan) => penginapan.id == id);
      _userPenginapanList.removeWhere((penginapan) => penginapan.id == id);

      // Clear selected penginapan if it was deleted
      if (_selectedPenginapan?.id == id) {
        _selectedPenginapan = null;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal menghapus penginapan: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // 6. Get penginapan by user
  Future<void> loadUserPenginapan(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userPenginapanList = await _getPenginapanByUserUseCase(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
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
