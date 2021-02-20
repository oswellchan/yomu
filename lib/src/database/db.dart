import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'migrations/001_create_read_table.dart';
import 'migrations/002_add_source_to_read.dart';
import 'migrations/003_add_manga_add_timestamp.dart';
import 'migrations/004_add_manga_thumbnail.dart';

class DBHelper {
  final String _dbPath = 'yomu.db';
  static Database _db;
  var upgrades = [
    upgradeTo002,
    upgradeTo003,
    upgradeTo004,
  ];

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, _dbPath);

    var theDb = await openDatabase(path,
        version: 4,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onDowngrade: _onDowngrade);
    return theDb;
  }

  void _onDowngrade(Database db, int oldVersion, int newVersion) async {}

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion == newVersion) return;
    var toApply = upgrades.sublist(oldVersion - 1, newVersion - 1);
    for (final upgrade in toApply) {
      await upgrade(db);
    }
  }

  void _onCreate(Database db, int version) async {
    await onCreate(db);
    for (final upgrade in upgrades.sublist(0, version - 1)) {
      await upgrade(db);
    }
  }

  Future<List<String>> getAllRead(String source, String manga) async {
    var dbClient = await db;

    var list = await dbClient.query('read',
        columns: ['chapter'],
        where: 'manga = ? AND source = ?',
        whereArgs: [manga, source]);

    var readList = <String>[];
    for (int i = 0; i < list.length; i++) {
      readList.add(list[i]['chapter']);
    }

    return readList;
  }

  Future<List<Map<String, dynamic>>> getAllRecents(String source, int n) async {
    if (n < 1) {
      return [];
    }

    var dbClient = await db;

    var list = await dbClient.rawQuery('''
      SELECT manga.*, read.ts, read.chapter_name, read.chapter FROM read
      INNER JOIN manga ON manga.manga = read.manga
      WHERE read.id in (
        SELECT r1.id as rid FROM read r1 LEFT JOIN read r2
        ON (r1.manga = r2.manga AND r1.ts < r2.ts AND r1.source = r2.source)
        WHERE r2.id IS NULL AND r1.source = ?
        AND manga.thumbnail IS NOT NULL
        AND read.chapter_name IS NOT NULL
        ORDER BY r1.ts DESC
        LIMIT ?
      )
      ORDER BY ts DESC
      ''', [source, n]);

    return list;
  }

  Future<int> saveRead(
      String source, String manga, String chapter, String chapterName) async {
    var dbClient = await db;

    final ts = DateTime.now().millisecondsSinceEpoch;
    var recordId = await dbClient.insert(
      'read',
      {
        'source': source,
        'manga': manga,
        'chapter': chapter,
        'ts': ts,
        'chapter_name': chapterName
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return recordId;
  }

  Future<int> saveManga(
      String source, String manga, String name, String thumbnail) async {
    var dbClient = await db;

    var recordId = await dbClient.insert(
      'manga',
      {'source': source, 'manga': manga, 'name': name, 'thumbnail': thumbnail},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return recordId;
  }
}
