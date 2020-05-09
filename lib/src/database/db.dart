import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'migrations/001_create_read_table.dart';
import 'migrations/002_add_source_to_read.dart';

class DBHelper{

  final String _dbPath = 'yomu.db';
  static Database _db;
  var upgrades = [
    upgradeTo002
  ];

  Future<Database> get db async {
    if(_db != null)
      return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, _dbPath);

    var theDb = await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: _onDowngrade
    );
    return theDb;
  }

  void _onDowngrade(Database db, int oldVersion, int newVersion) async {
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion == newVersion) return;
    var toApply = upgrades.sublist(oldVersion - 1, newVersion - 1);
    toApply.forEach((upgrade) async {
      await upgrade(db);
    });
  }

  void _onCreate(Database db, int version) async {
    await onCreate(db);
    upgrades.sublist(0, version - 1).forEach((upgrade) async {
      await upgrade(db);
    });
  }

  // Retrieving employees from Employee Tables
  Future<List<String>> getAllRead(String source, String manga) async {
    var dbClient = await db;
    
    var list = await dbClient.query(
      'read',
      columns: ['chapter'],
      where: 'manga = ? AND source = ?',
      whereArgs: [manga, source]
    );

    var readList = <String>[];
    for (int i = 0; i < list.length; i++) {
      readList.add(list[i]['chapter']);
    }

    return readList;
  }
  
  Future<int> saveRead(String source, String manga, String chapter) async {
    var dbClient = await db;
    var recordId = await dbClient.insert(
      'read',
      {'source': source, 'manga': manga, 'chapter': chapter},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    return recordId;
  }
}
