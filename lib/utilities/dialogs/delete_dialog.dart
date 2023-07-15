import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(
  BuildContext context,
) {
  return showGenericDialog(
    context: context,
    title: 'Delete note',
    content: 'Do you want to delete this note?',
    optionBuilder: () => {
      'Delete': true,
      'Cancel': false,
    },
  ).then((value) => value ?? false);
}
