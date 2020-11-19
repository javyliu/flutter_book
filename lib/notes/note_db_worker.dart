import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils.dart' as utils;
import 'models/note.dart';

class NoteDBWorker {
  NoteDBWorker._();

  static final NoteDBWorker db = NoteDBWorker._();
  Database _db;

  Future get database async {
    _db ??= await init();
    print("## Notes NotesDBWorker.get-database(): _db = $_db");

    return _db;
  }

  Future<Database> init() async {
    print("Notes NotesDBWorker.init()");
    String path = join(utils.docsDir.path, "notes.db");
    print("## notes NotesDBWorker.init(): path=$path");

    Database db = await openDatabase(
      path,
      version: 1,
      onOpen: (indb) {},
      onCreate: (indb, version) async {
        await indb.execute("create table if not exists notes ("
            "id integer primary key,"
            "title text,"
            "content text,"
            "color text"
            ")");
      },
    );
    return db;
  }

  Future create(Note note) async {
    print("## Notes NotesDBWorker.create(): inNote = $note");
    Database db = await database;

    var val = await db.rawQuery("select max(id)+1 as id from notes");
    note.id = val.first["id"] ?? 1;

    return await db.insert("notes", note.toMap());
  }

  Future<Note> find(int id) async {
    print("## Notes NotesDBWorker.get(): inID = $id");

    Database db = await database;

    var rec = await db.query("notes", where: "id = ?", whereArgs: [id]);
    return Note.fromMap(rec.first);
  }

  Future<List> all() async {
    print("## Notes NotesDBWorker.getAll()");

    Database db = await database;
    var recs = await db.query("notes");
    var list = recs.isNotEmpty ? recs.map((m) => Note.fromMap(m)).toList() : [];
    return list;
  }

  Future update(Note note) async {
    print("## Notes NotesDBWorker.update(): inNote = $note");

    Database db = await database;
    return await db.update("notes", note.toMap(), where: "id = ?", whereArgs: [note.id]);
  }

  Future delete(int id) async {
    print("## Notes NotesDBWorker.delete(): inID = $id");

    Database db = await database;
    return await db.delete("notes", where: "id = ?", whereArgs: [id]);
  }
}
