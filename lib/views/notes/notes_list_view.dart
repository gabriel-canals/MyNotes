import 'package:flutter/material.dart';
import 'package:mynotes/constants/colors.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/utilities/dialogs/delete_dialog.dart';

typedef NoteCallback = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;
  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });



  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes.elementAt(index);
        String title = note.title == '' ? context.loc.note : note.title;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 0.75),
              borderRadius: BorderRadius.circular(20),
            ),
            leading: CircleAvatar(
              backgroundColor: myColor,
            ),
            title: Text(
              title,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              note.text,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            trailing: IconButton(
              onPressed: () async {
                final shouldDelete = await showDeleteDialog(context);
                if (shouldDelete) onDeleteNote(note);
              },
              icon: const Icon(Icons.delete),
            ),
            onTap: () {
              onTap(note);
            },
          ),
        );
      },
    );
  }
}
