import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_flutter_app/features/domain/entities/penginapan.dart';

class PenginapanModel extends PenginapanEntity {
  PenginapanModel({
    String? id,
    required String namaRumah,
    required String alamatJalan,
    required String kecamatan,
    required String kelurahan,
    required String kodePos,
    required String linkMaps,
    required Map<String, KategoriKamarModel> kategoriKamar,
    required List<String> fotoPenginapan,
    required String userID,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
         id: id,
         namaRumah: namaRumah,
         alamatJalan: alamatJalan,
         kecamatan: kecamatan,
         kelurahan: kelurahan,
         kodePos: kodePos,
         linkMaps: linkMaps,
         kategoriKamar: kategoriKamar,
         fotoPenginapan: fotoPenginapan,
         userID: userID,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  factory PenginapanModel.fromJson(Map<String, dynamic> json) {
    Map<String, KategoriKamarModel> kategoriKamar = {};

    if (json['kategoriKamar'] != null) {
      (json['kategoriKamar'] as Map<String, dynamic>).forEach((key, value) {
        kategoriKamar[key] = KategoriKamarModel.fromJson(value);
      });
    }

    return PenginapanModel(
      id: json['id'],
      namaRumah: json['namaRumah'] ?? '',
      alamatJalan: json['alamatJalan'] ?? '',
      kecamatan: json['kecamatan'] ?? '',
      kelurahan: json['kelurahan'] ?? '',
      kodePos: json['kodePos'] ?? '',
      linkMaps: json['linkMaps'] ?? '',
      kategoriKamar: kategoriKamar,
      fotoPenginapan: List<String>.from(json['fotoPenginapan'] ?? []),
      userID: json['userID'] ?? '',
      createdAt:
          json['createdAt'] != null
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? (json['updatedAt'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> kategoriKamarMap = {};
    kategoriKamar.forEach((key, value) {
      if (value is KategoriKamarModel) {
        kategoriKamarMap[key] = value.toJson();
      }
    });

    return {
      'namaRumah': namaRumah,
      'alamatJalan': alamatJalan,
      'kecamatan': kecamatan,
      'kelurahan': kelurahan,
      'kodePos': kodePos,
      'linkMaps': linkMaps,
      'kategoriKamar': kategoriKamarMap,
      'fotoPenginapan': fotoPenginapan,
      'userID': userID,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class KategoriKamarModel extends KategoriKamarEntity {
  KategoriKamarModel({
    required String nama,
    required String deskripsi,
    required List<String> fasilitas,
    required String harga,
    required String jumlah,
    required List<String> fotoKamar,
  }) : super(
         nama: nama,
         deskripsi: deskripsi,
         fasilitas: fasilitas,
         harga: harga,
         jumlah: jumlah,
         fotoKamar: fotoKamar,
       );

  factory KategoriKamarModel.fromJson(Map<String, dynamic> json) {
    // Handle fasilitas, which might be a string or a list
    List<String> fasilitas;
    if (json['fasilitas'] is String) {
      // If it's a string, convert to a single-item list
      fasilitas = [json['fasilitas']];
    } else if (json['fasilitas'] is List) {
      // If it's already a list, ensure it's List<String>
      fasilitas = List<String>.from(json['fasilitas'] ?? []);
    } else {
      // Default to empty list if null or other type
      fasilitas = [];
    }

    return KategoriKamarModel(
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      fasilitas: fasilitas, // Use our safely converted list
      harga: json['harga'] ?? '',
      jumlah: json['jumlah'] ?? '',
      fotoKamar: List<String>.from(json['fotoKamar'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'deskripsi': deskripsi,
      'fasilitas': fasilitas,
      'harga': harga,
      'jumlah': jumlah,
      'fotoKamar': fotoKamar,
    };
  }
}
