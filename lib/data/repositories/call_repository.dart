import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database/app_database.dart';

class CallRepository {
  final AppDatabase _db;

  // Canal natif pour ACTION_CALL (appel direct, sans ouvrir le composeur)
  static const _callChannel = MethodChannel('com.jkassistant.vocal/call');

  CallRepository(this._db);

  /// Lancer un appel vocal direct.
  ///
  /// Stratégie :
  ///   1. MethodChannel → Intent.ACTION_CALL (appel immédiat avec CALL_PHONE)
  ///   2. Fallback       → url_launcher "tel:" (ouvre le composeur si le canal échoue)
  Future<bool> makeCall({
    required String phoneNumber,
    required String contactName,
    required String triggeredBy,
  }) async {
    bool called = false;

    // ── Tentative 1 : appel direct via MethodChannel (pas de bouton à presser) ──
    try {
      called = await _callChannel.invokeMethod<bool>('makeCall', phoneNumber) ?? false;
      if (called) {
        debugPrint('📞 Appel direct (ACTION_CALL): $contactName ($phoneNumber)');
      }
    } on PlatformException catch (e) {
      debugPrint('⚠️ MethodChannel makeCall échoué (${e.code}): ${e.message}');
      called = false;
    } catch (e) {
      debugPrint('⚠️ MethodChannel makeCall erreur inattendue: $e');
      called = false;
    }

    // ── Fallback : url_launcher tel: (ouvre le composeur) ──────────────────────
    if (!called) {
      try {
        final uri = Uri.parse('tel:$phoneNumber');
        if (!await canLaunchUrl(uri)) {
          debugPrint('❌ Impossible de lancer tel: sur cet appareil');
          return false;
        }
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        called = true;
        debugPrint('📞 Appel via url_launcher (fallback): $contactName ($phoneNumber)');
      } catch (e) {
        debugPrint('❌ CallRepository.makeCall url_launcher error: $e');
        return false;
      }
    }

    // ── Enregistrer dans l'historique ──────────────────────────────────────────
    if (called) {
      try {
        await _db.callHistoryDao.insertCall(
          CallHistoryTableCompanion.insert(
            contactName: contactName,
            phoneNumber: phoneNumber,
            callType: 'OUTGOING',
            triggeredBy: triggeredBy,
            calledAt: DateTime.now(),
          ),
        );
      } catch (e) {
        debugPrint('⚠️ Erreur enregistrement historique appel: $e');
      }
    }

    return called;
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
