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
      // [FIX E022] wa.me requiert le numéro SANS + mais en format international
      final cleanNumber = _toInternationalNoPlus(phoneNumber);

      final encodedMsg = Uri.encodeComponent(message);
      final uri = Uri.parse(
        'https://wa.me/$cleanNumber?text=$encodedMsg',
      );

      // [FIX E021] Toujours vérifier canLaunchUrl avant launchUrl
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
      // [FIX E022] wa.me requiert numéro sans +
      final cleanNumber = _toInternationalNoPlus(phoneNumber);

      final uri = Uri.parse('https://wa.me/$cleanNumber');

      // [FIX E021] Toujours vérifier canLaunchUrl
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

  /// Convertir numéro local en international SANS le signe +
  /// wa.me requiert : 33612345678 (pas +33612345678)
  String _toInternationalNoPlus(String number) {
    // Nettoyer tous les séparateurs
    String clean = number.replaceAll(RegExp(r'[\s\-\.\(\)\+]'), '');

    // France : 06... ou 07... → 336... ou 337...
    if (clean.startsWith('0') && clean.length == 10) {
      clean = '33${clean.substring(1)}';
    }
    // Si déjà en format international avec indicatif (ex: 33612...)
    // ne pas ajouter de préfixe
    return clean;
  }
}

class WhatsAppResult {
  final bool success;
  final String message;
  const WhatsAppResult.success(this.message) : success = true;
  const WhatsAppResult.failure(this.message) : success = false;
}
