import 'package:sqflite/sqflite.dart';

Future<void> upgradeTo003(Database db) async {
  await db.execute("""ALTER TABLE read ADD ts INTEGER
    """);
  final ts = DateTime.now().millisecondsSinceEpoch;
  await db.update('read', {'ts': ts}, where: 'source IS NULL');

  await db.execute("""CREATE TABLE manga(
        id INTEGER PRIMARY KEY,
        source TEXT,
        manga TEXT,
        name TEXT,
        UNIQUE(source, manga)
      )
    """);
}
