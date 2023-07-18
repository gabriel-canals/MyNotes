import 'package:bloc/bloc.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateUninitialized(isLoading: true)) {
    //send email verification
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });

    on<AuthEventForgotPassword>(
      (event, emit) async {
        emit(const AuthStateForgotPassword(
          exception: null,
          hasSentEmail: false,
          isLoading: false,
        ));
        final email = event.email;
        if (email == null) return;
        emit(const AuthStateForgotPassword(
          exception: null,
          hasSentEmail: false,
          isLoading: true,
        ));
        bool sentEmail;
        Exception? exception;
        try {
          await provider.sendPasswordReset(toEmail: email);
          sentEmail = true;
          exception = null;
        } on Exception catch (e) {
          sentEmail = false;
          exception = e;
        }
        emit(AuthStateForgotPassword(
          exception: exception,
          hasSentEmail: sentEmail,
          isLoading: false,
        ));
      },
    );

    on<AuthEventShouldRegister>((event, emit) async {
      emit(
        const AuthStateRegistering(
          exception: null,
          isLoading: false,
        ),
      );
    });

    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final passwd = event.passwd;
      try {
        await provider.createUser(
          email: email,
          password: passwd,
        );
        await provider.sendEmailVerification();
        emit(const AuthStateNeedsVerification(isLoading: false));
      } on Exception catch (exception) {
        emit(
          AuthStateRegistering(
            exception: exception,
            isLoading: false,
          ),
        );
      }
    });

    // initialize
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(
          exception: null,
          isLoading: false,
        ));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification(isLoading: false));
      } else {
        emit(AuthStateLoggedIn(
          user: user,
          isLoading: false,
        ));
      }
    });
    // log in
    on<AuthEventLogIn>((event, emit) async {
      emit(const AuthStateLoggedOut(
        exception: null,
        isLoading: true,
        loadingText: null,
      ));
      final email = event.email;
      final password = event.passwd;
      try {
        final user = await provider.logIn(
          email: email,
          password: password,
        );
        if (!user.isEmailVerified) {
          emit(const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ));
          emit(const AuthStateNeedsVerification(isLoading: false));
        } else {
          emit(const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ));
          emit(AuthStateLoggedIn(
            user: user,
            isLoading: false,
          ));
        }
        emit(AuthStateLoggedIn(
          user: user,
          isLoading: false,
        ));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(
          exception: e,
          isLoading: false,
        ));
      }
    });
    // log out
    on<AuthEventLogOut>((event, emit) async {
      try {
        await provider.logOut();
        emit(const AuthStateLoggedOut(
          exception: null,
          isLoading: false,
        ));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(
          exception: e,
          isLoading: false,
        ));
      }
    });
  }
}
