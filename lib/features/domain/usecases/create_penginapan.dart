import 'dart:io';

import 'package:my_flutter_app/core/usecases/usecases.dart';
import 'package:my_flutter_app/features/domain/entities/penginapan.dart';
import 'package:my_flutter_app/features/domain/repositories/penginapan_repository.dart';

class CreatePenginapan
    implements UseCase<PenginapanEntity, CreatePenginapanParams> {
  final PenginapanRepository repository;

  CreatePenginapan(this.repository);

  @override
  Future<PenginapanEntity> call(CreatePenginapanParams params) async {
    if (params.penginapan == null) {
      throw Exception('Penginapan cannot be null');
    }
    return repository.createPenginapan(params.penginapan, params.fotoFiles);
  }
}

class CreatePenginapanParams {
  final PenginapanEntity penginapan;
  final List<File> fotoFiles; // List files, bukan file tunggal

  const CreatePenginapanParams({
    required this.penginapan,
    required this.fotoFiles,
  });
}
