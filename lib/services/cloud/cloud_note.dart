import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';
import 'package:flutter/foundation.dart';

@immutable
class CloudNote {
  final String documentID;
  final String ownerUID;
  final String text;

  const CloudNote({
    required this.documentID,
    required this.ownerUID,
    required this.text,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentID = snapshot.id,
        ownerUID = snapshot.data()[ownerUIDFieldName],
        text = snapshot.data()[textFieldName];
}
