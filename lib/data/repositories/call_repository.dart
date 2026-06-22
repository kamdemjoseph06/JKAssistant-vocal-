import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database/app_database.dart';
import '../database/tables/call_history_table.dart';

class CallRepository {
  final AppDatabase _db;

  CallRepository(this._db);

  /// Lancer un appel vers un numéro
  Future<bool> makeCall({
    required String phoneNumber,
    required String contactName,
    required String triggeredBy, // 'VOICE' ou 'MANUAL'
  }) async {
    try {
      // ⚠️ ERRORS_LOG: Sur Android 26+, utiliser tel: et non telprompt:
      // telprompt: ouvre une boîte de dialogue de confirmation
      final uri = Uri.parse('tel:$phoneNumber');

      if (!await canLaunchUrl(uri)) {
        debugPrint('❌ Impossible de lancer tel: sur cet appareil');
        return false;
      }

      await launchUrl(uri);

      // Sauvegarder dans l'historique SQL
      await _db.callHistoryDao.insertCall(
        CallHistoryTableCompanion.insert(
          contactName: contactName,
          phoneNumber: phoneNumber,
          callType: 'OUTGOING',
          triggeredBy: triggeredBy,
          calledAt: DateTime.now(),
        ),
      );

      debugPrint('📞 Appel lancé: $contactName ($phoneNumber)');
      return true;
    } catch (e) {
      debugPrint('❌ CallRepository.makeCall error: $e');
      return false;
    }
  }

  /// Récupérer l'historique des appels
  Future<List<CallHistoryTableData>> getHistory({int limit = 50}) =>
      _db.callHistoryDao.getRecentCalls(limit);

  /// Effacer l'historique
  Future<void> clearHistory() => _db.callHistoryDao.clearHistory();

  /// Enregistrer un appel entrant répondu ou manqué
  Future<void> logIncomingCall({
    required String contactName,
    required String phoneNumber,
    required String callType, // 'INCOMING' | 'MISSED'
    required int durationSeconds,
  }) async {
    await _db.callHistoryDao.insertCall(
      CallHistoryTableCompanion.insert(
        contactName: contactName,
        phoneNumber: phoneNumber,
        callType: callType,
        triggeredBy: 'SYSTEM',
        durationSeconds: Value(durationSeconds),
        calledAt: DateTime.now(),
      ),
    );
  }
}
