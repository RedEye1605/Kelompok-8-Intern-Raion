import 'package:my_flutter_app/core/usecases/usecases.dart';
import 'package:my_flutter_app/features/domain/repositories/penginapan_repository.dart';

class DeletePenginapan implements UseCase<void, String> {
  final PenginapanRepository repository;

  DeletePenginapan(this.repository);

  @override
  Future<void> call(String id) {
    if (id.isEmpty) {
      throw Exception('ID cannot be empty');
    }
    return repository.deletePenginapan(id);
  }
}
