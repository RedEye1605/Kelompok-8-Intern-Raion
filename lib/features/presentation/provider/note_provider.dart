import 'package:flutter/cupertino.dart';

import '../../domain/entities/note.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/update_note.dart';

class NotesProvider with ChangeNotifier {
  final AddNote addNote;
  final GetNotes getNotes;
  final UpdateNote updateNote;
  final DeleteNote deleteNote;

  List<Note> notes = [];

  NotesProvider({
    required this.addNote,
    required this.getNotes,
    required this.updateNote,
    required this.deleteNote,
  });

  Future<void> loadNotes(String userId) async {
    notes = await getNotes(userId);
    notifyListeners();
  }

  Future<void> addNewNote(Note note) async {
    await addNote(AddNoteParams(note: note));
    await loadNotes(note.userId);
  }

  Future<void> updateExistingNote(Note note) async {
    await updateNote(UpdateNoteParams(note: note));
    await loadNotes(note.userId);
  }

  Future<void> removeNote(String noteId, String userId) async {
    await deleteNote(DeleteNoteParams(noteId: noteId, userId: userId));
    await loadNotes(userId);
  }
}