import 'package:flutter_test/flutter_test.dart';
import 'package:vocal_assistant/core/voice/command_parser.dart';
import 'package:vocal_assistant/core/voice/intent_recognizer.dart';

void main() {
  late CommandParser parser;

  setUp(() {
    parser = CommandParser();
  });

  group('📞 Appels — FR', () {
    final callPhrases = [
      'appelle Jean', 'appeler maman', 'téléphone à papa', 'contacte Marie',
      'joins Pierre', 'compose le numéro de Sophie', 'passe-moi Jean',
      'je voudrais appeler Jean', 'peux-tu appeler maman', 'je veux joindre papa',
      'essaie de contacter Marie', 'lance un appel à Pierre',
      'apelle Jean', 'appelé maman', 'telephoner papa',
    ];
    for (final phrase in callPhrases) {
      test('"$phrase" → CALL', () {
        final cmd = parser.parse(phrase);
        expect(cmd.action, CommandAction.call,
            reason: '"$phrase" devrait être reconnu comme CALL');
        expect(cmd.confidence, greaterThan(0.5),
            reason: 'Confidence trop basse pour "$phrase"');
      });
    }
  });

  group('📞 Appels — EN', () {
    final callPhrases = [
      'call John', 'phone mom', 'dial dad', 'ring Sophie',
      'can you call John', 'i want to call mom', 'please call dad',
      'try to reach Marie', 'connect me to Pierre',
      'put me through to Sophie', 'let me speak to John',
    ];
    for (final phrase in callPhrases) {
      test('"$phrase" → CALL', () {
        final cmd = parser.parse(phrase);
        expect(cmd.action, CommandAction.call);
      });
    }
  });

  group('✅ Décrocher — FR', () {
    final answerPhrases = [
      'décroche', 'décrocher', 'réponds', 'accepte l appel',
      'prends l appel', 'je veux décrocher', 'oui décroche',
      'ouvre la ligne', 'decroche', 'repondre',
    ];
    for (final phrase in answerPhrases) {
      test('"$phrase" → ANSWER', () {
        final cmd = parser.parse(phrase);
        expect(cmd.action, CommandAction.answer);
      });
    }
  });

  group('📵 Raccrocher — FR', () {
    final hangupPhrases = [
      'raccroche', 'raccrocher', 'termine l appel', 'coupe la communication',
      'ferme la ligne', 'mettre fin à l appel', 'je raccroche',
      'c est bon au revoir', 'fin d appel', 'racroche', 'terminer appel',
    ];
    for (final phrase in hangupPhrases) {
      test('"$phrase" → HANGUP', () {
        final cmd = parser.parse(phrase);
        expect(cmd.action, CommandAction.hangup);
      });
    }
  });

  group('📱 SMS — FR', () {
    test('Envoi SMS simple', () {
      final cmd = parser.parse('envoie un SMS à Jean je suis en route');
      expect(cmd.action, CommandAction.sendSms);
      expect(cmd.contactName, isNotNull);
      expect(cmd.messageText, isNotNull);
    });
    test('Envoi SMS naturel', () {
      final cmd = parser.parse('dis à maman que j arrive dans 10 minutes');
      expect(cmd.action, CommandAction.sendSms);
    });
    test('Envoi SMS informatif', () {
      final cmd = parser.parse('préviens papa je serai en retard');
      expect(cmd.action, CommandAction.sendSms);
    });
    test('Lecture SMS', () {
      final cmd = parser.parse('lis mes messages');
      expect(cmd.action, CommandAction.readSms);
    });
    test('Lecture SMS naturelle', () {
      final cmd = parser.parse('est-ce que j ai de nouveaux messages');
      expect(cmd.action, CommandAction.readSms);
    });
    test('Vérification SMS', () {
      final cmd = parser.parse('qui m a écrit');
      expect(cmd.action, CommandAction.readSms);
    });
  });

  group('💬 WhatsApp — FR', () {
    test('Message WhatsApp', () {
      final cmd = parser.parse('envoie un whatsapp à Jean bonjour');
      expect(cmd.action, CommandAction.whatsappMessage);
    });
    test('Message WhatsApp variante phonétique', () {
      final cmd = parser.parse('envoie un watsap à maman j arrive');
      expect(cmd.action, CommandAction.whatsappMessage);
    });
    test('Appel WhatsApp', () {
      final cmd = parser.parse('appel whatsapp à papa');
      expect(cmd.action, CommandAction.whatsappCall);
    });
    test('Appel vidéo', () {
      final cmd = parser.parse('lance un appel video avec Jean');
      expect(cmd.action, CommandAction.whatsappCall);
    });
  });

  group('⏰ Réveil — FR', () {
    test('Réveil simple', () {
      final cmd = parser.parse('réveille-moi à 7 heures');
      expect(cmd.action, CommandAction.setAlarm);
      expect(cmd.timeText, isNotNull);
    });
    test('Réveil naturel', () {
      final cmd = parser.parse('je dois me lever à 8h30 demain');
      expect(cmd.action, CommandAction.setAlarm);
    });
    test('Minuterie', () {
      final cmd = parser.parse('minuterie 5 minutes');
      expect(cmd.action, CommandAction.setTimer);
    });
    test('Timer naturel', () {
      final cmd = parser.parse('lance un timer de 30 secondes');
      expect(cmd.action, CommandAction.setTimer);
    });
    test('Annuler alarme', () {
      final cmd = parser.parse('annule le réveil');
      expect(cmd.action, CommandAction.cancelAlarm);
    });
    test('Supprimer timer', () {
      final cmd = parser.parse('supprime la minuterie');
      expect(cmd.action, CommandAction.cancelAlarm);
    });
  });

  group('🚗 Mode voiture — FR', () {
    test('Activer mode voiture', () {
      final cmd = parser.parse('mode voiture');
      expect(cmd.action, CommandAction.carModeOn);
    });
    test('Je conduis', () {
      final cmd = parser.parse('je conduis');
      expect(cmd.action, CommandAction.carModeOn);
    });
    test('Je prends la route', () {
      final cmd = parser.parse('je prends la route');
      expect(cmd.action, CommandAction.carModeOn);
    });
    test('Désactiver mode voiture', () {
      final cmd = parser.parse('je suis arrivé');
      expect(cmd.action, CommandAction.carModeOff);
    });
    test('Fin de trajet', () {
      final cmd = parser.parse('fin de trajet');
      expect(cmd.action, CommandAction.carModeOff);
    });
  });

  group('🔤 Tolérance aux fautes de prononciation', () {
    test('apelle → appelle (1 faute)', () {
      final cmd = parser.parse('apelle Jean');
      expect(cmd.action, CommandAction.call);
    });
    test('racroche → raccroche (1 faute)', () {
      final cmd = parser.parse('racroche');
      expect(cmd.action, CommandAction.hangup);
    });
    test('decroche → décroche (accent manquant)', () {
      final cmd = parser.parse('decroche');
      expect(cmd.action, CommandAction.answer);
    });
    test('telefone → téléphone (faute phonétique)', () {
      final cmd = parser.parse('telefone papa');
      expect(cmd.action, CommandAction.call);
    });
  });

  group('🎯 Extraction d\'entités', () {
    test('Extraire le contact d\'un appel', () {
      final cmd = parser.parse('appelle Jean');
      expect(cmd.contactName?.toLowerCase(), contains('jean'));
    });
    test('Extraire contact dans phrase longue', () {
      final cmd = parser.parse('je voudrais appeler mon ami Jean s il te plait');
      expect(cmd.contactName?.toLowerCase(), contains('jean'));
    });
    test('Extraire contact et message SMS', () {
      final cmd = parser.parse('envoie un message à Marie je suis en route');
      expect(cmd.contactName?.toLowerCase(), contains('marie'));
      expect(cmd.messageText, isNotNull);
    });
    test('Extraire heure réveil', () {
      final cmd = parser.parse('réveille-moi à 7 heures 30');
      expect(cmd.timeText, isNotNull);
    });
    test('Extraire durée timer', () {
      final cmd = parser.parse('lance un timer de 5 minutes');
      expect(cmd.timeText, isNotNull);
    });
  });

  group('❌ Commandes non reconnues', () {
    test('Phrase vide → unknown', () {
      final cmd = parser.parse('');
      expect(cmd.action, CommandAction.unknown);
    });
    test('Phrase hors sujet → unknown', () {
      final cmd = parser.parse('quelle heure est-il');
      expect(cmd.action, CommandAction.unknown);
    });
    test('Bruit → unknown', () {
      final cmd = parser.parse('euh hm');
      expect(cmd.action, CommandAction.unknown);
    });
  });

  group('📏 Distance Levenshtein', () {
    test('Mots identiques → distance 0', () {
      IntentRecognizer();
      final cmd = parser.parse('appelle Jean');
      expect(cmd.confidence, greaterThan(0.9));
    });
  });
}
