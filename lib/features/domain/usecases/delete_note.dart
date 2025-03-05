import 'package:my_flutter_app/core/usecases/usecases.dart';
import 'package:my_flutter_app/features/domain/repositories/note_repository.dart';

class DeleteNote implements UseCase<void, DeleteNoteParams> {
  final NotesRepository repository;

  DeleteNote(this.repository);

  @override
  Future<void> call(DeleteNoteParams params) async {
    await repository.deleteNote(params.noteId, params.userId);
  }
}

class DeleteNoteParams {
  final String noteId;
  final String userId;

  DeleteNoteParams({required this.noteId, required this.userId});
}