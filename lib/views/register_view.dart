
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';

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
                final userCredential = 
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
                log(userCredential.toString());
              } on FirebaseAuthException catch(e) {
                if (e.code == 'invalid-email') {
                  log('This is an invalid email');
                } else if (e.code == 'weak-password') {
                  log('This password is not valid');
                } else if (e.code == 'email-already-in-use') {
                  log('An account linked to this email already exists');
                } else {
                  log(e.code);
                }
              }
            },
            child: const Text('Register'),
          ),
          const Text('Already have an account?'),
          TextButton(onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              loginRoute,
              (route) => false,
            );
          }, 
          child: const Text('Sign in'),
          ),
        ]
      ),
    );      
  }
}
