import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogoutDialog(
  BuildContext context,
) {
  return showGenericDialog(
    context: context,
    title: 'Log out',
    content: 'Do you want to log out?',
    optionBuilder: () => {
      'Yes, Log out': true,
      'Cancel': false,
    },
  ).then((value) => value ?? false);
}
