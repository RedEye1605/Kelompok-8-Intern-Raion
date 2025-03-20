import 'package:my_flutter_app/features/domain/repositories/road_status_repository.dart';
import 'package:my_flutter_app/core/usecases/usecases.dart';

class DeleteRoadStatus implements UseCase<void, String> {
  final RoadStatusRepository repository;

  DeleteRoadStatus(this.repository);

  @override
  Future<void> call(String postId) async {
    await repository.deleteRoadStatus(postId);
  }
}
