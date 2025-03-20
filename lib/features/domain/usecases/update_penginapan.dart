import 'package:my_flutter_app/core/usecases/usecases.dart';
import 'package:my_flutter_app/features/domain/entities/penginapan.dart';
import 'package:my_flutter_app/features/domain/repositories/penginapan_repository.dart';

class UpdatePenginapan
    implements UseCase<PenginapanEntity, UpdatePenginapanParams> {
  final PenginapanRepository repository;

  UpdatePenginapan(this.repository);

  @override
  Future<PenginapanEntity> call(UpdatePenginapanParams params) {
    if (params.id.isEmpty) {
      throw Exception('ID cannot be empty');
    }
    if (params.penginapan == null) {
      throw Exception('Penginapan cannot be null');
    }
    return repository.updatePenginapan(params.id, params.penginapan);
  }
}

class UpdatePenginapanParams {
  final String id;
  final PenginapanEntity penginapan;

  const UpdatePenginapanParams({required this.id, required this.penginapan});
}
