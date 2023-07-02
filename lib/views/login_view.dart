// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

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
      body: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Column(
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
                        final userCredential =
                          await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: passwd);
                        print(userCredential);
                      } on FirebaseAuthException catch(e) {
                        if (e.code == 'user-not-found') {
                          print('This username has not been found');
                        } else if (e.code == 'wrong-password') {
                          print('Wrong password. Please try again');
                        }
                      }
                    }, 
                    child: const Text('Sign in'))
                ],
              );
            default:
              return const Text('Loading...');
          }
        },
      ),
    );
  }
}