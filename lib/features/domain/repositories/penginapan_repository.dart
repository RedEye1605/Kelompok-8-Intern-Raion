import 'dart:io';
import 'package:my_flutter_app/features/domain/entities/penginapan.dart';

abstract class PenginapanRepository {
  Future<List<PenginapanEntity>> getAllPenginapan();
  Future<PenginapanEntity> createPenginapan(
    PenginapanEntity penginapan,
    List<File> fotoFiles, // Ubah dari dynamic ke List<File>
  );
  Future<PenginapanEntity> updatePenginapan(
    String id,
    PenginapanEntity penginapan,
  );
  Future<void> deletePenginapan(String id);
  Future<PenginapanEntity> getPenginapanDetails(String id);
  Future<List<PenginapanEntity>> getPenginapanByUser(String userId);
}
