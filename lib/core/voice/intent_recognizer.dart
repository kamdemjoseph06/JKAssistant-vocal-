import 'package:flutter/foundation.dart';

/// ══════════════════════════════════════════════════════════════
/// MOTEUR NLU OFFLINE — Compréhension du langage naturel
///
/// Combine 3 techniques :
///   1. Synonymes étendus     → variantes de verbes et formulations
///   2. Distance Levenshtein  → tolérance aux fautes / mauvaise prononciation
///   3. Extraction d'entités  → trouver le nom, le message, l'heure dans la phrase
/// ══════════════════════════════════════════════════════════════

enum IntentType {
  call, answer, hangup, whoCalling,
  sendSms, readSms,
  whatsappMessage, whatsappCall,
  setAlarm, setTimer, cancelAlarm,
  carModeOn, carModeOff,
  unknown,
}

class Intent {
  final IntentType type;
  final double confidence;   // 0.0 → 1.0
  final String? contact;
  final String? message;
  final String? time;
  final String language;

  const Intent({
    required this.type,
    required this.confidence,
    required this.language,
    this.contact,
    this.message,
    this.time,
  });

  bool get isValid => confidence >= 0.5;

  @override
  String toString() =>
      'Intent($type, conf: ${confidence.toStringAsFixed(2)}, '
      'contact: $contact, msg: $message, time: $time)';
}

// ══════════════════════════════════════════════════════════════
// DICTIONNAIRES DE SYNONYMES
// ══════════════════════════════════════════════════════════════

class _Synonyms {

  // ── Verbes d'appel FR ──────────────────────────────────────
  static const frCallVerbs = [
    'appelle', 'appeler', 'appel', 'appelles',
    'téléphone', 'telephoner', 'téléphoner',
    'contacte', 'contacter', 'contact',
    'joins', 'joindre', 'joint',
    'compose', 'composer',
    'passe', 'passer',
    'sonne', 'sonner',
    'coup de fil', 'coup de téléphone',
    'appeler au téléphone',
    'je veux appeler', 'je voudrais appeler',
    'peux-tu appeler', 'pouvez-vous appeler',
    'essaie d appeler', 'essaie de joindre',
    'met-moi en contact avec', 'mettre en contact',
    'fais-moi parler à', 'fais moi parler',
    'passe-moi', 'passe moi',
    'lance un appel', 'lance l appel',
    'établir une communication', 'établir le contact',
  ];

  // ── Verbes de décrochage FR ───────────────────────────────
  static const frAnswerVerbs = [
    'décroche', 'décrocher', 'décrochons',
    'réponds', 'répondre', 'répondons',
    'accepte', 'accepter', 'accept',
    'prends', 'prendre',
    'reçois', 'recevoir',
    'prend l appel', 'prends l appel',
    'oui je décroche', 'oui réponds',
    'ouvre la ligne', 'ouvre le canal',
    'je veux décrocher', 'je voudrais décrocher',
    'prendre l appel', 'accepter l appel',
    'répondre à l appel',
  ];

  // ── Verbes de raccrochage FR ──────────────────────────────
  static const frHangupVerbs = [
    'raccroche', 'raccrocher', 'raccroches',
    'coupe', 'couper', 'coupes',
    'termine', 'terminer', 'termines',
    'arrête', 'arrêter', 'arrete',
    'stoppe', 'stopper',
    'fin', 'fini', 'finis',
    'ferme', 'fermer',
    'quitte', 'quitter',
    'déconnecte', 'déconnecter',
    'au revoir', 'bye', 'bonne journée',
    'ferme la ligne', 'coupe la ligne',
    'mettre fin', 'mettre fin à l appel',
    'terminer la communication',
    'je veux raccrocher', 'je raccroche',
    'c est bon merci', 'ok merci au revoir',
  ];

