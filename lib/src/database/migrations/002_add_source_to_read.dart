import 'package:sqflite/sqflite.dart';


Future<void> upgradeTo002(Database db) async {
  // When creating the db, create the table
  await db.execute(
    """ALTER TABLE read ADD source TEXT
    """
  );
  await db.update(
    'read',
    {'source': 'MangaTown'},
    where: 'source IS NULL'
  );
}
