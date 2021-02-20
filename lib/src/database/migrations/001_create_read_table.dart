import 'package:sqflite/sqflite.dart';

Future onCreate(Database db) async {
  await db.execute("""CREATE TABLE read(
        id INTEGER PRIMARY KEY,
        manga TEXT,
        chapter TEXT,
        UNIQUE(manga, chapter)
      )
    """);
}