  // ── Verbes d'envoi SMS FR ─────────────────────────────────
  static const frSmsVerbs = [
    'envoie', 'envoyer', 'envois', 'envoyer',
    'écris', 'écrire', 'écrit',
    'dis', 'dire', 'dit',
    'informe', 'informer',
    'préviens', 'prévenir',
    'notifie', 'notifier',
    'envoie un sms', 'envoie un message', 'envoie un texto',
    'écris un message', 'écrire un message',
    'envoie un texto', 'envoyer un texto',
    'peut-tu envoyer', 'peux-tu envoyer',
    'je veux envoyer un sms',
    'je voudrais envoyer un message',
    'envoie lui', 'envoie-lui', 'dis-lui',
  ];

  // ── Verbes lecture SMS FR ─────────────────────────────────
  static const frReadSmsVerbs = [
    'lis', 'lire', 'lit',
    'montre', 'montrer', 'affiche',
    'consulte', 'consulter',
    'vérifie', 'vérifier', 'vérifie mes messages',
    'mes messages', 'nouveaux messages',
    'j ai des messages', 'des sms',
    'quels sont mes messages', 'qui m a écrit',
    'lire mes sms', 'voir mes messages',
    'nouveaux sms', 'messages non lus',
  ];

  // ── WhatsApp FR ───────────────────────────────────────────
  static const frWhatsappVerbs = [
    'whatsapp', 'whatssap', 'watsap', 'watzap',  // variantes phonétiques
    'envoie un whatsapp', 'envoyer sur whatsapp',
    'message whatsapp', 'via whatsapp',
    'sur whatsapp', 'par whatsapp',
    'wattsap', 'whats app',
  ];

  static const frWhatsappCallVerbs = [
    'appel whatsapp', 'appelle sur whatsapp',
    'appel vidéo', 'appel video', 'appel vocal whatsapp',
    'vidéo call', 'video call',
    'appelle via whatsapp', 'appelle par whatsapp',
  ];

  // ── Réveil / Alarme FR ────────────────────────────────────
  static const frAlarmVerbs = [
    'réveille', 'réveille-moi', 'réveil',
    'alarme', 'alarme à',
    'mets une alarme', 'mets un réveil',
    'programme un réveil', 'programme une alarme',
    'crée une alarme', 'crée un réveil',
    'pose une alarme', 'pose un réveil',
    'je veux un réveil', 'je voudrais un réveil',
    'je dois me lever', 'lève-moi',
    'wake up', 'réveille moi',
  ];

  // ── Timer / Minuterie FR ──────────────────────────────────
  static const frTimerVerbs = [
    'minuterie', 'minuteur', 'timer',
    'chrono', 'chronomètre', 'compte à rebours',
    'dans', 'dans combien', 'dans exactement',
    'lance un timer', 'lance une minuterie',
    'mets un timer', 'programme un timer',
    'je veux un timer', 'met le minuteur',
    'commence à compter', 'lance le compte',
  ];

  // ── Mode voiture FR ───────────────────────────────────────
  static const frCarModeOnVerbs = [
    'mode voiture', 'conduite', 'je conduis',
    'je suis en voiture', 'je suis au volant',
    'démarrage voiture', 'mode conduite',
    'activer mode voiture', 'activer conduite',
    'je pars en voiture', 'je prends la route',
  ];

  static const frCarModeOffVerbs = [
    'quitter mode voiture', 'désactiver conduite',
    'je suis arrivé', 'je suis arrivée',
    'fin de trajet', 'arrêt voiture',
    'je gare', 'je me gare', 'je stationne',
    'je ne conduis plus', 'trajet terminé',
  ];

  // ══════════════════════════════════════════════════════════
  // ANGLAIS
  // ══════════════════════════════════════════════════════════

  static const enCallVerbs = [
    'call', 'phone', 'dial', 'ring', 'contact',
    'reach', 'get', 'connect',
    'make a call', 'give a call', 'place a call',
    'can you call', 'could you call', 'please call',
    'i want to call', 'i need to call', 'i would like to call',
    'try to reach', 'try calling', 'get in touch with',
    'put me through to', 'connect me to', 'connect me with',
    'let me speak to', 'i want to speak to',
  ];

