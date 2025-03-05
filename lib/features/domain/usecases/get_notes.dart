import 'package:my_flutter_app/core/usecases/usecases.dart';
import 'package:my_flutter_app/features/domain/entities/note.dart';
import 'package:my_flutter_app/features/domain/repositories/note_repository.dart';

class GetNotes implements UseCase<List<Note>, String> {
  final NotesRepository repository;

  GetNotes(this.repository);

  @override
  Future<List<Note>> call(String userId) async {
    return await repository.getNotes(userId);
  }
}