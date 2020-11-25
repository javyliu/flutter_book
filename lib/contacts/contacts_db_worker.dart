import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils.dart' as utils;
import 'models/contact.dart';

class ContactDBWorker {
  ContactDBWorker._();

  static final ContactDBWorker db = ContactDBWorker._();

  Database _db;

  Future get database async {
    if (_db == null) {
      _db = await init();
    }

    return _db;
  }

  Future<Database> init() async {
    String path = join(utils.docsDir.path, "contacts.db");
    Database _database = await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (db, version) async {
        await db.execute("create table if not exists contacts ("
            "id integer primary key,"
            "name text,"
            "email text,"
            "phone text,"
            "birthday text"
            ")");
      },
    );

    return _database;
  }

  Future create(Contact user) async {
    Database db = await database;
    var val = await db.rawQuery("select max(id) + 1 as id from contacts");
    user.id = val.first["id"] ?? 1;
    await db.insert("contacts", user.toJson());
    return user.id;
  }

  Future<Contact> find(int id) async {
    Database db = await database;
    var rec = await db.query("contacts", where: "id = ? ", whereArgs: [id]);
    return Contact.fromJson(rec.first);
  }

  Future<List> all() async {
    Database db = await database;
    var recs = await db.query("contacts");
    var list = recs.isNotEmpty ? recs.map((m) => Contact.fromJson(m)).toList() : [];
    return list;
  }

  Future update(Contact contact) async {
    Database db = await database;
    return await db.update("contacts", contact.toJson(), where: "id = ?", whereArgs: [contact.id]);
  }

  Future delete(int id) async {
    Database db = await database;
    return await db.delete("contacts", where: "id = ?", whereArgs: [id]);
  }
}
