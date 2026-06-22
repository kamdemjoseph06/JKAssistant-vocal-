import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/call_history_table.dart';
import 'tables/contacts_cache_table.dart';
import 'tables/voice_commands_table.dart';
import 'daos/call_history_dao.dart';
import 'daos/contacts_dao.dart';
import 'daos/voice_commands_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [CallHistoryTable, ContactsCacheTable, VoiceCommandsTable],
  daos: [CallHistoryDao, ContactsDao, VoiceCommandsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      // Insérer commandes vocales par défaut FR + EN
      await _insertDefaultCommands();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // ⚠️ ERRORS_LOG: Toujours incrémenter schemaVersion ici
      // lors d'une migration, jamais modifier onCreate directement
    },
  );

  Future<void> _insertDefaultCommands() async {
    final commands = [
      // Français
      VoiceCommandsTableCompanion.insert(
        pattern: 'appelle %',
        action: 'CALL',
        language: 'fr',
      ),
      VoiceCommandsTableCompanion.insert(
        pattern: 'décroche',
        action: 'ANSWER',
        language: 'fr',
      ),
      VoiceCommandsTableCompanion.insert(
        pattern: 'raccroche',
        action: 'HANGUP',
        language: 'fr',
      ),
      VoiceCommandsTableCompanion.insert(
        pattern: 'qui appelle',
        action: 'WHO_CALLING',
        language: 'fr',
      ),
      // English
      VoiceCommandsTableCompanion.insert(
        pattern: 'call %',
        action: 'CALL',
        language: 'en',
      ),
      VoiceCommandsTableCompanion.insert(
        pattern: 'answer',
        action: 'ANSWER',
        language: 'en',
      ),
      VoiceCommandsTableCompanion.insert(
        pattern: 'hang up',
        action: 'HANGUP',
        language: 'en',
      ),
      VoiceCommandsTableCompanion.insert(
        pattern: 'who is calling',
        action: 'WHO_CALLING',
        language: 'en',
      ),
    ];

    for (final cmd in commands) {
      await into(voiceCommandsTable).insert(cmd);
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'vocal_assistant.db'));
    return NativeDatabase.createInBackground(file);
  });
}