  static const enAnswerVerbs = [
    'answer', 'pick up', 'accept', 'take',
    'receive', 'get the call',
    'answer the call', 'pick up the call',
    'accept the call', 'take the call',
    'yes answer', 'yeah pick up', 'go ahead',
  ];

  static const enHangupVerbs = [
    'hang up', 'end', 'stop', 'finish', 'terminate',
    'disconnect', 'close', 'drop',
    'end the call', 'hang up the call', 'stop the call',
    'i am done', 'i am finished', 'that is all',
    'goodbye', 'bye', 'later', 'take care',
    'cut the line', 'drop the call',
  ];

  static const enSmsVerbs = [
    'send', 'text', 'message', 'write', 'tell',
    'notify', 'inform', 'let know',
    'send a text', 'send a message', 'send an sms',
    'write a message', 'drop a message',
    'can you text', 'please text',
  ];

  static const enReadSmsVerbs = [
    'read', 'show', 'check', 'see', 'look at',
    'my messages', 'new messages', 'any messages',
    'read my messages', 'check my texts',
    'do i have messages', 'any new texts',
  ];

  static const enWhatsappVerbs = [
    'whatsapp', 'whatsap', 'watsapp',
    'send on whatsapp', 'via whatsapp', 'through whatsapp',
    'whatsapp message',
  ];

  static const enAlarmVerbs = [
    'alarm', 'wake me', 'wake up', 'wake me up',
    'set alarm', 'set an alarm', 'create alarm',
    'i need to wake up', 'wake me at',
  ];

  static const enTimerVerbs = [
    'timer', 'countdown', 'count down',
    'set timer', 'start timer', 'start a timer',
    'remind me in', 'in',
  ];

  static const enCarModeOnVerbs = [
    'car mode', 'driving mode', 'i am driving',
    'enable car mode', 'start driving mode',
    'i am in the car', 'taking the car',
  ];

  static const enCarModeOffVerbs = [
    'disable car mode', 'exit car mode', 'stop driving mode',
    'i arrived', 'i have arrived', 'i am parked',
    'done driving', 'finished driving',
  ];
}

// ══════════════════════════════════════════════════════════════
// MOTEUR DE RECONNAISSANCE D'INTENTION
// ══════════════════════════════════════════════════════════════

class IntentRecognizer {

  /// Point d'entrée principal
  Intent recognize(String rawText) {
    final text = _normalize(rawText);
    if (text.isEmpty) {
      return Intent(type: IntentType.unknown, confidence: 0.0, language: 'fr');
    }

    debugPrint('🧠 NLU: analyse de "$text"');

    // Détecter la langue
    final lang = _detectLanguage(text);

    // Tenter la reconnaissance par intention
    final intent = lang == 'fr'
        ? _recognizeFrench(text, rawText)
        : _recognizeEnglish(text, rawText);

    debugPrint('🎯 NLU résultat: $intent');
    return intent;
  }

  // ── Détection de langue simple ────────────────────────────
  String _detectLanguage(String text) {
    final frWords = ['le', 'la', 'les', 'un', 'une', 'des', 'je', 'tu',
                     'il', 'elle', 'nous', 'vous', 'ils', 'et', 'ou',
                     'mais', 'donc', 'mon', 'ma', 'mes', 'ton', 'ta'];
    final enWords = ['the', 'a', 'an', 'i', 'you', 'he', 'she', 'we',
                     'they', 'and', 'or', 'but', 'my', 'your', 'his'];

    int frScore = 0;
    int enScore = 0;

    final words = text.split(' ');
    for (final word in words) {
      if (frWords.contains(word)) frScore++;
      if (enWords.contains(word)) enScore++;
    }

    return enScore > frScore ? 'en' : 'fr';
  }

