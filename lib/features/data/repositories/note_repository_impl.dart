import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_flutter_app/features/domain/entities/note.dart';
import 'package:my_flutter_app/features/domain/repositories/note_repository.dart';

class NotesRepositoryImpl implements NotesRepository {
  final FirebaseFirestore firestore;

  NotesRepositoryImpl(this.firestore);

  @override
  Future<void> addNote(Note note) async {
    try {
      await firestore.collection('users').doc(note.userId).collection('notes').add({
        'title': note.title,
        'content': note.content,
        'createdAt': note.createdAt,
      });
    } catch (e) {
      throw Exception('Error adding note: $e');
    }
  }

  @override
  Future<void> deleteNote(String noteId, String userId) async {
    try {
      await firestore.collection('users').doc(userId).collection('notes').doc(noteId).delete();
    } catch (e) {
      throw Exception('Error deleting note: $e');
    }
  }

  @override
  Future<void> updateNote(Note note) async {
    try {
      await firestore.collection('users').doc(note.userId).collection('notes').doc(note.id).update({
        'title': note.title,
        'content': note.content,
        'createdAt': note.createdAt,
      });
    } catch (e) {
      throw Exception('Error updating note: $e');
    }
  }

  @override
  Future<List<Note>> getNotes(String userId) async {
    try {
      final snapshot = await firestore.collection('users').doc(userId).collection('notes').get();
      return snapshot.docs.map((doc) {
        return Note(
          id: doc.id,
          title: doc['title'],
          content: doc['content'],
          createdAt: doc['createdAt'].toDate(),
          userId: userId, // Ensure userId is included
        );
      }).toList();
    } catch (e) {
      throw Exception('Error fetching notes: $e');
    }
  }
}