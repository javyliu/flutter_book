import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../utils.dart' as utils;
import 'models/appointment.dart';

class AppointmentDBWorker {
  AppointmentDBWorker._();
  static final AppointmentDBWorker db = AppointmentDBWorker._();
  Database _db;

  Future get database async {
    if (_db == null) {
      _db = await init();
    }
    return _db;
  }

  Future<Database> init() async {
    String path = join(utils.docsDir.path, "appointments.db");

    Database _db = await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (db, version) async {
        await db.execute("create table if not exists appointments ("
            "id integer primary key,"
            "title text,"
            "description text,"
            "apptDate text,"
            "apptTime text"
            ")");
      },
    );

    return _db;
  }

  Future create(Appointment model) async{
    Database db = await database;
    var val = await db.rawQuery("select max(id)+1 as id from appointments");
    model.id = val.first["id"] ?? 1;

    return await db.insert("appointments", model.toMap());
    
  }

  Future<Appointment> find(int id) async{
    Database db = await database;
    var rec = await db.query("appointments", where: "id=?", whereArgs: [id]);
    return Appointment.fromMap(rec.first);
  }

  Future<List> all() async{
    Database db = await database;
    var recs = await db.query("appointments");
    return recs.isNotEmpty ? recs.map((e) => Appointment.fromMap(e)).toList() : [];
    
  }

  Future update(Appointment model) async{
    Database db = await database;
    return await db.update("appointments", model.toMap(), where: "id=?", whereArgs: [model.id]);
    
    
  }

  Future delete(int id) async{
    Database db = await database;
    return await db.delete("appointments", where: "id=?", whereArgs: [id]);
    
  }


}
