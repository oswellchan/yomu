import 'package:sqflite/sqflite.dart';

Future<void> upgradeTo004(Database db) async {
  await db.execute("""ALTER TABLE manga ADD thumbnail TEXT
    """);
  await db.execute("""ALTER TABLE read ADD chapter_name TEXT
    """);
}
