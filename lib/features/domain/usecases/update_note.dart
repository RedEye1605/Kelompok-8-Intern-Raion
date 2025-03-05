import 'package:my_flutter_app/core/usecases/usecases.dart';
import 'package:my_flutter_app/features/domain/entities/note.dart';
import 'package:my_flutter_app/features/domain/repositories/note_repository.dart';

class UpdateNote implements UseCase<void, UpdateNoteParams> {
  final NotesRepository repository;

  UpdateNote(this.repository);

  @override
  Future<void> call(UpdateNoteParams params) async {
    await repository.updateNote(params.note);
  }
}

class UpdateNoteParams {
  final Note note;

  UpdateNoteParams({required this.note});
}