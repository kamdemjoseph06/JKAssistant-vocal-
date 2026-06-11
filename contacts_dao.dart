import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/contacts_cache_table.dart';

part 'contacts_dao.g.dart';
part 'voice_commands_dao.g.dart';

@DriftAccessor(tables: [ContactsCacheTable])
class ContactsDao extends DatabaseAccessor<AppDatabase>
    with _$ContactsDaoMixin {
  ContactsDao(super.db);

  /// Chercher un contact par nom normalisé (sans accents, minuscule)
  Future<List<ContactsCacheTableData>> searchByName(String name) {
    final normalized = _normalize(name);
    return (select(contactsCacheTable)
          ..where((t) => t.normalizedName.like('%$normalized%')))
        .get();
  }

  /// Chercher correspondance exacte ou la plus proche
  Future<ContactsCacheTableData?> findBestMatch(String spokenName) async {
    final normalized = _normalize(spokenName);
    final results = await searchByName(normalized);
    if (results.isEmpty) return null;
    // Retourne la correspondance la plus courte (la plus précise)
    results.sort((a, b) =>
        a.normalizedName.length.compareTo(b.normalizedName.length));
    return results.first;
  }

  /// Mettre à jour le cache complet des contacts
  Future<void> refreshCache(
      List<ContactsCacheTableCompanion> contacts) async {
    await transaction(() async {
      await delete(contactsCacheTable).go();
      await batch((b) {
        b.insertAll(contactsCacheTable, contacts);
      });
    });
  }

  /// Nombre de contacts en cache
  Future<int> count() async {
    final count = contactsCacheTable.id.count();
    final query = selectOnly(contactsCacheTable)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .trim();
  }
}

@DriftAccessor(tables: [VoiceCommandsTable])
class VoiceCommandsDao extends DatabaseAccessor<AppDatabase>
    with _$VoiceCommandsDaoMixin {
  VoiceCommandsDao(super.db);

  /// Récupérer toutes les commandes actives pour une langue
  Future<List<VoiceCommandsTableData>> getCommandsForLanguage(
          String language) =>
      (select(voiceCommandsTable)
            ..where((t) =>
                t.language.equals(language) & t.isActive.equals(true)))
          .get();

  /// Récupérer toutes les commandes actives (FR + EN)
  Future<List<VoiceCommandsTableData>> getAllActiveCommands() =>
      (select(voiceCommandsTable)
            ..where((t) => t.isActive.equals(true)))
          .get();
}
