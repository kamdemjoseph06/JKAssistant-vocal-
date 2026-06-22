# ERRORS_LOG.md
# Erreurs rencontrées — NE PAS REPRODUIRE

> Ce fichier documente toutes les erreurs et pièges identifiés.
> Consulter AVANT tout développement sur la fonctionnalité concernée.

---

## 🎙️ VOSK — Reconnaissance vocale

### [E001] Modèles non chargés au démarrage
- **Erreur** : `Model not found` au lancement
- **Cause** : Modèles absent de `assets/models/` ou non déclarés dans `pubspec.yaml`
- **Fix** : Télécharger depuis https://alphacephei.com/vosk/models et ajouter dans `flutter.assets`
- **À faire** :
  ```yaml
  flutter:
    assets:
      - assets/models/vosk-model-small-fr-0.22/
      - assets/models/vosk-model-small-en-us-0.15/
  ```

### [E002] Initialisation synchrone
- **Erreur** : App freeze au démarrage
- **Cause** : `VoiceRecognizer.initialize()` appelé de façon synchrone
- **Fix** : Toujours `await` dans un contexte async, jamais dans le constructeur

### [E003] Résultats Vosk en JSON
- **Erreur** : Texte brut non extrait correctement
- **Cause** : Vosk retourne `{"text": "appelle jean"}`, pas le texte direct
- **Fix** : Parser avec regex `r'"text"\s*:\s*"([^"]*)"'`

---

## 📞 APPELS TÉLÉPHONIQUES

### [E004] ANSWER_PHONE_CALLS refusé
- **Erreur** : Impossible de décrocher programmatiquement
- **Cause** : Permission `ANSWER_PHONE_CALLS` requise API 26+ (Android 8+)
- **Fix** : Déclarer dans `AndroidManifest.xml` ET demander au runtime
- **Note** : Sur Android < 8, utiliser `HeadsetPlugin` ou `TelecomManager`

### [E005] Schéma URI appel incorrect
- **Erreur** : `canLaunchUrl` retourne false
- **Cause** : Utilisation de `telprompt:` au lieu de `tel:`
- **Fix** : Toujours `tel:+33612345678` (sans espace)
- **Note** : `telprompt:` ouvre une boîte de confirmation sur certains appareils

### [E006] Permission CALL_PHONE non demandée au runtime
- **Erreur** : Crash silencieux, appel non lancé
- **Cause** : Permission déclarée dans manifest mais pas demandée runtime
- **Fix** : `await Permission.phone.request()` avant tout appel

---

## 📖 CONTACTS

### [E007] Contacts vides après sync
- **Erreur** : Cache SQL vide malgré permission accordée
- **Cause** : `FlutterContacts.getContacts()` sans `withProperties: true`
- **Fix** : Toujours passer `withProperties: true` pour avoir les numéros

### [E008] Numéros avec espaces/tirets
- **Erreur** : `tel:06 12 34 56` échoue
- **Cause** : Numéros bruts depuis le répertoire contiennent des espaces
- **Fix** : `_cleanPhone()` → `replaceAll(RegExp(r'[\s\-\.\(\)]'), '')`

### [E009] Recherche avec accents
- **Erreur** : "appelle Stéphane" ne trouve pas "Stéphane"
- **Cause** : Comparaison directe échoue sur les accents
- **Fix** : Normaliser les deux côtés via `_normalize()` avant comparaison

---

## 🗄️ BASE DE DONNÉES SQL (DRIFT)

### [E010] schemaVersion non incrémenté après migration
- **Erreur** : App plante au redémarrage après ajout de colonne
- **Cause** : `schemaVersion` non incrémenté dans `app_database.dart`
- **Fix** : Incrémenter `schemaVersion` ET ajouter migration dans `onUpgrade`

### [E011] Transaction non utilisée pour opérations groupées
- **Erreur** : Données partiellement insérées en cas d'erreur
- **Cause** : Insertions multiples sans `transaction()`
- **Fix** : Toujours `await db.transaction(() async { ... })` pour les batches

### [E012] Fichier .g.dart non généré
- **Erreur** : `part 'app_database.g.dart'` manquant
- **Cause** : `build_runner` non exécuté après modification des tables
- **Fix** : `flutter pub run build_runner build --delete-conflicting-outputs`

