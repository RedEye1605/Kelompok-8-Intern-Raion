class PenginapanEntity {
  final String? id;
  final String namaRumah;
  final String alamatJalan;
  final String kecamatan;
  final String kelurahan;
  final String kodePos;
  final String linkMaps;
  final Map<String, KategoriKamarEntity> kategoriKamar;
  final List<String> fotoPenginapan;
  final String userID;
  final DateTime createdAt;
  final DateTime updatedAt;

  PenginapanEntity({
    this.id,
    required this.namaRumah,
    required this.alamatJalan,
    required this.kecamatan,
    required this.kelurahan,
    required this.kodePos,
    required this.linkMaps,
    required this.kategoriKamar,
    required this.fotoPenginapan,
    required this.userID,
    required this.createdAt,
    required this.updatedAt,
  });
}

class KategoriKamarEntity {
  final String nama;
  final String deskripsi;
  final List<String> fasilitas;
  final String harga;
  final String jumlah;
  final List<String> fotoKamar;

  KategoriKamarEntity({
    required this.nama,
    required this.deskripsi,
    required this.fasilitas,
    required this.harga,
    required this.jumlah,
    required this.fotoKamar,
  });
}
