import 'package:flutter/foundation.dart';
  import 'package:url_launcher/url_launcher.dart';
  import 'package:permission_handler/permission_handler.dart';

  class SmsService {
    /// Envoyer un SMS par voix (ouvre l'app SMS native)
    /// Commande : "Envoie un message à Jean je suis en route"
    Future<SmsResult> sendSms({
      required String phoneNumber,
      required String contactName,
      required String message,
    }) async {
      try {
        final cleanNumber = _toInternational(phoneNumber);

        // Ouvre l'app SMS native avec numéro et message pré-remplis
        final uri = Uri(
          scheme: 'sms',
          path: cleanNumber,
          queryParameters: {'body': message},
        );

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
          debugPrint('SMS ouvert pour $contactName ($cleanNumber)');
          return SmsResult.success('Application SMS ouverte pour $contactName');
        } else {
          return SmsResult.failure("Impossible d'ouvrir l'application SMS");
        }
      } catch (e) {
        debugPrint('SmsService.sendSms error: $e');
        return SmsResult.failure('Erreur envoi SMS: $e');
      }
    }

    /// Lire les derniers SMS reçus (non supporté sans package natif)
    Future<List<Map<String, String>>> getRecentSms({int limit = 5}) async {
      return [];
    }

    /// Formater les SMS pour la lecture vocale
    String formatSmsForSpeech(List<Map<String, String>> messages, String lang) {
      if (messages.isEmpty) {
        return lang == 'fr' ? 'Aucun nouveau message' : 'No new messages';
      }
      final count = messages.length;
      final intro = lang == 'fr'
          ? '$count nouveau${count > 1 ? "x" : ""} message${count > 1 ? "s" : ""}. '
          : '$count new message${count > 1 ? "s" : ""}. ';
      final readings = messages.take(3).map((sms) {
        final sender = sms['address'] ?? 'Inconnu';
        final body = sms['body'] ?? '';
        return lang == 'fr' ? 'De $sender: $body' : 'From $sender: $body';
      }).join('. ');
      return intro + readings;
    }

    /// Convertir numéro local en format international
    String _toInternational(String number) {
      String clean = number.replaceAll(RegExp(r'[\s\-\.\(\)]'), '');
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
  