  // ── Reconnaissance FR ─────────────────────────────────────
  Intent _recognizeFrench(String text, String raw) {
    // APPEL
    final callMatch = _matchWithEntity(text, _Synonyms.frCallVerbs);
    if (callMatch != null) {
      return Intent(
        type: IntentType.call,
        confidence: callMatch.confidence,
        language: 'fr',
        contact: _extractContact(text, callMatch.matchedVerb),
      );
    }

    // DÉCROCHER
    if (_matchesAny(text, _Synonyms.frAnswerVerbs) > 0.5) {
      return Intent(
        type: IntentType.answer,
        confidence: _matchesAny(text, _Synonyms.frAnswerVerbs),
        language: 'fr',
      );
    }

    // RACCROCHER
    if (_matchesAny(text, _Synonyms.frHangupVerbs) > 0.5) {
      return Intent(
        type: IntentType.hangup,
        confidence: _matchesAny(text, _Synonyms.frHangupVerbs),
        language: 'fr',
      );
    }

    // SMS
    final smsMatch = _matchWithEntity(text, _Synonyms.frSmsVerbs);
    if (smsMatch != null && _hasContactAndMessage(text)) {
      final parts = _extractContactAndMessage(text, smsMatch.matchedVerb);
      return Intent(
        type: IntentType.sendSms,
        confidence: smsMatch.confidence,
        language: 'fr',
        contact: parts.$1,
        message: parts.$2,
      );
    }

    // LIRE SMS
    if (_matchesAny(text, _Synonyms.frReadSmsVerbs) > 0.5) {
      return Intent(
        type: IntentType.readSms,
        confidence: _matchesAny(text, _Synonyms.frReadSmsVerbs),
        language: 'fr',
      );
    }

    // WHATSAPP APPEL
    if (_matchesAny(text, _Synonyms.frWhatsappCallVerbs) > 0.5) {
      return Intent(
        type: IntentType.whatsappCall,
        confidence: _matchesAny(text, _Synonyms.frWhatsappCallVerbs),
        language: 'fr',
        contact: _extractAfterKeyword(text, ['whatsapp', 'appel']),
      );
    }

    // WHATSAPP MESSAGE
    final waMatch = _matchWithEntity(text, _Synonyms.frWhatsappVerbs);
    if (waMatch != null) {
      final parts = _extractContactAndMessage(text, waMatch.matchedVerb);
      return Intent(
        type: IntentType.whatsappMessage,
        confidence: waMatch.confidence,
        language: 'fr',
        contact: parts.$1,
        message: parts.$2,
      );
    }

    // RÉVEIL
    final alarmMatch = _matchWithEntity(text, _Synonyms.frAlarmVerbs);
    if (alarmMatch != null) {
      return Intent(
        type: IntentType.setAlarm,
        confidence: alarmMatch.confidence,
        language: 'fr',
        time: _extractTime(text),
      );
    }

    // TIMER
    final timerMatch = _matchWithEntity(text, _Synonyms.frTimerVerbs);
    if (timerMatch != null) {
      return Intent(
        type: IntentType.setTimer,
        confidence: timerMatch.confidence,
        language: 'fr',
        time: _extractDuration(text),
      );
    }

    // ANNULER ALARME
    if (text.contains('annule') || text.contains('supprime') ||
        text.contains('efface') || text.contains('enlève')) {
      if (text.contains('alarme') || text.contains('réveil') ||
          text.contains('timer') || text.contains('minuterie')) {
        return Intent(type: IntentType.cancelAlarm, confidence: 0.9, language: 'fr');
      }
    }

    // MODE VOITURE
    if (_matchesAny(text, _Synonyms.frCarModeOnVerbs) > 0.5) {
      return Intent(type: IntentType.carModeOn, confidence: 0.9, language: 'fr');
    }
    if (_matchesAny(text, _Synonyms.frCarModeOffVerbs) > 0.5) {
      return Intent(type: IntentType.carModeOff, confidence: 0.9, language: 'fr');
    }

    return Intent(type: IntentType.unknown, confidence: 0.0, language: 'fr');
  }

