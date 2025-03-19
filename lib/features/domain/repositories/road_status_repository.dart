import 'dart:io';
import 'package:my_flutter_app/features/domain/entities/road_status.dart';

abstract class RoadStatusRepository {
  Future<List<RoadStatusEntity>> getRoadStatuses();
  Future<RoadStatusEntity> createRoadStatus(RoadStatusEntity roadStatus);
  Future<RoadStatusEntity> updateRoadStatus(
    String roadStatusId,
    RoadStatusEntity roadStatus,
  );
  Future<void> deleteRoadStatus(String roadStatusId);
  Future<void> uploadRoadStatus(RoadStatusEntity roadStatus, File imageFile);
}
