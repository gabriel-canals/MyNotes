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
  late final TextEditingController _titleController;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _textController = TextEditingController();
    _titleController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) return;
    final text = _textController.text;
    final title = _titleController.text;
    await _notesService.updateNote(
      documentID: note.documentID,
      text: text,
      title: title,
      updateTime: DateTime.now().toUtc(),
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
      if (widgetNote.title.isNotEmpty) {
        _titleController.text = widgetNote.title;
      }
      return widgetNote;
    }
    final existingNote = _note;
    if (existingNote != null) return existingNote;
    final currentUser = AuthService.firebase().currentUser!;
    final newNote = await _notesService.createNewNote(ownerUID: currentUser.uid, title: '');
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfEmpty() {
    final note = _note;
    final text = _textController.text;
    final title = _titleController.text;
    if (text.isEmpty && title.isEmpty && note != null) _notesService.deleteNote(documentID: note.documentID);
  }

  void _saveNoteIfNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    String title = _titleController.text;
    if (note != null && (text.isNotEmpty || title.isNotEmpty)) {
      await _notesService.updateNote(
        documentID: note.documentID,
        text: text,
        title: title,
        updateTime: DateTime.now().toUtc(),
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfEmpty();
    _saveNoteIfNotEmpty();
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          String appBarTitleText = _titleController.text;
          switch (snapshot.connectionState) {
            case ConnectionState.done:
            case ConnectionState.waiting:
            case ConnectionState.active:
              _setUpTextControllerListener();
              return Scaffold(
                appBar: AppBar(
                  title: TextField(
                    readOnly: true,
                    maxLines: 1,
                    controller: _titleController,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                      overflow: TextOverflow.ellipsis,
                    ),
                    decoration: InputDecoration(
                      hintText: appBarTitleText.isEmpty ? context.loc.note : appBarTitleText,
                      border: InputBorder.none,
                      hintStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
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
                body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (value) {
                          appBarTitleText = value;
                        },
                        controller: _titleController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        style: const TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          hintText: context.loc.note_title,
                          border: InputBorder.none,
                        ),
                      ),
                      TextField(
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        showCursor: true,
                        style: const TextStyle(fontSize: 17),
                        decoration: InputDecoration(
                            hintText: context.loc.start_typing_your_note,
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            )),
                      ),
                    ],
                  ),
                ),
              );
            default:
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
        });
  }
}
