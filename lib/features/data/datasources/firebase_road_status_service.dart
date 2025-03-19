import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_flutter_app/features/data/models/road_status_model.dart';

abstract class FirebaseRoadStatusRemoteDataSource {
  Future<List<RoadStatusModel>> getRoadStatuses();
  Future<RoadStatusModel> createRoadStatus(RoadStatusModel roadStatusModel);
  Future<RoadStatusModel> updateRoadStatus(
    String id,
    RoadStatusModel roadStatusModel,
  );
  Future<void> deleteRoadStatus(String id);
}

class FirebaseRoadStatusRemoteDataSourceImpl
    implements FirebaseRoadStatusRemoteDataSource {
  final FirebaseFirestore firestore;

  FirebaseRoadStatusRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<RoadStatusModel>> getRoadStatuses() async {
    final querySnapshot = await firestore.collection('road_status').get();
    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return RoadStatusModel.fromJson(data);
    }).toList();
  }

  @override
  Future<RoadStatusModel> createRoadStatus(
    RoadStatusModel roadStatusModel,
  ) async {
    try {
      print("Menyimpan data ke Firestore: ${roadStatusModel.toJson()}");
      final docRef = await firestore
          .collection('road_status')
          .add(roadStatusModel.toJson());
      final docSnapshot = await docRef.get();
      final data = docSnapshot.data()!;
      data['id'] = docSnapshot.id;
      print("Data berhasil disimpan dengan ID: ${docSnapshot.id}");
      return RoadStatusModel.fromJson(data);
    } catch (e) {
      print("Error saat menyimpan data ke Firestore: $e");
      rethrow;
    }
  }

  @override
  Future<RoadStatusModel> updateRoadStatus(
    String id,
    RoadStatusModel roadStatusModel,
  ) async {
    await firestore
        .collection('road_status')
        .doc(id)
        .update(roadStatusModel.toJson());
    final updatedDoc = await firestore.collection('road_status').doc(id).get();
    final data = updatedDoc.data()!;
    data['id'] = updatedDoc.id;
    return RoadStatusModel.fromJson(data);
  }

  @override
  Future<void> deleteRoadStatus(String id) async {
    await firestore.collection('road_status').doc(id).delete();
  }
}
