# Corrections de bugs — JKAssistant Vocal

## Liste des bugs corrigés

### E013 — TTS : phrases superposées
- **Fichier** : `lib/core/voice/voice_synthesizer.dart`
- **Fix** : `awaitSpeakCompletion(true)` confirmé actif dans `initialize()`

### E014 — TTS : langue indisponible sur l'appareil
- **Fichier** : `lib/core/voice/voice_synthesizer.dart`
- **Fix** : `setLanguage()` vérifie maintenant `isLanguageAvailable()` avant d'appliquer la langue, avec fallback sur le code court (`fr` si `fr-FR` absent), puis conserve la langue système si aucun fallback ne marche.

### E017 — Fuite mémoire : StreamSubscription non annulée
- **Fichier** : `lib/presentation/blocs/voice_bloc.dart`
- **Fix** : `_resultSub?.cancel()`, `_partialSub?.cancel()`, `_hotwordSub?.cancel()` dans `close()` — déjà présent, confirmé.

### E019 — Permission SMS non demandée au runtime
- **Fichier** : `lib/core/services/sms_service.dart`
- **Fix** : `Permission.sms.request()` appelé avant tout envoi (et non juste `isGranted` qui ne demande pas).

### E020 — SMS sans indicatif international
- **Fichier** : `lib/core/services/sms_service.dart`
- **Fix** : `_toInternational()` convertit `06XXXXXXXX` → `+336XXXXXXXX` avant envoi SMS.

### E021 — WhatsApp crash si non installé
- **Fichier** : `lib/core/services/whatsapp_service.dart`
- **Fix** : `canLaunchUrl()` vérifié avant `launchUrl()` dans `sendMessage()` ET `makeCall()`.

### E022 — Numéro WhatsApp avec `+` dans l'URL wa.me
- **Fichier** : `lib/core/services/whatsapp_service.dart`
- **Fix** : `_toInternationalNoPlus()` produit `33612345678` (sans `+`) au lieu de `+33612345678` — wa.me exige le format sans `+`.

### E032 — Double déclenchement hotword
- **Fichier** : `lib/core/services/hotword_service.dart`
- **Fix** : Cooldown 3s maintenu, documenté — ne pas réduire.

### E033 — Modèle Vosk chargé deux fois (OOM)
- **Fichiers** : `lib/core/voice/voice_recognizer.dart`, `lib/core/services/hotword_service.dart`, `lib/presentation/blocs/voice_bloc.dart`
- **Fix** :
  - `VoiceRecognizer` expose `frModel` et `enModel` en getter public.
  - `HotwordService.startListening({Model? sharedModel})` accepte le modèle partagé et ne le charge que si `null`.
  - `VoiceBloc._onHotwordToggled` passe `_recognizer.frModel` au `HotwordService`.
  - `_ownsModel` flag dans `HotwordService` pour n'appeler `dispose()` que sur les modèles que le service a chargés lui-même.

### E035 — Extraction de contact incorrecte sur phrases longues
- **Fichier** : `lib/core/voice/intent_recognizer.dart`
- **Fix** : Liste `linking` étendue dans `_extractContact()` :
  - Pronoms possessifs : `mon`, `ma`, `mes`, `ton`, `ta`, `son`, `sa`…
  - Mots relationnels : `ami`, `amie`, `frere`, `soeur`, `pere`, `mere`, `fils`, `copain`, `collegue`…
  - Équivalents EN : `my`, `friend`, `brother`, `sister`, `dad`, `mom`…
  - "je voudrais appeler mon ami Jean ce soir" → contact = "Jean" ✅

### E037 — Message SMS null envoyé silencieusement
- **Fichier** : `lib/presentation/blocs/voice_bloc.dart`
- **Fix** : Dans `_handleSendSms()` et `_handleWhatsappMessage()`, si `contactName == null` ou `messageText == null`, l'assistant demande vocalement ce qui manque au lieu de passer silencieusement.

### E038 — Confidence faible ignorée silencieusement
- **Fichier** : `lib/presentation/blocs/voice_bloc.dart`
- **Fix** :
  - confidence < 0.3 → feedback vocal "Je n'ai pas bien compris, veuillez répéter"
  - 0.3 ≤ confidence < 0.75 sur actions sensibles (appel, SMS, WhatsApp) → dialogue de confirmation vocale "Vous voulez dire : appeler Jean ?"
  - `_requiresConfirmation()` et `_buildConfirmationText()` extraits en méthodes séparées.

---

## Résumé

| # | Fichier | Sévérité | Statut |
|---|---------|----------|--------|
| E013 | voice_synthesizer.dart | Moyen | ✅ Corrigé |
| E014 | voice_synthesizer.dart | Moyen | ✅ Corrigé |
| E019 | sms_service.dart | Critique | ✅ Corrigé |
| E020 | sms_service.dart | Moyen | ✅ Corrigé |
| E021 | whatsapp_service.dart | Critique | ✅ Corrigé |
| E022 | whatsapp_service.dart | Critique | ✅ Corrigé |
| E033 | recognizer + hotword + bloc | Critique (OOM) | ✅ Corrigé |
| E035 | intent_recognizer.dart | Moyen | ✅ Corrigé |
| E037 | voice_bloc.dart | Moyen | ✅ Corrigé |
| E038 | voice_bloc.dart | Moyen | ✅ Corrigé |