  // ── Reconnaissance EN ─────────────────────────────────────
  Intent _recognizeEnglish(String text, String raw) {
    final callMatch = _matchWithEntity(text, _Synonyms.enCallVerbs);
    if (callMatch != null) {
      return Intent(
        type: IntentType.call,
        confidence: callMatch.confidence,
        language: 'en',
        contact: _extractContact(text, callMatch.matchedVerb),
      );
    }

    if (_matchesAny(text, _Synonyms.enAnswerVerbs) > 0.5) {
      return Intent(type: IntentType.answer, confidence: 0.9, language: 'en');
    }
    if (_matchesAny(text, _Synonyms.enHangupVerbs) > 0.5) {
      return Intent(type: IntentType.hangup, confidence: 0.9, language: 'en');
    }

    final smsMatch = _matchWithEntity(text, _Synonyms.enSmsVerbs);
    if (smsMatch != null && _hasContactAndMessage(text)) {
      final parts = _extractContactAndMessage(text, smsMatch.matchedVerb);
      return Intent(
        type: IntentType.sendSms,
        confidence: smsMatch.confidence,
        language: 'en',
        contact: parts.$1,
        message: parts.$2,
      );
    }

    if (_matchesAny(text, _Synonyms.enReadSmsVerbs) > 0.5) {
      return Intent(type: IntentType.readSms, confidence: 0.9, language: 'en');
    }

    final waMatch = _matchWithEntity(text, _Synonyms.enWhatsappVerbs);
    if (waMatch != null) {
      final parts = _extractContactAndMessage(text, waMatch.matchedVerb);
      return Intent(
        type: IntentType.whatsappMessage,
        confidence: waMatch.confidence,
        language: 'en',
        contact: parts.$1,
        message: parts.$2,
      );
    }

    final alarmMatch = _matchWithEntity(text, _Synonyms.enAlarmVerbs);
    if (alarmMatch != null) {
      return Intent(
        type: IntentType.setAlarm,
        confidence: alarmMatch.confidence,
        language: 'en',
        time: _extractTime(text),
      );
    }

    final timerMatch = _matchWithEntity(text, _Synonyms.enTimerVerbs);
    if (timerMatch != null) {
      return Intent(
        type: IntentType.setTimer,
        confidence: timerMatch.confidence,
        language: 'en',
        time: _extractDuration(text),
      );
    }

    if (_matchesAny(text, _Synonyms.enCarModeOnVerbs) > 0.5) {
      return Intent(type: IntentType.carModeOn, confidence: 0.9, language: 'en');
    }
    if (_matchesAny(text, _Synonyms.enCarModeOffVerbs) > 0.5) {
      return Intent(type: IntentType.carModeOff, confidence: 0.9, language: 'en');
    }

    return Intent(type: IntentType.unknown, confidence: 0.0, language: 'en');
  }

  // ══════════════════════════════════════════════════════════
  // UTILITAIRES
  // ══════════════════════════════════════════════════════════

  /// Normaliser le texte (accents, ponctuation, espaces multiples)
  String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Chercher le meilleur synonyme dans le texte
  /// Retourne le verbe trouvé et son score de confiance
  _MatchResult? _matchWithEntity(String text, List<String> synonyms) {
    double bestScore = 0.0;
    String bestVerb = '';

    for (final synonym in synonyms) {
      // Correspondance exacte → score 1.0
      if (text.contains(synonym)) {
        return _MatchResult(confidence: 1.0, matchedVerb: synonym);
      }

      // Correspondance par mots individuels
      final synWords = synonym.split(' ');
      int matchCount = 0;
      for (final word in synWords) {
        if (word.length > 3 && text.contains(word)) matchCount++;
      }
      if (synWords.isNotEmpty) {
        final score = matchCount / synWords.length;
        if (score > bestScore) {
          bestScore = score;
          bestVerb = synonym;
        }
      }

      // Distance Levenshtein pour les mots simples
      if (synonym.split(' ').length == 1 && synonym.length > 4) {
        for (final word in text.split(' ')) {
          if (word.length > 3) {
            final dist = _levenshtein(word, synonym);
            final maxLen = [word.length, synonym.length].reduce((a, b) => a > b ? a : b);
            final score = 1.0 - (dist / maxLen);
            if (score > 0.75 && score > bestScore) {
              bestScore = score;
              bestVerb = synonym;
            }
          }
        }
      }
    }

    if (bestScore >= 0.5) return _MatchResult(confidence: bestScore, matchedVerb: bestVerb);
    return null;
  }

