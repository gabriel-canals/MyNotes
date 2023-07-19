import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';
import 'package:mynotes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  static final FirebaseCloudStorage _shared = FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  Future<void> deleteNote({required String documentID}) async {
    try {
      await notes.doc(documentID).delete();
    } catch (e) {
      CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNote({
    required String documentID,
    required String text,
    required String? title,
  }) async {
    try {
      await notes.doc(documentID).update({
        textFieldName: text,
        titleFieldName: title,
      });
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<CloudNote> createNewNote({required String ownerUID, required String title}) async {
    final document = await notes.add({
      ownerUIDFieldName: ownerUID,
      textFieldName: '',
      titleFieldName: title,
    });
    final fetchedNote = await document.get();
    return CloudNote(
      documentID: fetchedNote.id,
      ownerUID: ownerUID,
      text: '',
      title: title,
    );
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUID}) {
    final allNotes = notes
        .where(ownerUIDFieldName, isEqualTo: ownerUID)
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)));
    return allNotes;
  }
}