---

## 🔊 FLUTTER TTS — Synthèse vocale

### [E013] Phrases qui se superposent
- **Erreur** : Plusieurs phrases lues en même temps
- **Cause** : `awaitSpeakCompletion` non configuré à `true`
- **Fix** : `await _tts.awaitSpeakCompletion(true)` dans `initialize()`

### [E014] Langue non disponible sur l'appareil
- **Erreur** : TTS silencieux sur certains appareils
- **Cause** : Langue `fr-FR` non installée sur l'appareil Android
- **Fix** : Vérifier avec `_tts.isLanguageAvailable('fr-FR')` et fallback sur `fr`

---

## 🔐 PERMISSIONS

### [E015] Permissions demandées séquentiellement
- **Erreur** : UX dégradée, l'utilisateur voit 3 popups
- **Cause** : `Permission.microphone.request()` puis `Permission.phone.request()`, etc.
- **Fix** : `[Permission.microphone, Permission.phone, Permission.contacts].request()`

### [E016] App fermée sans permissions → crash
- **Erreur** : `PlatformException` au démarrage
- **Cause** : Code vocal lancé sans vérifier les permissions d'abord
- **Fix** : Toujours passer par `PermissionGate` avant d'initialiser `VoiceBloc`

---

## 📱 FLUTTER GÉNÉRAL

### [E017] BLoC non fermé → memory leak
- **Erreur** : Fuite mémoire après navigation
- **Cause** : `StreamSubscription` non annulée dans `close()`
- **Fix** : Toujours `subscription?.cancel()` dans `VoiceBloc.close()`

### [E018] GlobalScope utilisé dans ViewModel
- **Erreur** : Coroutine continue après destruction de l'écran
- **Cause** : (Pattern équivalent Flutter) : subscription non liée au lifecycle
- **Fix** : Toujours lier les streams au `BlocProvider` / `close()` du BLoC

---

## 📋 CHECKLIST AVANT RELEASE

- [ ] Modèles Vosk présents dans `assets/models/`
- [ ] `build_runner` exécuté (fichiers `.g.dart` à jour)
- [ ] Toutes les permissions dans `AndroidManifest.xml`
- [ ] `schemaVersion` correct
- [ ] Tests permissions sur Android 8, 10, 13
- [ ] Test appel vocal FR et EN
- [ ] Test hors réseau (mode avion)

---

## 📱 SMS

### [E019] Permission SEND_SMS non déclarée
- **Erreur** : `SecurityException` à l'envoi
- **Fix** : Ajouter `<uses-permission android:name="android.permission.SEND_SMS"/>` dans AndroidManifest.xml ET demander au runtime

### [E020] Numéro sans indicatif international pour SMS
- **Erreur** : SMS envoyé mais non reçu sur certains opérateurs
- **Fix** : Toujours convertir en format international (+33...) avant envoi

---

## 💬 WHATSAPP

### [E021] WhatsApp non installé → crash
- **Erreur** : `canLaunchUrl` retourne false silencieusement
- **Fix** : Toujours vérifier `canLaunchUrl` avant `launchUrl` et informer l'utilisateur vocalement

### [E022] Numéro local dans l'URL WhatsApp
- **Erreur** : `wa.me/0612345678` → page d'erreur WhatsApp
- **Fix** : Toujours utiliser format international sans le + : `wa.me/33612345678`

---

## ⏰ RÉVEIL / MINUTERIE

### [E023] AlarmManager non initialisé
- **Erreur** : `AlarmManager not initialized`
- **Fix** : Appeler `AndroidAlarmManager.initialize()` dans `main()` avant `runApp()`

### [E024] Callback alarme non top-level
- **Erreur** : Alarme déclenche mais callback non appelé
- **Fix** : Le callback DOIT être une fonction top-level (pas dans une classe) avec `@pragma('vm:entry-point')`

### [E025] Timezone non initialisée
- **Erreur** : Exception au parsing des heures
- **Fix** : Appeler `tz.initializeTimeZones()` dans `AlarmService.initialize()`

