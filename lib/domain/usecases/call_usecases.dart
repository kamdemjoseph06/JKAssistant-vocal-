import 'package:flutter/foundation.dart';
import '../../data/repositories/call_repository.dart';
import '../../data/repositories/contact_repository.dart';
import '../../data/database/app_database.dart';

// ── Résultat d'un UseCase ──────────────────────────────────
class UseCaseResult<T> {
  final bool success;
  final T? data;
  final String? errorMessage;

  const UseCaseResult.success(this.data)
      : success = true,
        errorMessage = null;

  const UseCaseResult.failure(this.errorMessage)
      : success = false,
        data = null;
}

// ── UseCase: Lancer un appel depuis un nom prononcé ────────
class MakeCallUseCase {
  final ContactRepository _contactRepo;
  final CallRepository _callRepo;

  MakeCallUseCase(this._contactRepo, this._callRepo);

  Future<UseCaseResult<String>> execute({
    required String spokenName,
    required String triggeredBy,
  }) async {
    try {
      final contact = await _contactRepo.findContact(spokenName);

      if (contact == null) {
        return UseCaseResult.failure('Contact "$spokenName" introuvable');
      }

      final success = await _callRepo.makeCall(
        phoneNumber: contact.phoneNumber,
        contactName: contact.displayName,
        triggeredBy: triggeredBy,
      );

      if (!success) {
        return UseCaseResult.failure('Impossible de lancer l\'appel');
      }

      return UseCaseResult.success(contact.displayName);
    } catch (e) {
      debugPrint('❌ MakeCallUseCase error: $e');
      return UseCaseResult.failure('Erreur inattendue: $e');
    }
  }
}

// ── UseCase: Synchroniser les contacts ────────────────────
class SyncContactsUseCase {
  final ContactRepository _contactRepo;

  SyncContactsUseCase(this._contactRepo);

  Future<UseCaseResult<int>> execute() async {
    try {
      final count = await _contactRepo.syncContacts();
      return UseCaseResult.success(count);
    } catch (e) {
      debugPrint('❌ SyncContactsUseCase error: $e');
      return UseCaseResult.failure('Erreur synchronisation contacts: $e');
    }
  }
}

// ── UseCase: Chercher un contact ───────────────────────────
class FindContactUseCase {
  final ContactRepository _contactRepo;

  FindContactUseCase(this._contactRepo);

  Future<UseCaseResult<ContactsCacheTableData>> execute(
      String spokenName) async {
    try {
      final contact = await _contactRepo.findContact(spokenName);
      if (contact == null) {
        return UseCaseResult.failure('Introuvable');
      }
      return UseCaseResult.success(contact);
    } catch (e) {
      return UseCaseResult.failure('$e');
    }
  }
}
