import 'package:my_flutter_app/core/usecases/usecases.dart';
import 'package:my_flutter_app/features/domain/entities/note.dart';
import 'package:my_flutter_app/features/domain/repositories/note_repository.dart';

class AddNote implements UseCase<void, AddNoteParams> {
  final NotesRepository repository;

  AddNote(this.repository);

  @override
  Future<void> call(AddNoteParams params) async {
    await repository.addNote(params.note);
  }
}

class AddNoteParams {
  final Note note;

  AddNoteParams({required this.note});
}