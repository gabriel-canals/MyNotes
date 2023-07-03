import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';

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
                await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: passwd);
                final user = FirebaseAuth.instance.currentUser;
                if (user != null && user.emailVerified) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    notesRoute,
                    (route) => false,
                  );
                } else {
                  // TODO: Push verify email view
                }
              } on FirebaseAuthException catch(e) {
                if (e.code == 'user-not-found') {
                  log('This username has not been found');
                } else if (e.code == 'wrong-password') {
                  log('Wrong password. Please try again');
                }
              }
            }, 
           child: const Text('Sign in')
          ),
          const Text('Not registered yet?'),
          TextButton(onPressed: () {
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