---

## 👂 HOTWORD / ÉCOUTE PERMANENTE

### [E026] Clé Picovoice manquante
- **Erreur** : Porcupine lance une exception au démarrage
- **Fix** : Créer un compte gratuit sur picovoice.ai → Console → récupérer AccessKey → l'insérer dans hotword_service.dart

### [E027] Service foreground sans notification
- **Erreur** : Service tué par Android après quelques minutes
- **Fix** : Un service foreground DOIT afficher une notification permanente (déjà configuré dans HotwordService)

### [E028] autoRunOnBoot sans permission
- **Erreur** : Service ne redémarre pas après reboot
- **Fix** : Ajouter `<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>` dans AndroidManifest.xml

---

## 🚗 MODE VOITURE

### [E029] WakelockPlus non désactivé à la fermeture
- **Erreur** : Écran reste allumé même après fermeture de l'app
- **Fix** : Toujours appeler `WakelockPlus.disable()` dans `CarModeService.dispose()`

---

## 🔄 MIGRATION Porcupine → Vosk Hotword

### [E030] Porcupine remplacé par Vosk
- **Raison** : Porcupine nécessite une inscription sur picovoice.ai
- **Solution** : Vosk utilisé pour la détection du hotword
- **Avantages** : Aucune clé, aucun compte, déjà installé, 100% offline
- **Fonctionnement** : Grammaire restreinte aux mots déclencheurs → rapide et économe

### [E031] Grammaire Vosk obligatoire pour le hotword
- **Erreur** : Hotword déclenché trop souvent (faux positifs)
- **Fix** : Passer une grammaire JSON limitée au recognizer Vosk
  ```dart
  grammar: '["hey", "vocal", "assistant", "hello"]'
  ```
  Cela restreint Vosk à n'écouter QUE ces mots → précision maximale

### [E032] Double déclenchement hotword
- **Erreur** : L'assistant se réveille 2-3 fois d'affilée
- **Fix** : Cooldown de 3 secondes dans `_checkForHotword()`
  Ne pas réduire en dessous de 2 secondes

### [E033] Modèle Vosk chargé deux fois
- **Erreur** : Out of memory si HotwordService charge son propre modèle
- **Fix** : Passer le modèle partagé depuis VoiceRecognizer :
  ```dart
  hotwordService.startListening(sharedModel: recognizer.frModel)
  ```

---

## 🧠 NLU — MOTEUR DE COMPRÉHENSION NATURELLE

### [E034] Levenshtein trop permissif
- **Erreur** : Faux positifs — "bonjour" reconnue comme commande
- **Cause** : Seuil de similarité trop bas
- **Fix** : Ne jamais descendre en dessous de 0.75 de score
  ```dart
  if (score > 0.75 && score > bestScore) // NE PAS baisser ce seuil
  ```

### [E035] Extraction de contact incorrecte sur phrases longues
- **Erreur** : "je voudrais appeler mon ami Jean ce soir" → contact = "mon"
- **Cause** : Mots de liaison non filtrés
- **Fix** : Ajouter les mots de liaison dans la liste `linking` de `_extractContact()`
  Ajouter : 'mon', 'ma', 'mes', 'ton', 'ta', 'son', 'sa', 'ami', 'amie', 'frère', 'sœur'

### [E036] Double détection FR/EN sur même phrase
- **Erreur** : "call Jean" détecté en FR et EN
- **Cause** : Certains mots comme "call" existent dans les deux dictionnaires
- **Fix** : La détection de langue passe EN avant FR si score EN > FR
  Ne pas modifier l'ordre de priorité dans `recognize()`

### [E037] Message vide pour SMS
- **Erreur** : SMS envoyé avec message null
- **Cause** : Phrase sans séparateur clair entre contact et message
- **Fix** : Toujours vérifier `command.messageText != null` avant envoi
  Demander vocalement le message si null : "Quel est le message ?"

### [E038] Confidence trop basse ignorée silencieusement
- **Erreur** : Commande inconnue sans feedback à l'utilisateur
- **Fix** : Si confidence entre 0.3 et 0.5, demander confirmation vocale :
  "Vous voulez dire : appeler Jean ?"
