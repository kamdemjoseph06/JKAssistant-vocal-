import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/call_history_table.dart';
import 'tables/contacts_cache_table.dart';
import 'daos/call_history_dao.dart';
import 'daos/contacts_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [CallHistoryTable, ContactsCacheTable],
  daos: [CallHistoryDao, ContactsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {},
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'vocal_assistant.db'));
    return NativeDatabase.createInBackground(file);
  });
}
