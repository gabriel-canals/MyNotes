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
  }) async {
    try {
      await notes.doc(documentID).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<CloudNote> createNewNote({required String ownerUID}) async {
    final document = await notes.add({
      ownerUIDFieldName: ownerUID,
      textFieldName: '',
    });
    final fetchedNote = await document.get();
    return CloudNote(
      documentID: fetchedNote.id,
      ownerUID: ownerUID,
      text: '',
    );
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUID}) => notes
      .snapshots()
      .map((event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)).where((note) => note.ownerUID == ownerUID));

  Future<Iterable<CloudNote>> getNotes({required String ownerUID}) async {
    try {
      return await notes
          .where(
            ownerUIDFieldName,
            isEqualTo: ownerUID,
          )
          .get()
          .then(
            (value) => value.docs.map((doc) => CloudNote.fromSnapshot(doc)),
          );
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }
}
