import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../database/app_database.dart';

class ContactRepository {
  final AppDatabase _db;

  ContactRepository(this._db);

  Future<int> syncContacts() async {
    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      final rows = <ContactsCacheTableCompanion>[];

      for (final contact in contacts) {
        for (final phone in contact.phones) {
          rows.add(ContactsCacheTableCompanion.insert(
            contactId: contact.id,
            displayName: contact.displayName,
            normalizedName: _normalize(contact.displayName),
            phoneNumber: _cleanPhone(phone.number),
            phoneLabel: Value(phone.label.name),
            cachedAt: DateTime.now(),
          ));
        }
      }

      await _db.contactsDao.refreshCache(rows);
      debugPrint('✅ ContactRepository: ${rows.length} numéros synchronisés');
      return rows.length;
    } catch (e) {
      debugPrint('❌ ContactRepository.syncContacts error: $e');
      rethrow;
    }
  }

  Future<ContactsCacheTableData?> findContact(String spokenName) async {
    final contact = await _db.contactsDao.findBestMatch(spokenName);
    if (contact == null) {
      debugPrint('⚠️ Aucun contact trouvé pour: "$spokenName"');
    } else {
      debugPrint('✅ Contact trouvé: ${contact.displayName} → ${contact.phoneNumber}');
    }
    return contact;
  }

  Future<int> getCachedCount() => _db.contactsDao.count();

  String _cleanPhone(String raw) {
    return raw.replaceAll(RegExp(r'[\s\-\.\(\)]'), '');
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
