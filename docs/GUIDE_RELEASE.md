# 🚀 Guide — Publier l'APK Release sur le Play Store

## Vue d'ensemble

Ce guide couvre toutes les étapes pour passer du code source à un APK signé publié sur le Google Play Store.

---

## Étape 1 — Créer un Keystore (une seule fois)

Le keystore est ta clé de signature. **Ne le perds jamais** — sans lui tu ne pourras plus mettre à jour ton app sur le Play Store.

```bash
keytool -genkey -v \
  -keystore keystore.jks \
  -alias vocal_key \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

Réponds aux questions (nom, organisation, pays) et note bien :
- Le mot de passe du keystore (`CM_KEYSTORE_PASS`)
- Le nom de l'alias (`CM_KEY_ALIAS` = `vocal_key`)
- Le mot de passe de la clé (`CM_KEY_PASS`)

⚠️ **Ne commit jamais `keystore.jks` sur GitHub.** Ajoute-le à `.gitignore`.

---

## Étape 2 — Encoder le Keystore en base64

Codemagic reçoit le keystore sous forme de variable d'environnement encodée :

```bash
# Linux / macOS
base64 keystore.jks | tr -d '\n' > keystore_b64.txt

# Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("keystore.jks")) | Out-File keystore_b64.txt
```

Copie le contenu de `keystore_b64.txt` — tu en auras besoin à l'étape 3.

---

## Étape 3 — Configurer les secrets dans Codemagic

1. Ouvre [codemagic.io](https://codemagic.io) → ton app → **App settings**
2. Va dans **Environment variables**
3. Ajoute ces 4 variables (coche **Secure** pour chacune) :

| Variable | Valeur | Secure |
|---|---|---|
| `CM_KEYSTORE` | Contenu de `keystore_b64.txt` | ✅ |
| `CM_KEYSTORE_PASS` | Mot de passe du keystore | ✅ |
| `CM_KEY_ALIAS` | `vocal_key` (ou ton alias) | ✅ |
| `CM_KEY_PASS` | Mot de passe de la clé | ✅ |

---

## Étape 4 — Mettre à jour la version dans pubspec.yaml

Avant chaque release, incrémente la version :

```yaml
# pubspec.yaml
version: 2.0.1+2   # format : versionName+versionCode
#         ^   ^
#         |   └── versionCode  : entier qui s'incrémente à chaque build
#         └────── versionName  : version affichée sur le Play Store
```

---

## Étape 5 — Créer un tag Git pour déclencher le build

Le workflow Release se déclenche automatiquement sur les tags `v*`.

Depuis ton terminal local :

```
git add pubspec.yaml
git commit -m "chore: bump version 2.0.1+2"
git tag v2.0.1
git push origin v2.0.1
```

Codemagic détecte le tag et lance **vocal-assistant-release** automatiquement.

---

## Étape 6 — Récupérer l'APK signé

Une fois le build terminé (email envoyé à `kamdemjoseph06@gmail.com`) :

1. Ouvre Codemagic → ton build → **Artifacts**
2. Télécharge `app-release.apk`
3. Vérifie la signature localement (optionnel) :

```bash
jarsigner -verify -verbose -certs app-release.apk
```

---

## Étape 7 — Publier sur le Google Play Store

### Première publication (nouvelle app)

1. Crée un compte **Google Play Console** sur [play.google.com/console](https://play.google.com/console) (frais uniques : 25 $)
2. **Créer une application** → remplis nom, description, captures d'écran
3. Va dans **Production → Releases → Créer une release**
4. Upload `app-release.apk`
5. Remplis les notes de version → **Examiner et publier**

### Mises à jour suivantes

1. Incrémente `versionCode` dans `pubspec.yaml`
2. Crée un nouveau tag → build Release automatique
3. Upload le nouvel APK dans Play Console → Publier

---

## Checklist avant chaque release

- [ ] `pubspec.yaml` : `versionCode` incrémenté
- [ ] Build Debug passé sans erreur sur `main`
- [ ] Secrets Codemagic configurés (`CM_KEYSTORE`, etc.)
- [ ] Tag `v*` créé et poussé depuis ton terminal
- [ ] Email de succès reçu depuis Codemagic
- [ ] APK téléchargé et testé sur un vrai appareil
- [ ] APK uploadé sur Play Console

---

## Commandes utiles

```bash
# Vérifier la signature d'un APK
jarsigner -verify app-release.apk

# Voir les infos du keystore
keytool -list -v -keystore keystore.jks

# Lister les tags existants
git tag -l
```

---

## Structure des builds Codemagic

```
main  ──push──▶  Debug build   (app-debug.apk)
      ──tag v*─▶  Release build (app-release.apk signé)
```

---

*Guide généré automatiquement — mis à jour avec chaque évolution du projet.*
