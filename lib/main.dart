// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:mynotes/views/homepage_view.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/register-view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const Homepage(),
    ),
  );
}
