#!/bin/bash
# ─────────────────────────────────────────────────────────────
# setup_models.sh — Télécharge les modèles Vosk offline
# Exécuter UNE SEULE FOIS avant de lancer le projet
# Usage : bash setup_models.sh
# ─────────────────────────────────────────────────────────────

set -e  # Arrêter si une commande échoue

echo "🎙️  Installation des modèles Vosk offline..."
echo ""

# Créer le dossier si absent
mkdir -p assets/models

# ── Modèle Français ──────────────────────────────────────────
FR_MODEL="vosk-model-small-fr-0.22"
if [ -d "assets/models/$FR_MODEL" ]; then
  echo "✅ Modèle Français déjà installé, skip."
else
  echo "📥 Téléchargement modèle Français (45 MB)..."
  wget -q --show-progress \
    https://alphacephei.com/vosk/models/$FR_MODEL.zip \
    -O /tmp/vosk-fr.zip
  echo "📦 Extraction..."
  unzip -q /tmp/vosk-fr.zip -d assets/models/
  rm /tmp/vosk-fr.zip
  echo "✅ Modèle Français installé : assets/models/$FR_MODEL"
fi

echo ""

# ── Modèle Anglais ───────────────────────────────────────────
EN_MODEL="vosk-model-small-en-us-0.15"
if [ -d "assets/models/$EN_MODEL" ]; then
  echo "✅ Modèle Anglais déjà installé, skip."
else
  echo "📥 Téléchargement modèle Anglais (40 MB)..."
  wget -q --show-progress \
    https://alphacephei.com/vosk/models/$EN_MODEL.zip \
    -O /tmp/vosk-en.zip
  echo "📦 Extraction..."
  unzip -q /tmp/vosk-en.zip -d assets/models/
  rm /tmp/vosk-en.zip
  echo "✅ Modèle Anglais installé : assets/models/$EN_MODEL"
fi

echo ""
echo "──────────────────────────────────────────"
echo "✅ Tous les modèles sont prêts !"
echo ""
echo "Prochaines étapes :"
echo "  1. flutter pub get"
echo "  2. flutter pub run build_runner build --delete-conflicting-outputs"
echo "  3. flutter run"
echo "──────────────────────────────────────────"
