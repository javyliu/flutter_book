import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils.dart' as utils;
import 'notes_model.dart';

class NotesDBWorker {
  NotesDBWorker._();

  static final NotesDBWorker db = NotesDBWorker._();
  Database _db;

  Future get database async {
    if (_db == null) {
      _db = await init();
    }
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

  Map<String, dynamic> noteToMap(Note inNote) {
    print("## Notes NotesDBWorker.noteToMap(): inNote = $inNote");

    Map<String, dynamic> map = Map<String, dynamic>();

    map["id"] = inNote.id;
    map["title"] = inNote.title;
    map["content"] = inNote.content;
    map["color"] = inNote.color;

    print("## notes NotesDBWorker.noteToMap: map = $map");

    return map;
  }

  Note noteFromMap(Map inMap) {
    print("## Notes NotesDBWorker.noteFromMap(): inMap = $inMap");
    Note note = Note();
    note.id = inMap["id"];
    note.title = inMap["title"];
    note.content = inMap["content"];
    note.color = inMap["color"];
    print("## notes NotesDBWorker.noteFromMap(): note = $note");

    return note;
  }

  Future create(Note inNote) async {
    print("## Notes NotesDBWorker.create(): inNote = $inNote");
    Database db = await database;

    var val = await db.rawQuery("select max(id)+1 as id from notes");
    int id = val.first["id"] ?? 1;

    return await db.rawInsert("insert into notes(id, title, content, color) values(?,?,?,?)", [id, inNote.title, inNote.content, inNote.color]);
  }

  Future<Note> find(int inID) async {
    print("## Notes NotesDBWorker.get(): inID = $inID");

    Database db = await database;

    var rec = await db.query("notes", where: "id = ?", whereArgs: [inID]);
    return noteFromMap(rec.first);
  }

  Future<List> all() async {
    print("## Notes NotesDBWorker.getAll()");

    Database db = await database;
    var recs = await db.query("notes");
    var list = recs.isNotEmpty ? recs.map((m) => noteFromMap(m)).toList() : [];
    return list;
  }

  Future update(Note inNote) async {
    print("## Notes NotesDBWorker.update(): inNote = $inNote");

    Database db = await database;
    return await db.update("notes", noteToMap(inNote), where: "id = ?", whereArgs: [inNote.id]);
  }

  Future delete(int inID) async {
    print("## Notes NotesDBWorker.delete(): inID = $inID");

    Database db = await database;
    return await db.delete("notes", where: "id = ?", whereArgs: [inID]);
  }
}
