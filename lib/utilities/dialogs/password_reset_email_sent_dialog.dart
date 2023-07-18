import 'package:flutter/material.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(
  BuildContext context,
) {
  return showGenericDialog<void>(
    context: context,
    content: context.loc.password_reset_dialog_prompt,
    title: context.loc.password_reset,
    optionsBuilder: () => {
      context.loc.ok: null,
    },
  );
}
