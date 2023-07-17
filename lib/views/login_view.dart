import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
        title: const Text('Login'),
      ),
      body: Column(
        children: [
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
            controller: _passwd,
            enableSuggestions: false,
            autocorrect: false,
            obscureText: true,
          ),
          TextButton(
            onPressed: () async {
              final email = _username.text;
              final passwd = _passwd.text;
              try {
                context.read<AuthBloc>().add(
                      AuthEventLogIn(
                        email,
                        passwd,
                      ),
                    );
              } on UserNotFoundAuthException {
                await showErrorDialog(
                  context,
                  'This user has not been found.',
                );
              } on WrongPasswordAuthException {
                await showErrorDialog(
                  context,
                  'Wrong password. Please try again.',
                );
              } on GenericAuthException {
                await showErrorDialog(
                  context,
                  'Authentication error. Please try again.',
                );
              }
            },
            child: const Text('Sign in'),
          ),
          const Text('Not registered yet?'),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
              );
            },
            child: const Text('Create an account'),
          )
        ],
      ),
    );
  }
}
