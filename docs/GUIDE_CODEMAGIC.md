# 🚀 Guide : Obtenir ton APK avec GitHub + Codemagic

Suit ces étapes dans l'ordre. Durée totale : ~20 minutes.

---

## PARTIE 1 — Mettre le projet sur GitHub

### Étape 1 : Créer un compte GitHub
1. Aller sur **github.com**
2. Cliquer **"Sign up"**
3. Entrer ton email, un mot de passe, un nom d'utilisateur
4. Valider l'email reçu

---

### Étape 2 : Créer un nouveau repository
1. Cliquer le **"+"** en haut à droite → **"New repository"**
2. Remplir :
   - **Repository name** : `vocal-assistant`
   - **Visibility** : Private (recommandé)
3. Cliquer **"Create repository"**

---

### Étape 3 : Uploader les fichiers
1. Sur la page du repo → cliquer **"uploading an existing file"**
2. Extraire le ZIP sur ton ordinateur
3. **Glisser-déposer TOUS les fichiers** du dossier extrait
4. En bas → message de commit : `Premier upload`
5. Cliquer **"Commit changes"**

> ⚠️ Ne pas uploader le ZIP lui-même, mais son contenu décompressé.

---

## PARTIE 2 — Compiler avec Codemagic

### Étape 4 : Créer un compte Codemagic
1. Aller sur **codemagic.io**
2. Cliquer **"Sign up free"**
3. Choisir **"Continue with GitHub"** (connecte automatiquement tes repos)

---

### Étape 5 : Ajouter l'application
1. Dans Codemagic → cliquer **"Add application"**
2. Choisir **GitHub** comme source
3. Sélectionner le repo **"vocal-assistant"**
4. Type de projet : **"Flutter App"**
5. Cliquer **"Finish: Add application"**

---

### Étape 6 : Lancer le build
1. Codemagic détecte automatiquement le fichier `codemagic.yaml`
2. Cliquer **"Start new build"**
3. Workflow : **"vocal-assistant-android"**
4. Cliquer **"Start new build"** ✅

---

### Étape 7 : Attendre le build
```
⏳ Durée : 10 à 20 minutes

Tu peux voir les logs en temps réel :
  ✅ Vérification Flutter
  ✅ Téléchargement modèles Vosk (automatique)
  ✅ Installation dépendances
  ✅ Génération Drift SQL
  ✅ Compilation APK
```

---

### Étape 8 : Télécharger l'APK
1. Build terminé → onglet **"Artifacts"**
2. Télécharger **`app-debug.apk`** (pour tester)
3. Ou **`app-release.apk`** (version finale)

---

## PARTIE 3 — Installer l'APK sur ton téléphone

### Étape 9 : Autoriser les sources inconnues
Sur ton téléphone Android :
```
Paramètres → Sécurité → "Installer des apps inconnues"
→ Activer pour ton navigateur ou gestionnaire de fichiers
```

> Sur Android récent (10+) :
> Paramètres → Applications → ⋮ → Accès spécial → Installer des apps inconnues

---

### Étape 10 : Installer l'APK
1. Envoyer l'APK sur ton téléphone :
   - Par email (te l'envoyer à toi-même)
   - Ou Google Drive → télécharger sur le téléphone
2. Ouvrir le fichier `.apk` depuis le téléphone
3. Cliquer **"Installer"**
4. Ouvrir l'app ✅

---

## ❓ Problèmes fréquents

| Problème | Solution |
|---|---|
| Build échoue à "build_runner" | Vérifier que tous les fichiers sont bien uploadés |
| "App not installed" sur téléphone | Désinstaller une version précédente d'abord |
| Modèles Vosk timeout | Relancer le build, réseau Codemagic parfois lent |
| APK trop lourd | Normal : ~150 MB à cause des modèles Vosk |

---

## 📧 Notification automatique

Le fichier `codemagic.yaml` envoie un email quand l'APK est prêt.
Pense à mettre **ton email** dans le fichier avant d'uploader :
```yaml
recipients:
  - ton-email@exemple.com   ← Modifier ici
```
