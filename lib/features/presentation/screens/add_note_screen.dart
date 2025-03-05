import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/domain/entities/note.dart';
import 'package:my_flutter_app/features/presentation/provider/note_provider.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AddNoteScreen extends StatefulWidget {
  final Note? note;

  const AddNoteScreen({this.note, super.key});

  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: widget.note == null ? const Text('Add New Note') : const Text('Edit Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final title = _titleController.text.trim();
                final content = _contentController.text.trim();
                if (title.isNotEmpty && content.isNotEmpty) {
                  if (widget.note == null) {
                    final newNote = Note(
                      id: DateTime.now().toString(),
                      title: title,
                      content: content,
                      createdAt: DateTime.now(),
                      userId: firebase_auth.FirebaseAuth.instance.currentUser!.uid,
                    );
                    notesProvider.addNewNote(newNote);
                  } else {
                    final updatedNote = widget.note!.copyWith(
                      title: title,
                      content: content,
                    );
                    notesProvider.updateExistingNote(updatedNote);
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('Save Note'),
            ),
          ],
        ),
      ),
    );
  }
}