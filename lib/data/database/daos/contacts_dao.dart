import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/contacts_cache_table.dart';

part 'contacts_dao.g.dart';

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
  /// [FIX] Recherche multi-étapes : exacte → partielle → mot par mot → longueur
  Future<ContactsCacheTableData?> findBestMatch(String spokenName) async {
    final normalized = _normalize(spokenName);

    // 1. Correspondance directe (contient le nom normalisé complet)
    var results = await searchByName(normalized);

    // 2. Si pas de résultat, chercher mot par mot (contacts composés)
    if (results.isEmpty) {
      final words = normalized.split(' ').where((w) => w.length > 2).toList();
      for (final word in words) {
        final partial = await searchByName(word);
        for (final r in partial) {
          if (!results.any((e) => e.contactId == r.contactId)) {
            results.add(r);
          }
        }
      }
    }

    if (results.isEmpty) return null;

    // Trier par score de pertinence (le plus pertinent en premier)
    results.sort((a, b) {
      final aScore = _matchScore(a.normalizedName, normalized);
      final bScore = _matchScore(b.normalizedName, normalized);
      return bScore.compareTo(aScore);
    });

    return results.first;
  }

  /// Score de pertinence entre un nom de contact et le nom prononcé (0.0–1.0)
  double _matchScore(String contactName, String spokenName) {
    if (contactName == spokenName) return 1.0;
    if (contactName.contains(spokenName)) return 0.9;
    if (spokenName.contains(contactName)) return 0.85;

    // Score par mots communs
    final cWords = contactName.split(' ').where((w) => w.length > 1).toList();
    final sWords = spokenName.split(' ').where((w) => w.length > 1).toList();
    if (sWords.isEmpty) return 0.0;

    int matches = 0;
    for (final sw in sWords) {
      for (final cw in cWords) {
        if (cw == sw || cw.contains(sw) || sw.contains(cw)) {
          matches++;
          break;
        }
      }
    }
    return matches / sWords.length * 0.7;
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
