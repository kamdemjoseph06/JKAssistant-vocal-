import 'package:flutter/foundation.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsService {
  /// Envoyer un SMS par voix
  /// Commande : "Envoie un message à Jean je suis en route"
  Future<SmsResult> sendSms({
    required String phoneNumber,
    required String contactName,
    required String message,
  }) async {
    try {
      // [FIX E019] Demander la permission SMS au runtime avant envoi
      final status = await Permission.sms.request();
      if (!status.isGranted) {
        return SmsResult.failure('Permission SMS refusée. Activez-la dans les paramètres.');
      }

      // [FIX E020] Convertir en format international avant envoi
      final cleanNumber = _toInternational(phoneNumber);

      final result = await sendSMS(
        message: message,
        recipients: [cleanNumber],
      );

      debugPrint('📤 SMS status: $result');
      debugPrint('✅ SMS envoyé à $contactName ($cleanNumber): "$message"');
      return SmsResult.success('SMS envoyé à $contactName');
    } catch (e) {
      debugPrint('❌ SmsService.sendSms error: $e');
      return SmsResult.failure('Erreur envoi SMS: $e');
    }
  }

  /// Lire les derniers SMS reçus (non supporté par flutter_sms)
  Future<List<Map<String, String>>> getRecentSms({int limit = 5}) async {
    debugPrint('ℹ️ Lecture SMS non disponible avec flutter_sms');
    return [];
  }

  /// Formater les SMS pour la lecture vocale
  String formatSmsForSpeech(List<Map<String, String>> messages, String lang) {
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
      final sender = sms['address'] ?? 'Inconnu';
      final body = sms['body'] ?? '';
      return lang == 'fr'
          ? 'De $sender: $body'
          : 'From $sender: $body';
    }).join('. ');

    return intro + readings;
  }

  /// Convertir numéro local en format international
  String _toInternational(String number) {
    String clean = number.replaceAll(RegExp(r'[\s\-\.\(\)]'), '');
    // France : 06... ou 07... → +336... ou +337...
    if (clean.startsWith('0') && clean.length == 10) {
      clean = '+33${clean.substring(1)}';
    }
    if (!clean.startsWith('+')) {
      clean = '+$clean';
    }
    return clean;
  }
}

class SmsResult {
  final bool success;
  final String message;

  const SmsResult.success(this.message) : success = true;
  const SmsResult.failure(this.message) : success = false;
}