  /// Score de correspondance entre le texte et une liste de synonymes
  double _matchesAny(String text, List<String> synonyms) {
    final result = _matchWithEntity(text, synonyms);
    return result?.confidence ?? 0.0;
  }

  /// Extraire le nom du contact après le verbe d'action
  String? _extractContact(String text, String matchedVerb) {
    // Supprimer le verbe du texte
    String remaining = text.replaceFirst(matchedVerb, '').trim();

    // Articles et possessifs à ignorer en tête (pas les mots relationnels)
    final linking = [
      'a', 'à', 'le', 'la', 'les', 'au', 'aux', 'de', 'du', 'un', 'une', 'pour',
      'mon', 'ma', 'mes', 'ton', 'ta', 'tes', 'son', 'sa', 'ses',
      'notre', 'votre', 'leur', 'leurs',
      'to', 'the', 'an', 'for', 'my', 'your', 'his', 'her', 'our',
    ];
    // Mots relationnels : on les conserve en fallback si rien d'autre n'est trouvé.
    // Ex: "appelle ma mère" → "mere" utilisé pour la recherche (trouvera "Mère" en DB)
    final relational = [
      'ami', 'amie', 'amis', 'frere', 'soeur', 'pere', 'mere', 'fils',
      'fille', 'copain', 'copine', 'collegue', 'patron', 'chef',
      'voisin', 'voisine', 'cousin', 'cousine', 'oncle', 'tante', 'maman', 'papa',
      'friend', 'brother', 'sister', 'dad', 'mom', 'father', 'mother',
      'boss', 'colleague', 'neighbor', 'cousin',
    ];

    final words = remaining.split(' ');
    final filtered = <String>[];
    final relationalFallback = <String>[];

    for (final word in words) {
      if (word.isEmpty) continue;
      // Mots de fin de phrase : on s'arrête
      if (['et', 'en', 'que', 'qu', 'and', 'saying', 'ce', 'cet', 'cette',
           's il', 'sil', 'te', 'plait', 'maintenant', 'vite', 'urgent',
           'merci', 'please', 'now'].contains(word)) break;
      // Ignorer les articles/possessifs en tête seulement
      if (linking.contains(word) && filtered.isEmpty && relationalFallback.isEmpty) continue;
      // Mot relationnel : garder en fallback si c'est le seul contenu
      if (relational.contains(word) && filtered.isEmpty) {
        relationalFallback.add(word);
        continue;
      }
      filtered.add(word);
    }

    // Utiliser les vrais mots s'il y en a, sinon le mot relationnel comme terme de recherche
    if (filtered.isNotEmpty) {
      return filtered.take(2).join(' ').trim();
    }
    if (relationalFallback.isNotEmpty) {
      // [FIX] Était null avant → "appelle ma mère" échouait silencieusement
      return relationalFallback.first;
    }
    return null;
  }

