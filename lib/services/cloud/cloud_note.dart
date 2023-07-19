import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';
import 'package:flutter/foundation.dart';

@immutable
class CloudNote {
  final String documentID;
  final String ownerUID;
  final String text;
  final String title;

  const CloudNote({
    required this.documentID,
    required this.ownerUID,
    required this.text,
    required this.title,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentID = snapshot.id,
        ownerUID = snapshot.data()[ownerUIDFieldName],
        text = snapshot.data()[textFieldName],
        title = snapshot.data()[titleFieldName];
}
