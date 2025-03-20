import 'package:my_flutter_app/core/usecases/usecases.dart';
import 'package:my_flutter_app/features/domain/entities/penginapan.dart';
import 'package:my_flutter_app/features/domain/repositories/penginapan_repository.dart';

class GetAllPenginapan implements UseCase<List<PenginapanEntity>, NoParams> {
  final PenginapanRepository repository;

  GetAllPenginapan(this.repository);

  @override
  Future<List<PenginapanEntity>> call(NoParams params) {
    return repository.getAllPenginapan();
  }
}
