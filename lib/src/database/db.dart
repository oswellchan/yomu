import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'migrations/001_create_read_table.dart';


class DBHelper{

  final String _dbPath = 'yomu.db';
  static Database _db;

  Future<Database> get db async {
    if(_db != null)
      return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, _dbPath);

    var theDb = await openDatabase(path, version: 1, onCreate: onCreate);
    return theDb;
  }

  // Retrieving employees from Employee Tables
  Future<List<String>> getAllRead(String manga) async {
    var dbClient = await db;
    
    var list = await dbClient.query(
      'read',
      columns: ['chapter'],
      where: 'manga = ?',
      whereArgs: [manga]
    );

    var readList = <String>[];
    for (int i = 0; i < list.length; i++) {
      readList.add(list[i]['chapter']);
    }

    return readList;
  }
  
  Future<int> saveRead(String manga, String chapter) async {
    var dbClient = await db;
    var recordId = await dbClient.insert(
      'read',
      {'manga': manga, 'chapter': chapter},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    return recordId;
  }
}
