import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'crud_exceptions.dart';

class NotesService {
  Database? _db;

  List<DatabaseNote> _notes = [];

  final _notesStreamController = StreamController<List<DatabaseNote>>.broadcast();

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    _getDatabaseOrThrow();
    try {
      final user = await getUser(email: email);
      return user;
    } on UserNotFoundException {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    final db = _getDatabaseOrThrow();
    await getNote(noteId: note.noteId);
    final update = await db.update(noteTable, {
      contentCol: text,
    });
    if (update == 0) throw CouldNotUpdateNoteException();
    final updatedNote = await getNote(noteId: note.noteId);
    _notes.removeWhere((note) => note.noteId == updatedNote.noteId);
    _notes.add(updatedNote);
    _notesStreamController.add(_notes);
    return updatedNote;
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    if (notes.isEmpty) throw CouldNotFindNoteException();
    final results = notes.map((e) => DatabaseNote.fromRow(e));
    return results;
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    final numberOfNotes = await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return numberOfNotes;
  }

  Future<DatabaseNote> getNote({required int noteId}) async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [noteId],
    );
    if (notes.isEmpty) throw CouldNotFindNoteException();
    final note = DatabaseNote.fromRow(notes.first);
    _notes.removeWhere((note) => note.noteId == noteId);
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<void> deleteNote({required int noteId}) async {
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [noteId],
    );
    if (deleteCount == 0) throw CouldNotDeleteNoteException();
    _notes.removeWhere((note) => note.noteId == noteId);
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    if (owner != dbUser) throw UserNotFoundException();
    const text = '';
    final noteId = await db.insert(noteTable, {
      userIdCol: owner.uid,
      contentCol: text,
    });

    final note = DatabaseNote(
      noteId: noteId,
      uid: owner.uid,
      content: text,
    );

    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) throw UserNotFoundException();
    return DatabaseUser.fromRow(results.first);
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) throw UserAlreadyExistsException();
    final uid = await db.insert(userTable, {emailCol: email.toLowerCase()});
    return DatabaseUser(
      uid: uid,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedAccount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedAccount != 1) throw CouldNotDeleteUserException();
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) throw DatabaseIsNotOpenException();
    return db;
  }

  Future<void> close() async {
    final db = _getDatabaseOrThrow();
    await db.close();
    _db = null;
  }

  Future<void> open() async {
    if (_db != null) throw DatabaseAlreadyOpenException();
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
        "UID"	INTEGER NOT NULL,
	      "email"	TEXT NOT NULL UNIQUE,
	      PRIMARY KEY("UID" AUTOINCREMENT)
      );''';

      await db.execute(createUserTable);

      const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
      	"note_id"	INTEGER NOT NULL,
      	"UID"	INTEGER NOT NULL,
      	"content"	TEXT,
      	FOREIGN KEY("UID") REFERENCES "user"("UID"),
      	PRIMARY KEY("note_id" AUTOINCREMENT)
      );''';

      await db.execute(createNoteTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }
  }
}

@immutable
class DatabaseUser {
  final int uid;
  final String email;

  // Constructor
  const DatabaseUser({
    required this.uid,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : uid = map[idCol] as int,
        email = map[emailCol] as String;

  @override
  String toString() => 'User ID = $uid, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}

@immutable
class DatabaseNote {
  final int uid;
  final int noteId;
  final String content;

  const DatabaseNote({
    required this.uid,
    required this.noteId,
    required this.content,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : noteId = map[idCol] as int,
        uid = map[userIdCol] as int,
        content = map[contentCol] as String;

  @override
  String toString() => 'Note id: $noteId, User ID: $uid';

  @override
  bool operator ==(covariant DatabaseNote other) => noteId == other.noteId;

  @override
  int get hashCode => noteId.hashCode;
}

const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idCol = 'id';
const emailCol = 'email';
const userIdCol = 'userId';
const contentCol = 'content';
