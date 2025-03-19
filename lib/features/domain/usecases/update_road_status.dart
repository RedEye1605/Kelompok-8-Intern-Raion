import 'package:my_flutter_app/features/domain/entities/road_status.dart';
import 'package:my_flutter_app/features/domain/repositories/road_status_repository.dart';
import 'package:my_flutter_app/core/usecases/usecases.dart';

class UpdateRoadStatus implements UseCase<RoadStatusEntity, RoadStatusEntity> {
  final RoadStatusRepository repository;

  UpdateRoadStatus(this.repository);

  @override
  Future<RoadStatusEntity> call(RoadStatusEntity roadStatus) async {
    return await repository.updateRoadStatus(roadStatus.id, roadStatus);
  }
}
