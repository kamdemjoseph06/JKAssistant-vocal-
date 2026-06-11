# 🎙️ Vocal Assist — Assistant Vocal Android Offline

Application mobile Android de contrôle vocal des appels téléphoniques.
Fonctionne **100% hors ligne** — aucune connexion internet requise.

---

## Fonctionnalités

| Commande vocale | Action |
|---|---|
| "Appelle Jean" / "Call John" | Lance un appel vers ce contact |
| "Décroche" / "Answer" | Répond à l'appel entrant |
| "Raccroche" / "Hang up" | Termine l'appel en cours |
| "Qui appelle ?" / "Who's calling?" | Annonce l'appelant |

---

## Stack technique

```
Flutter (Dart)        → UI + Logique
Vosk                  → Reconnaissance vocale offline FR + EN
Flutter TTS           → Synthèse vocale offline
Drift + SQLite        → Base de données locale SQL
flutter_bloc          → Gestion d'état
get_it                → Injection de dépendances
```

---

## Installation

### 1. Cloner le projet
```bash
git clone <repo>
cd vocal_assistant
```

### 2. Télécharger les modèles Vosk
```bash
# Créer le dossier
mkdir -p assets/models

# Français (45 MB)
wget https://alphacephei.com/vosk/models/vosk-model-small-fr-0.22.zip
unzip vosk-model-small-fr-0.22.zip -d assets/models/

# Anglais (40 MB)
wget https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip
unzip vosk-model-small-en-us-0.15.zip -d assets/models/
```

### 3. Installer les dépendances
```bash
flutter pub get
```

### 4. Générer les fichiers Drift SQL
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Lancer l'app
```bash
flutter run
```

---

## Structure du projet

```
lib/
├── main.dart                          # Point d'entrée
├── service_locator.dart               # Injection dépendances
├── core/
│   └── voice/
│       ├── voice_recognizer.dart      # Vosk offline
│       ├── voice_synthesizer.dart     # TTS offline
│       └── command_parser.dart        # Interprétation commandes
├── data/
│   ├── database/
│   │   ├── app_database.dart          # Config Drift SQL
│   │   ├── tables/                    # Schémas SQL
│   │   └── daos/                      # Requêtes SQL
│   └── repositories/
│       ├── contact_repository.dart
│       └── call_repository.dart
├── domain/
│   └── usecases/
│       └── call_usecases.dart
└── presentation/
    ├── screens/home_screen.dart
    ├── blocs/voice_bloc.dart
    └── widgets/
docs/
└── ERRORS_LOG.md                      # ⚠️ Lire avant de coder
```

---

## Permissions Android requises

```xml
RECORD_AUDIO          → Microphone
CALL_PHONE            → Passer des appels
ANSWER_PHONE_CALLS    → Décrocher (API 26+)
READ_PHONE_STATE      → État du téléphone
READ_CONTACTS         → Répertoire
```

---

## ⚠️ Lire avant de développer

Consulter `docs/ERRORS_LOG.md` pour éviter les erreurs connues.

---

## Commandes utiles

```bash
# Régénérer Drift après modification des tables
flutter pub run build_runner build --delete-conflicting-outputs

# Tests
flutter test

# Build APK release
flutter build apk --release
```