  /// Extraire contact ET message pour SMS/WhatsApp
  (String?, String?) _extractContactAndMessage(String text, String matchedVerb) {
    String remaining = text.replaceFirst(matchedVerb, '').trim();

    // Supprimer les préfixes : "à Jean dis lui que" → "Jean", "je suis en route"
    remaining = remaining
        .replaceFirst(RegExp(r'^(a|à|au|le|la|un|une|mon|ma|to|the|my)\s+'), '')
        .trim();

    // Séparer contact et message sur les mots de coupure
    final separators = RegExp(
      r'\s+(que|qu|pour dire|pour lui dire|dis lui|dis-lui|dis lui que'
      r'|en lui disant|le message|le texte|ceci|cela|disant|en disant'
      r'|that|saying|to say|the message)\s+',
      caseSensitive: false,
    );

    final parts = remaining.split(separators);
    if (parts.length >= 2) {
      // [FIX] Était: parts[0].split(' ').first → un seul mot, "Jean Pierre" → "jean"
      // Maintenant : jusqu'à 2 mots pour les prénoms composés
      final contactWords = parts[0].trim().split(' ')
          .where((w) => w.isNotEmpty)
          .take(2)
          .toList();
      final contact = contactWords.join(' ').trim();
      final message = parts.sublist(1).join(' ').trim();
      return (contact.isEmpty ? null : contact, message.isEmpty ? null : message);
    }

    // Fallback: premier(s) mot(s) = contact, reste = message
    final words = remaining.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.length >= 3) {
      // Essayer 2 mots pour le contact si le 2ème ressemble à un prénom (commence par majuscule)
      final secondWordIsName = words.length > 1 &&
          words[1].isNotEmpty &&
          words[1][0] == words[1][0].toUpperCase() &&
          !['de', 'du', 'que', 'en', 'le', 'la'].contains(words[1].toLowerCase());
      if (secondWordIsName && words.length >= 3) {
        return (
          '${words[0]} ${words[1]}',
          words.sublist(2).join(' '),
        );
      }
      return (words.first, words.sublist(1).join(' '));
    }
    if (words.length == 2) {
      return (words.first, words.last);
    }

    return (remaining.isEmpty ? null : remaining, null);
  }

  /// Extraire une heure depuis le texte
  String? _extractTime(String text) {
    // "à 7 heures 30", "à 8h30", "à midi", "at 7 thirty"
    final patterns = [
      RegExp(r'a\s+(\d{1,2}h\d{2})'),
      RegExp(r'a\s+(\d{1,2})\s+heures?\s+(\d{1,2})'),
      RegExp(r'a\s+(\d{1,2})\s+heures?'),
      RegExp(r'(midi|minuit|noon|midnight)'),
      RegExp(r'at\s+(\d{1,2}:\d{2})'),
      RegExp(r'at\s+(\d{1,2})\s+(am|pm)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) return match.group(0)?.replaceFirst('a ', '').trim();
    }
    return null;
  }

  /// Extraire une durée depuis le texte
  String? _extractDuration(String text) {
    final patterns = [
      RegExp(r'(\d+)\s+(minutes?|mins?|secondes?|seconds?|secs?|heures?|hours?)'),
      RegExp(r'(\d+)\s+heures?\s+(\d+)\s+minutes?'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) return match.group(0)?.trim();
    }
    return null;
  }

  bool _hasContactAndMessage(String text) {
    return text.split(' ').length >= 3;
  }

  String? _extractAfterKeyword(String text, List<String> keywords) {
    for (final kw in keywords) {
      final idx = text.indexOf(kw);
      if (idx != -1) {
        final after = text.substring(idx + kw.length).trim();
        if (after.isNotEmpty) return after.split(' ').first;
      }
    }
    return null;
  }

  // ══════════════════════════════════════════════════════════
  // ALGORITHME DE LEVENSHTEIN
  // Distance entre deux mots (tolérance aux fautes)
  // Exemples:
  //   levenshtein("appele", "appelle") = 1  ✅ accepté
  //   levenshtein("racrroche", "raccroche") = 1  ✅ accepté
  //   levenshtein("bonjour", "appelle") = 6  ❌ rejeté
  // ══════════════════════════════════════════════════════════
  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final matrix = List.generate(
      a.length + 1,
      (i) => List.generate(b.length + 1, (j) => 0),
    );

    for (int i = 0; i <= a.length; i++) matrix[i][0] = i;
    for (int j = 0; j <= b.length; j++) matrix[0][j] = j;

    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,      // suppression
          matrix[i][j - 1] + 1,      // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[a.length][b.length];
  }
}

class _MatchResult {
  final double confidence;
  final String matchedVerb;
  const _MatchResult({required this.confidence, required this.matchedVerb});
}
