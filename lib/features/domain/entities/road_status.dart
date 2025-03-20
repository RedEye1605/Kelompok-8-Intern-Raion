class RoadStatusEntity {
  final String id;
  final String userId;
  final String description;
  final String linkMaps;
  final List<String> images;
  final DateTime createdAt;

  RoadStatusEntity({
    required this.id,
    required this.userId,
    required this.description,
    required this.linkMaps,
    required this.images,
    required this.createdAt,
  });
}
