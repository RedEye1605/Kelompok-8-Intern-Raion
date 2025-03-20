import 'package:my_flutter_app/features/domain/entities/road_status.dart';

class RoadStatusModel extends RoadStatusEntity {
  RoadStatusModel({
    required String id,
    required String userId,
    required String description,
    required String linkMaps,
    required List<String> images,
    required DateTime createdAt,
  }) : super(
          id: id,
          userId: userId,
          description: description,
          linkMaps: linkMaps,
          images: images,
          createdAt: createdAt,
        );

  factory RoadStatusModel.fromJson(Map<String, dynamic> json) {
    return RoadStatusModel(
      id: json['id'],
      userId: json['userId'],
      description: json['description'],
      linkMaps: json['linkMaps'],
      images: List<String>.from(json['images']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'description': description,
      'linkMaps': linkMaps,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
