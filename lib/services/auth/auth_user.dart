import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  const AuthUser(this.isEmailVerified);
  final bool isEmailVerified;

  factory AuthUser.fromFirebase(User user) => AuthUser(user.emailVerified);
}
