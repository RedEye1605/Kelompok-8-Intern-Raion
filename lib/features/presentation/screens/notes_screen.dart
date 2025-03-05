import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/presentation/provider/note_provider.dart';
import 'package:my_flutter_app/features/presentation/screens/add_note_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);

    notesProvider
        .loadNotes(firebase_auth.FirebaseAuth.instance.currentUser!.uid);

    return Scaffold(
      appBar: AppBar(
        title:
            Text('${firebase_auth.FirebaseAuth.instance.currentUser?.email}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              // Logout user
              await firebase_auth.FirebaseAuth.instance.signOut();
              // Navigate to the Login Screen after logout
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Consumer<NotesProvider>(
        builder: (context, notesProvider, child) {
          if (notesProvider.notes.isEmpty) {
            return const Center(child: Text('No notes available.'));
          }

          return ListView.builder(
            itemCount: notesProvider.notes.length,
            itemBuilder: (context, index) {
              final note = notesProvider.notes[index];

              return ListTile(
                title: Text(note.title),
                subtitle: Text(note.content),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddNoteScreen(note: note),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await notesProvider.removeNote(
                            note.id,
                            firebase_auth
                                .FirebaseAuth.instance.currentUser!.uid);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNoteScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}