import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<void> cannotShareEmptyNoteDialog(
  BuildContext context,
) {
  return showGenericDialog(
    context: context,
    title: 'Sharing note',
    content: 'An empty note cannot be shared.',
    optionBuilder: () => {
      'OK': null,
    },
  );
}
