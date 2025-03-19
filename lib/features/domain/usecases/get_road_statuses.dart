import 'package:my_flutter_app/features/domain/entities/road_status.dart';
import 'package:my_flutter_app/features/domain/repositories/road_status_repository.dart';
import 'package:my_flutter_app/core/usecases/usecases.dart';

class GetRoadStatuses implements UseCase<List<RoadStatusEntity>, NoParams> {
  final RoadStatusRepository repository;

  GetRoadStatuses(this.repository);

  @override
  Future<List<RoadStatusEntity>> call(NoParams params) async {
    return await repository.getRoadStatuses();
  }
}
