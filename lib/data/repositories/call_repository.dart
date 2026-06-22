import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database/app_database.dart';

class CallRepository {
  final AppDatabase _db;

  CallRepository(this._db);

  /// Lancer un appel vers un numéro
  Future<bool> makeCall({
    required String phoneNumber,
    required String contactName,
    required String triggeredBy,
  }) async {
    try {
      final uri = Uri.parse('tel:$phoneNumber');

      if (!await canLaunchUrl(uri)) {
        debugPrint('❌ Impossible de lancer tel: sur cet appareil');
        return false;
      }

      await launchUrl(uri);

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

  Future<List<CallHistoryTableData>> getHistory({int limit = 50}) =>
      _db.callHistoryDao.getRecentCalls(limit);

  Future<void> clearHistory() => _db.callHistoryDao.clearHistory();

  Future<void> logIncomingCall({
    required String contactName,
    required String phoneNumber,
    required String callType,
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
