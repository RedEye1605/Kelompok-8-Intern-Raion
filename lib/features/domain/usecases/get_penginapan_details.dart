import 'package:my_flutter_app/core/usecases/usecases.dart';
import 'package:my_flutter_app/features/domain/entities/penginapan.dart';
import 'package:my_flutter_app/features/domain/repositories/penginapan_repository.dart';

class GetPenginapanDetails implements UseCase<PenginapanEntity, String> {
  final PenginapanRepository repository;

  GetPenginapanDetails(this.repository);

  @override
  Future<PenginapanEntity> call(String id) {
    if (id.isEmpty) {
      throw Exception('ID cannot be empty');
    }
    return repository.getPenginapanDetails(id);
  }
}
