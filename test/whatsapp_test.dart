// Test de la logique WhatsApp — sans Flutter (pur Dart)
// Vérifie que les commandes WhatsApp sont bien reconnues

import 'package:test/test.dart';
import 'package:vocal_assistant/core/voice/intent_recognizer.dart';
import 'package:vocal_assistant/core/voice/command_parser.dart';

void main() {
  group('WhatsApp Intent Recognition', () {
    final recognizer = IntentRecognizer();
    final parser = CommandParser();

    group('Messages WhatsApp FR', () {
      test('enregistre whatsapp jean je suis en route', () {
        final cmd = parser.parse('enregistre whatsapp jean je suis en route');
        // Note: "enregistre" n'est pas dans les verbes SMS — test de fallback
        expect(cmd.action, isNot(CommandAction.unknown));
      });

      test('envoie whatsapp jean message test', () {
        final intent = recognizer.recognize('envoie whatsapp jean message test');
        expect(intent.type, IntentType.whatsappMessage);
        expect(intent.contact, 'jean');
        expect(intent.message, 'message test');
      });

      test('whatsapp jean je suis en retard', () {
        final intent = recognizer.recognize('whatsapp jean je suis en retard');
        expect(intent.type, IntentType.whatsappMessage);
        expect(intent.contact, 'jean');
        expect(intent.message, 'je suis en retard');
      });

      test('envoie un whatsapp à marie le rendez-vous est reporté', () {
        final intent = recognizer.recognize(
            'envoie un whatsapp à marie le rendez-vous est reporté');
        expect(intent.type, IntentType.whatsappMessage);
        expect(intent.contact, 'marie');
        expect(intent.message, 'le rendez-vous est reporté');
      });

      test('watsap pierre on se voit demain', () {
        final intent = recognizer.recognize('watsap pierre on se voit demain');
        expect(intent.type, IntentType.whatsappMessage);
        expect(intent.contact, 'pierre');
      });
    });

    group('Appels WhatsApp FR', () {
      test('appel whatsapp maman', () {
        final intent = recognizer.recognize('appel whatsapp maman');
        expect(intent.type, IntentType.whatsappCall);
        expect(intent.contact, 'maman');
      });

      test('appelle sur whatsapp jean pierre', () {
        final intent = recognizer.recognize('appelle sur whatsapp jean pierre');
        expect(intent.type, IntentType.whatsappCall);
      });

      test('appel wa pierre', () {
        final intent = recognizer.recognize('appel wa pierre');
        expect(intent.type, IntentType.whatsappCall);
      });
    });

    group('WhatsApp EN', () {
      test('whatsapp john hello there', () {
        final intent = recognizer.recognize('whatsapp john hello there');
        expect(intent.type, IntentType.whatsappMessage);
        expect(intent.contact, 'john');
        expect(intent.message, 'hello there');
      });

      test('send on whatsapp marie i am running late', () {
        final intent = recognizer.recognize(
            'send on whatsapp marie i am running late');
        expect(intent.type, IntentType.whatsappMessage);
      });
    });

    group('Edge cases', () {
      test('confusion SMS vs WhatsApp — contient whatsapp', () {
        final intent = recognizer.recognize(
            'envoie un message sur whatsapp à paul salut');
        // Devrait être whatsappMessage, pas sendSms
        expect(intent.type, IntentType.whatsappMessage);
      });

      test('numéro de contact extrait correctement pour prénom composé', () {
        final intent = recognizer.recognize(
            'whatsapp jean pierre dis lui que je suis en retard');
        expect(intent.type, IntentType.whatsappMessage);
        expect(intent.contact, 'jean pierre');
        expect(intent.message, 'dis lui que je suis en retard');
      });
    });
  });
}
