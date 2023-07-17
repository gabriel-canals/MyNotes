import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventLogIn extends AuthEvent {
  final String email;
  final String passwd;
  const AuthEventLogIn(this.email, this.passwd);
}

class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}

class AuthEventSendEmailVerification extends AuthEvent {
  const AuthEventSendEmailVerification();
}

class AuthEventRegister extends AuthEvent{
  final String email;
  final String passwd;
  const AuthEventRegister(this.email, this.passwd);
}

class AuthEventForgotPassword extends AuthEvent{
  final String? email;
  const AuthEventForgotPassword({this.email});
}

class AuthEventShouldRegister extends AuthEvent{
  const AuthEventShouldRegister();
}