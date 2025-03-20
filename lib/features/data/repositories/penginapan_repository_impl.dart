import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_flutter_app/features/data/datasources/cloudinary_service.dart';
import 'package:my_flutter_app/features/domain/entities/penginapan.dart';
import 'package:my_flutter_app/features/domain/repositories/penginapan_repository.dart';
import 'package:my_flutter_app/features/data/models/penginapan_model.dart';
import 'package:my_flutter_app/features/data/datasources/firebase_penginapan_service.dart';
import 'package:my_flutter_app/features/domain/entities/penginapan.dart';

class PenginapanRepositoryImpl implements PenginapanRepository {
  final FirebasePenginapanRemoteDataSource remoteDataSource;
  final CloudinaryService cloudinaryService;

  PenginapanRepositoryImpl({
    required this.remoteDataSource,
    required this.cloudinaryService,
  });

  @override
  Future<PenginapanEntity> createPenginapan(
    PenginapanEntity penginapan,
    dynamic fotoFile,
  ) async {
    final penginapanModel = _convertToModel(penginapan);
    final result = await remoteDataSource.createPenginapan(
      penginapanModel,
      fotoFile,
    );
    return result;
  }

  @override
  Future<void> deletePenginapan(String id) {
    return remoteDataSource.deletePenginapan(id);
  }

  @override
  Future<List<PenginapanEntity>> getAllPenginapan() async {
    // Implementasi untuk mendapatkan semua penginapan
    return await remoteDataSource.getAllPenginapan();
  }

  @override
  Future<PenginapanEntity> getPenginapanDetails(String id) {
    return remoteDataSource.getPenginapanDetails(id);
  }

  @override
  Future<List<PenginapanEntity>> getPenginapanByUser(String userId) async {
    // Implementasi untuk mendapatkan penginapan berdasarkan user ID
    return await remoteDataSource.getPenginapanByUser(userId);
  }

  @override
  Future<PenginapanEntity> updatePenginapan(
    String id,
    PenginapanEntity penginapan,
  ) {
    final penginapanModel = _convertToModel(penginapan);
    return remoteDataSource.updatePenginapan(id, penginapanModel);
  }

  PenginapanModel _convertToModel(PenginapanEntity entity) {
    // Konversi dari entity ke model
    if (entity is PenginapanModel) {
      return entity;
    }

    Map<String, KategoriKamarModel> kategoriKamarModels = {};
    entity.kategoriKamar.forEach((key, value) {
      kategoriKamarModels[key] = KategoriKamarModel(
        nama: value.nama,
        deskripsi: value.deskripsi,
        fasilitas: value.fasilitas,
        harga: value.harga,
        jumlah: value.jumlah,
        fotoKamar: value.fotoKamar,
      );
    });

    return PenginapanModel(
      id: entity.id,
      namaRumah: entity.namaRumah,
      alamatJalan: entity.alamatJalan,
      kecamatan: entity.kecamatan,
      kelurahan: entity.kelurahan,
      kodePos: entity.kodePos,
      linkMaps: entity.linkMaps,
      kategoriKamar: kategoriKamarModels,
      fotoPenginapan: entity.fotoPenginapan,
      userID: entity.userID,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
