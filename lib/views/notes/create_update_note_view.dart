import 'package:flutter/material.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:mynotes/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:mynotes/utilities/generics/get_arguments.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) return;
    final text = _textController.text;
    await _notesService.updateNote(
      documentID: note.documentID,
      text: text,
    );
  }

  void _setUpTextControllerListener() async {
    _textController.removeListener((_textControllerListener));
    _textController.addListener((_textControllerListener));
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();
    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text; // The text field will have the current text of the note
      return widgetNote;
    }
    final existingNote = _note;
    if (existingNote != null) return existingNote;
    final currentUser = AuthService.firebase().currentUser!;
    final newNote = await _notesService.createNewNote(ownerUID: currentUser.uid);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) _notesService.deleteNote(documentID: note.documentID);
  }

  void _saveNoteIfNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (text.isNotEmpty && note != null) await _notesService.updateNote(documentID: note.documentID, text: text);
  }

  @override
  void dispose() {
    _deleteNoteIfEmpty();
    _saveNoteIfNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.note),
        actions: [
          IconButton(
              onPressed: () async {
                String text = _textController.text;
                if (_note == null || text.isEmpty) {
                  await showCannotShareEmptyNoteDialog(context);
                } else {
                  text = '$text ${context.loc.signature}';
                  Share.share(text);
                }
              },
              icon: const Icon(Icons.share)),
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setUpTextControllerListener();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: context.loc.start_typing_your_note,
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
