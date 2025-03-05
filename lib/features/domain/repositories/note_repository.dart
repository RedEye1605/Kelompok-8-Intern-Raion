import 'package:my_flutter_app/features/domain/entities/note.dart';

abstract class NotesRepository {
  Future<void> addNote(Note note);
  Future<void> deleteNote(String noteId, String userId);
  Future<void> updateNote(Note note);
  Future<List<Note>> getNotes(String userId);
}