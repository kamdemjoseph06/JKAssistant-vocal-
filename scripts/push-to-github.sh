#!/bin/bash

REPO="kamdemjoseph06/JKAssistant-vocal-"
BRANCH="${1:-main}"
MSG="${2:-Mise à jour depuis Replit}"

if [ -z "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
  echo "Erreur : GITHUB_PERSONAL_ACCESS_TOKEN n'est pas défini."
  exit 1
fi

git config user.name "kamdemjoseph06"
git config user.email "kamdemjoseph06@users.noreply.github.com"

git remote remove github 2>/dev/null || true
git remote add github "https://${GITHUB_PERSONAL_ACCESS_TOKEN}@github.com/${REPO}.git"

echo "Ajout de tous les fichiers modifiés..."
git add -A

if git diff --cached --quiet; then
  echo "Rien de nouveau à committer."
else
  git commit -m "$MSG"
  echo "Commit effectué : $MSG"
fi

echo "Envoi vers GitHub ($REPO) sur la branche '$BRANCH'..."
git push github HEAD:"$BRANCH" --force

git remote remove github
echo "Terminé ! Fichiers envoyés sur https://github.com/${REPO}"
