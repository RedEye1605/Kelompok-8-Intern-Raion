import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_flutter_app/features/data/models/note_model.dart';

class NotesFirestoreService {
  final FirebaseFirestore firestore;

  NotesFirestoreService({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addNote(NoteModel note) async {
    await firestore.collection('notes').doc(note.id).set(note.toJson());
  }

  Future<void> deleteNote(String noteId) async {
    await firestore.collection('notes').doc(noteId).delete();
  }

  Future<void> updateNote(NoteModel note) async {
    await firestore.collection('notes').doc(note.id).update(note.toJson());
  }

  Future<List<NoteModel>> getNotes(String userId) async {
    final querySnapshot = await firestore
        .collection('notes')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => NoteModel.fromJson(doc.data()))
        .toList();
  }
}