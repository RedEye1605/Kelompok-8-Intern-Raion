import 'package:my_flutter_app/features/domain/entities/road_status.dart';
import 'package:my_flutter_app/features/domain/repositories/road_status_repository.dart';
import 'package:my_flutter_app/core/usecases/usecases.dart';

class CreateRoadStatus implements UseCase<RoadStatusEntity, RoadStatusEntity> {
  final RoadStatusRepository repository;

  CreateRoadStatus(this.repository);

  @override
  Future<RoadStatusEntity> call(RoadStatusEntity roadStatus) async {
    return await repository.createRoadStatus(roadStatus);
  }
}
