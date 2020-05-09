import 'package:sqflite/sqflite.dart';


Future onCreate(Database db) async {
  // When creating the db, create the table
  await db.execute(
    """CREATE TABLE read(
        id INTEGER PRIMARY KEY,
        manga TEXT,
        chapter TEXT,
        UNIQUE(manga, chapter)
      )
    """
  );
}
