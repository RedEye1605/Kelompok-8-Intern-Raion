import 'package:my_flutter_app/features/domain/entities/penginapan.dart';
import 'package:my_flutter_app/features/domain/repositories/penginapan_repository.dart';

class GetPenginapanDetailsUseCase {
  final PenginapanRepository repository;
  
  GetPenginapanDetailsUseCase(this.repository);
  
  Future<PenginapanEntity> execute(String id) async {
    if (id.isEmpty) {
      throw Exception('ID cannot be empty');
    }
    return repository.getPenginapanDetails(id);
  }
}
