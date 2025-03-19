import 'dart:io';
import 'package:my_flutter_app/features/domain/entities/road_status.dart';
import 'package:my_flutter_app/features/domain/repositories/road_status_repository.dart';

class UploadRoadStatus {
  final RoadStatusRepository repository;

  UploadRoadStatus(this.repository);

  Future<void> call(RoadStatusEntity roadStatus, File imageFile) async {
    return await repository.uploadRoadStatus(roadStatus, imageFile);
  }
}
