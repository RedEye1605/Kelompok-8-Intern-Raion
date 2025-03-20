import 'package:my_flutter_app/core/usecases/usecases.dart';
import 'package:my_flutter_app/features/domain/entities/penginapan.dart';
import 'package:my_flutter_app/features/domain/repositories/penginapan_repository.dart';

class GetPenginapanByUser implements UseCase<List<PenginapanEntity>, String> {
  final PenginapanRepository repository;

  GetPenginapanByUser(this.repository);

  @override
  Future<List<PenginapanEntity>> call(String userId) {
    if (userId.isEmpty) {
      throw Exception('User ID cannot be empty');
    }
    return repository.getPenginapanByUser(userId);
  }
}
