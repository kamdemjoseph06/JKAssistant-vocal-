import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {

  /// Envoyer un message WhatsApp par voix
  /// Commande : "Envoie un WhatsApp à Jean je suis en route"
  Future<WhatsAppResult> sendMessage({
    required String phoneNumber,
    required String contactName,
    required String message,
  }) async {
    try {
      // ⚠️ ERRORS_LOG: Numéro doit être au format international
      // sans espaces ni tirets : +33612345678
      final cleanNumber = _toInternational(phoneNumber);

      // URL scheme WhatsApp officielle
      final encodedMsg = Uri.encodeComponent(message);
      final uri = Uri.parse(
        'https://wa.me/$cleanNumber?text=$encodedMsg',
      );

      if (!await canLaunchUrl(uri)) {
        return WhatsAppResult.failure(
          'WhatsApp non installé sur cet appareil',
        );
      }

      await launchUrl(uri, mode: LaunchMode.externalApplication);
      debugPrint('✅ WhatsApp ouvert pour $contactName');
      return WhatsAppResult.success('WhatsApp ouvert pour $contactName');
    } catch (e) {
      debugPrint('❌ WhatsAppService.sendMessage error: $e');
      return WhatsAppResult.failure('Erreur WhatsApp: $e');
    }
  }

  /// Lancer un appel WhatsApp par voix
  /// Commande : "Appel WhatsApp à maman"
  Future<WhatsAppResult> makeCall({
    required String phoneNumber,
    required String contactName,
  }) async {
    try {
      final cleanNumber = _toInternational(phoneNumber);

      // URL scheme pour appel WhatsApp direct
      // ⚠️ ERRORS_LOG: whatsapp://call ne fonctionne pas sur tous les appareils
      // Utiliser l'API WhatsApp Business ou ouvrir le chat comme fallback
      final uri = Uri.parse('https://wa.me/$cleanNumber');

      if (!await canLaunchUrl(uri)) {
        return WhatsAppResult.failure('WhatsApp non installé');
      }

      await launchUrl(uri, mode: LaunchMode.externalApplication);
      debugPrint('✅ WhatsApp appel lancé pour $contactName');
      return WhatsAppResult.success(contactName);
    } catch (e) {
      debugPrint('❌ WhatsAppService.makeCall error: $e');
      return WhatsAppResult.failure('Erreur appel WhatsApp: $e');
    }
  }

  /// Convertir numéro local en international
  String _toInternational(String number) {
    // Nettoyer
    String clean = number.replaceAll(RegExp(r'[\s\-\.\(\)]'), '');

    // France : 06... → +336...
    if (clean.startsWith('0') && clean.length == 10) {
      clean = '+33${clean.substring(1)}';
    }
    // Déjà international
    if (!clean.startsWith('+')) {
      clean = '+$clean';
    }
    return clean;
  }
}

class WhatsAppResult {
  final bool success;
  final String message;
  const WhatsAppResult.success(this.message) : success = true;
  const WhatsAppResult.failure(this.message) : success = false;
}
