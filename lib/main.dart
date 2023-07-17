import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/routes.dart';
//import 'package:mynotes/views/homepage_view.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes/create_update_note_view.dart';
import 'package:mynotes/views/notes/notes_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const Homepage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Testing Bloc'),
        ),
        body: BlocConsumer<CounterBloc, CounterState>(
          listener: (context, state) {
            _controller.clear();
          },
          builder: (context, state) {
            final invalidValue = (state is CounterStateInvalid) ? state.invalidValue : '';
            return Column(
              children: [
                Text('Current value => ${state.val}'),
                Visibility(
                  visible: state is CounterStateInvalid,
                  child: Text('Invalid input => $invalidValue'),
                ),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'Enter a number'),
                  keyboardType: TextInputType.number,
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        context.read<CounterBloc>().add(
                              DecrementEvent(_controller.text),
                            );
                      },
                      child: const Text('-'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<CounterBloc>().add(
                              IncrementEvent(_controller.text),
                            );
                      },
                      child: const Text('+'),
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterStateValid(0)) {
    on<IncrementEvent>(
      (event, emit) {
        final integer = int.tryParse(event.val);
        if (integer == null) {
          emit(CounterStateInvalid(
            invalidValue: event.val,
            previousValue: state.val,
          ));
        } else {
          emit(CounterStateValid(state.val + integer));
        }
      },
    );

    on<DecrementEvent>(
      (event, emit) {
        final integer = int.tryParse(event.val);
        if (integer == null) {
          emit(CounterStateInvalid(
            invalidValue: event.val,
            previousValue: state.val,
          ));
        } else {
          emit(CounterStateValid(state.val - integer));
        }
      },
    );
  }
}

@immutable
abstract class CounterEvent {
  final String val;

  const CounterEvent(this.val);
}

class IncrementEvent extends CounterEvent {
  const IncrementEvent(String val) : super(val);
}

class DecrementEvent extends CounterEvent {
  const DecrementEvent(String val) : super(val);
}

class CounterStateValid extends CounterState {
  const CounterStateValid(int val) : super(val);
}

class CounterStateInvalid extends CounterState {
  final String invalidValue;
  const CounterStateInvalid({
    required this.invalidValue,
    required int previousValue,
  }) : super(previousValue);
}

@immutable
abstract class CounterState {
  final int val;

  const CounterState(this.val);
}
