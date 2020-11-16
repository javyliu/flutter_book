
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../utils.dart' as utils;
import 'models/task.dart';

class TasksDBWorker {
  Database _db;
  TasksDBWorker._();

  static final TasksDBWorker db = TasksDBWorker._();

  Future get database async {
    _db ??= await init();
    return _db;
  }

  //初始化数据库
  Future<Database> init() async {
    String path = join(utils.docsDir.path, "tasks.db");
    Database _db = await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (db, version) async {
        await db.execute("create table if not exists tasks ("
            "id integer primary key,"
            "description text,"
            "dueDate text,"
            "completed text"
            ")");
      },
    );
    return _db;
  }

  /// Task taskFromMap(Map inMap) => Task.fromJson(inMap)
  /// Map<String, dynamic> taskToMap(Task inTask) => inTask.toJson()

  Future create(Task inTask) async {
    Database db = await database;
    var val = await db.rawQuery("select max(id)+1 as id from tasks");
    Map<String, dynamic> values = inTask.toJson();

    values["id"] = val.first["id"] ?? 1;
    return await db.insert("tasks", values);
    // return await db.rawInsert("insert into tasks(id, description, dueDate, completed) values (?,?,?,?)", [id, inTask.description, inTask.dueDate, inTask.completed]);
  }

  Future<Task> find(int id) async{
    Database db = await database;
    var rec=await db.query("tasks", where: "id=?", whereArgs: [id]);
    return Task.fromJson(rec.first);
    
  }

  Future<List> all() async{
    Database db = await database;
    var recs = await db.query("tasks");
    return recs.isNotEmpty ? recs.map((m)=>Task.fromJson(m)).toList() : [];
  }

  
  Future update(Task tsk) async{
    Database db = await database;
    
    return await db.update("tasks", tsk.toJson(), where: "id = ?", whereArgs: [tsk.id]);
  }

  Future delete(int id) async{
    Database db = await database;
    return await db.delete("tasks", where: "id=?", whereArgs: [id]);
    
  }

}
