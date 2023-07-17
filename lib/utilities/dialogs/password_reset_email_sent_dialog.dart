import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(
  BuildContext context,
) {
  return showGenericDialog<void>(
    context: context,
    content: 'We have sent you a password reset link. Please check your email inbox',
    title: 'Password reset',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
