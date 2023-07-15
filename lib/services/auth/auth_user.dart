import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  const AuthUser({
    required this.email,
    required this.isEmailVerified,
    required this.uid,
  });
  final String uid;
  final bool isEmailVerified;
  final String email;
  factory AuthUser.fromFirebase(User user) => AuthUser(
        isEmailVerified: user.emailVerified,
        email: user.email!,
        uid: user.uid,
      );
}
