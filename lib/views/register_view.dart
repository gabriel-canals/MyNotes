import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _username;
  late final TextEditingController _passwd;

  @override
  void initState() {
    _username = TextEditingController();
    _passwd = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _username.dispose();
    _passwd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Column(children: [
        TextField(
          decoration: const InputDecoration(
            hintText: 'Username',
          ),
          controller: _username,
          enableSuggestions: true,
          autocorrect: false,
          keyboardType: TextInputType.emailAddress,
        ),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Password',
          ),
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
          controller: _passwd,
        ),
        TextButton(
          onPressed: () async {
            final email = _username.text;
            final password = _passwd.text;
            try {
              await AuthService.firebase().logIn(
                email: email,
                password: password,
              );
              await AuthService.firebase().sendEmailVerification();
              Navigator.of(context).pushNamed(verifyEmailRoute);
            } on InvalidEmailAuthException {
              await showErrorDialog(
                context,
                'This email is not valid. Please try again.',
              );
            } on WeakPasswordAuthException {
              await showErrorDialog(
                context,
                'This password is too weak. Please try again.',
              );
            } on AlreadyInUseEmailAuthException {
              await showErrorDialog(
                context,
                'An account linked to this email already exists.',
              );
            } on GenericAuthException {
              await showErrorDialog(
                context,
                'An error has occurred. Please try again.',
              );
            }
          },
          child: const Text('Register'),
        ),
        const Text('Already have an account?'),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              loginRoute,
              (route) => false,
            );
          },
          child: const Text('Sign in'),
        ),
      ]),
    );
  }
}
