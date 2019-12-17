import 'dart:io';

import 'package:eventevent/Database/Models/EventBannerModel.dart';
import 'package:eventevent/helper/API/catalogModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  static Database _database;

  Future<Database> get database async{
    if(_database != null)
      return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "EventeventDatabase.db");
    return await openDatabase(path, version: 1, onOpen: (db){},
      onCreate: (Database db, int version) async {
        await db.execute("CREATE TABLE event_banner ("
            "id INTEGER PRIMARY KEY,"
            "name TEXT,"
            "image TEXT"
            ")");
      }
    );
  }
}