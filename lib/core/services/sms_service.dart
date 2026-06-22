import 'package:flutter/foundation.dart';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsService {
  final Telephony _telephony = Telephony.instance;

  /// Envoyer un SMS par voix
  /// Commande : "Envoie un message à Jean je suis en route"
  Future<SmsResult> sendSms({
    required String phoneNumber,
    required String contactName,
    required String message,
  }) async {
    try {
      // ⚠️ ERRORS_LOG: Vérifier permission SEND_SMS avant envoi
      final granted = await Permission.sms.isGranted;
      if (!granted) {
        return SmsResult.failure('Permission SMS refusée');
      }

      await _telephony.sendSms(
        to: phoneNumber,
        message: message,
        statusListener: (SendStatus status) {
          debugPrint('📤 SMS status: $status');
        },
      );

      debugPrint('✅ SMS envoyé à $contactName: "$message"');
      return SmsResult.success('SMS envoyé à $contactName');
    } catch (e) {
      debugPrint('❌ SmsService.sendSms error: $e');
      return SmsResult.failure('Erreur envoi SMS: $e');
    }
  }

  /// Lire les derniers SMS reçus
  /// Commande : "Lis mes messages" / "Nouveaux SMS"
  Future<List<SmsMessage>> getRecentSms({int limit = 5}) async {
    try {
      final granted = await Permission.sms.isGranted;
      if (!granted) return [];

      final messages = await _telephony.getInboxSms(
        columns: [
          SmsColumn.ADDRESS,
          SmsColumn.BODY,
          SmsColumn.DATE,
          SmsColumn.READ,
        ],
        filter: SmsFilter.where(SmsColumn.READ).equals('0'), // Non lus
        sortOrder: [
          OrderBy(SmsColumn.DATE, sort: Sort.DESC),
        ],
      );

      return messages.take(limit).toList();
    } catch (e) {
      debugPrint('❌ SmsService.getRecentSms error: $e');
      return [];
    }
  }

  /// Formater les SMS pour la lecture vocale
  String formatSmsForSpeech(List<SmsMessage> messages, String lang) {
    if (messages.isEmpty) {
      return lang == 'fr'
          ? 'Aucun nouveau message'
          : 'No new messages';
    }

    final count = messages.length;
    final intro = lang == 'fr'
        ? '$count nouveau${count > 1 ? 'x' : ''} message${count > 1 ? 's' : ''}. '
        : '$count new message${count > 1 ? 's' : ''}. ';

    final readings = messages.take(3).map((sms) {
      final sender = sms.address ?? 'Inconnu';
      final body = sms.body ?? '';
      return lang == 'fr'
          ? 'De $sender: $body'
          : 'From $sender: $body';
    }).join('. ');

    return intro + readings;
  }
}

class SmsResult {
  final bool success;
  final String message;

  const SmsResult.success(this.message) : success = true;
  const SmsResult.failure(this.message) : success = false;
}
