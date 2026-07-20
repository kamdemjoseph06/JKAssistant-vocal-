#!/usr/bin/env python3
"""
Test standalone de la logique NLU WhatsApp.
Simule le comportement du IntentRecognizer Dart pour vérifier
que les commandes WhatsApp sont correctement reconnues.
"""

import re
from dataclasses import dataclass
from typing import Optional, Tuple
from enum import Enum

class IntentType(Enum):
    CALL = "call"
    ANSWER = "answer"
    HANGUP = "hangup"
    WHO_CALLING = "whoCalling"
    SEND_SMS = "sendSms"
    READ_SMS = "readSms"
    WHATSAPP_MESSAGE = "whatsappMessage"
    WHATSAPP_CALL = "whatsappCall"
    SET_ALARM = "setAlarm"
    SET_TIMER = "setTimer"
    CANCEL_ALARM = "cancelAlarm"
    UNKNOWN = "unknown"

@dataclass
class Intent:
    type: IntentType
    confidence: float
    language: str
    contact: Optional[str] = None
    message: Optional[str] = None
    time: Optional[str] = None

    @property
    def is_valid(self):
        return self.confidence >= 0.5

# ══════════════════════════════════════════════════════════════
# DICTIONNAIRES DE SYNONYMES (version corrigée)
# ══════════════════════════════════════════════════════════════

FR_WHATSAPP_VERBS = [
    'whatsapp', 'whatssap', 'watsap', 'watzap',
    'envoie un whatsapp', 'envoyer sur whatsapp',
    'message whatsapp', 'via whatsapp',
    'sur whatsapp', 'par whatsapp',
    'wattsap', 'whats app',
    'envoie whatsapp', 'envoyer whatsapp', 'envoi whatsapp',
    'un whatsapp', 'sur wa', 'wa message',
]

FR_WHATSAPP_CALL_VERBS = [
    'appel whatsapp', 'appelle sur whatsapp',
    'appel vidéo', 'appel video', 'appel vocal whatsapp',
    'vidéo call', 'video call',
    'appelle via whatsapp', 'appelle par whatsapp',
    'appelle sur wa', 'appel wa',
    'appeller whatsapp', 'appel via wa',
    'appelle whatsapp', 'appel whatsap',
]

FR_SMS_VERBS = [
    'envoie', 'envoyer', 'envois',
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
]

# ══════════════════════════════════════════════════════════════
# FONCTIONS UTILITAIRES
# ══════════════════════════════════════════════════════════════

def normalize(text: str) -> str:
    """Normaliser le texte (accents, ponctuation, espaces)"""
    text = text.lower()
    accents = {
        'àáâãäå': 'a', 'èéêë': 'e', 'ìíîï': 'i',
        'òóôõö': 'o', 'ùúûü': 'u', 'ç': 'c',
    }
    for chars, replacement in accents.items():
        for char in chars:
            text = text.replace(char, replacement)
    text = re.sub(r'[^\w\s]', ' ', text)
    text = re.sub(r'\s+', ' ', text)
    return text.strip()

def levenshtein(a: str, b: str) -> int:
    """Distance de Levenshtein"""
    if a == b:
        return 0
    if not a:
        return len(b)
    if not b:
        return len(a)
    matrix = [[0] * (len(b) + 1) for _ in range(len(a) + 1)]
    for i in range(len(a) + 1):
        matrix[i][0] = i
    for j in range(len(b) + 1):
        matrix[0][j] = j
    for i in range(1, len(a) + 1):
        for j in range(1, len(b) + 1):
            cost = 0 if a[i-1] == b[j-1] else 1
            matrix[i][j] = min(
                matrix[i-1][j] + 1,
                matrix[i][j-1] + 1,
                matrix[i-1][j-1] + cost
            )
    return matrix[len(a)][len(b)]

def match_with_entity(text: str, synonyms: list) -> Optional[Tuple[float, str]]:
    """Chercher le meilleur synonyme dans le texte"""
    best_score = 0.0
    best_verb = ''
    
    for synonym in synonyms:
        # Correspondance exacte → score 1.0
        if text.find(synonym) != -1:
            return (1.0, synonym)
        
        # Correspondance par mots individuels
        syn_words = synonym.split(' ')
        match_count = 0
        for word in syn_words:
            if len(word) > 3 and text.find(word) != -1:
                match_count += 1
        if syn_words:
            score = match_count / len(syn_words)
            if score > best_score:
                best_score = score
                best_verb = synonym
        
        # Distance Levenshtein pour les mots simples
        if len(synonym.split(' ')) == 1 and len(synonym) > 4:
            for word in text.split(' '):
                if len(word) > 3:
                    dist = levenshtein(word, synonym)
                    max_len = max(len(word), len(synonym))
                    score = 1.0 - (dist / max_len)
                    if score > 0.75 and score > best_score:
                        best_score = score
                        best_verb = synonym
    
    if best_score >= 0.5:
        return (best_score, best_verb)
    return None

def matches_any(text: str, synonyms: list) -> float:
    result = match_with_entity(text, synonyms)
    return result[0] if result else 0.0

def extract_contact_and_message(text: str, matched_verb: str) -> Tuple[Optional[str], Optional[str]]:
    """Extraire contact ET message"""
    remaining = text.replace(matched_verb, '', 1).strip()
    remaining = re.sub(r'^(a|à|au|le|la|un|une|mon|ma|to|the|my)\s+', '', remaining).strip()
    
    separators = re.compile(
        r'\s+(que|qu|pour dire|pour lui dire|dis lui|dis-lui|dis lui que'
        r'|en lui disant|le message|le texte|ceci|cela|disant|en disant'
        r'|that|saying|to say|the message)\s+',
        re.IGNORECASE
    )
    
    parts = separators.split(remaining)
    if len(parts) >= 2:
        contact_words = parts[0].strip().split(' ')
        contact_words = [w for w in contact_words if w][:2]
        contact = ' '.join(contact_words).strip()
        message = ' '.join(parts[1:]).strip()
        return (contact if contact else None, message if message else None)
    
    words = [w for w in remaining.split(' ') if w]
    if len(words) >= 3:
        return (words[0], ' '.join(words[1:]))
    if len(words) == 2:
        return (words[0], words[1])
    
    return (remaining if remaining else None, None)

# ══════════════════════════════════════════════════════════════
# MOTEUR NLU
# ══════════════════════════════════════════════════════════════

def recognize(raw_text: str) -> Intent:
    text = normalize(raw_text)
    if not text:
        return Intent(type=IntentType.UNKNOWN, confidence=0.0, language='fr')
    
    # ── WHATSAPP APPEL (vérifier AVANT WhatsApp message car "whatsapp" seul matche les deux) ──
    score_call = matches_any(text, FR_WHATSAPP_CALL_VERBS)
    if score_call > 0.5:
        return Intent(
            type=IntentType.WHATSAPP_CALL,
            confidence=score_call,
            language='fr',
            contact=None,  # Contact extraction simplifiée
        )
    
    # ── WHATSAPP MESSAGE ──
    wa_match = match_with_entity(text, FR_WHATSAPP_VERBS)
    if wa_match:
        contact, message = extract_contact_and_message(text, wa_match[1])
        return Intent(
            type=IntentType.WHATSAPP_MESSAGE,
            confidence=wa_match[0],
            language='fr',
            contact=contact,
            message=message,
        )
    
    return Intent(type=IntentType.UNKNOWN, confidence=0.0, language='fr')

# ══════════════════════════════════════════════════════════════
# TESTS
# ══════════════════════════════════════════════════════════════

def test_intent(name, raw_text, expected_type, expected_contact=None, expected_message=None):
    intent = recognize(raw_text)
    status = "✅" if intent.type == expected_type else "❌"
    
    details = []
    if intent.type != expected_type:
        details.append(f"type attendu={expected_type.value}, obtenu={intent.type.value}")
    if expected_contact and intent.contact != expected_contact:
        details.append(f"contact attendu={expected_contact}, obtenu={intent.contact}")
    if expected_message and intent.message != expected_message:
        details.append(f"message attendu={expected_message}, obtenu={intent.message}")
    
    detail_str = f" [{', '.join(details)}]" if details else ""
    print(f"{status} {name}: \"{raw_text}\" → {intent.type.value}{detail_str}")
    return intent.type == expected_type

print("=" * 60)
print("TESTS NLU — RECONNAISSANCE WHATSAPP")
print("=" * 60)

results = []

# Messages WhatsApp
results.append(test_intent(
    "WA MSG basique", "envoie whatsapp jean je suis en route",
    IntentType.WHATSAPP_MESSAGE, "jean", "je suis en route"
))

results.append(test_intent(
    "WA MSG avec 'à'", "envoie un whatsapp à marie le rendez-vous est reporté",
    IntentType.WHATSAPP_MESSAGE, "marie", "le rendez-vous est reporté"
))

results.append(test_intent(
    "WA MSG variante phonétique", "watsap pierre on se voit demain",
    IntentType.WHATSAPP_MESSAGE, "pierre", "on se voit demain"
))

results.append(test_intent(
    "WA MSG 'whatsapp' seul", "whatsapp jean je suis en retard",
    IntentType.WHATSAPP_MESSAGE, "jean", "je suis en retard"
))

results.append(test_intent(
    "WA MSG 'sur whatsapp'", "envoie un message sur whatsapp à paul salut",
    IntentType.WHATSAPP_MESSAGE, "paul", "salut"
))

# Appels WhatsApp
results.append(test_intent(
    "WA CALL basique", "appel whatsapp maman",
    IntentType.WHATSAPP_CALL
))

results.append(test_intent(
    "WA CALL 'appelle sur'", "appelle sur whatsapp jean pierre",
    IntentType.WHATSAPP_CALL
))

results.append(test_intent(
    "WA CALL 'wa' abrégé", "appel wa pierre",
    IntentType.WHATSAPP_CALL
))

# Edge cases
results.append(test_intent(
    "WA MSG prénom composé", "whatsapp jean pierre dis lui que je suis en retard",
    IntentType.WHATSAPP_MESSAGE, "jean", "pierre dis lui que je suis en retard"
))

# Non-WhatsApp (ne doit PAS matcher)
non_wa = recognize("bonjour comment ça va")
results.append(non_wa.type == IntentType.UNKNOWN)
print(f"{'✅' if non_wa.type == IntentType.UNKNOWN else '❌'} Non-WA: \"bonjour comment ça va\" → {non_wa.type.value}")

print("\n" + "=" * 60)
passed = sum(results)
total = len(results)
print(f"RÉSULTATS: {passed}/{total} tests passés ({passed/total*100:.0f}%)")
print("=" * 60)

# Test du WhatsAppService — format URL
print("\n" + "=" * 60)
print("TEST WHATSAPP SERVICE — FORMAT NUMÉRO")
print("=" * 60)

def to_international_no_plus(number: str) -> str:
    clean = re.sub(r'[\s\-\.\(\)\+]', '', number)
    if clean.startswith('0') and len(clean) == 10:
        clean = f'33{clean[1:]}'
    return clean

tests_phone = [
    ("0612345678", "33612345678"),
    ("+33612345678", "33612345678"),
    ("07 12 34 56 78", "33712345678"),
    ("33612345678", "33612345678"),
]

for raw, expected in tests_phone:
    result = to_international_no_plus(raw)
    status = "✅" if result == expected else "❌"
    print(f"{status} \"{raw}\" → \"{result}\" (attendu: \"{expected}\")")

# Test URL WhatsApp
print("\n" + "=" * 60)
print("TEST URL WHATSAPP")
print("=" * 60)

number = "0612345678"
clean = to_international_no_plus(number)
message = "Bonjour"
from urllib.parse import quote
encoded = quote(message)

url_msg = f"https://wa.me/{clean}?text={encoded}"
print(f"URL message: {url_msg}")
print(f"URL correcte (pas de +): {'✅' if '+' not in url_msg else '❌'}")

native_url = f"whatsapp://send?phone={clean}&text={encoded}"
print(f"URL native: {native_url}")
print(f"URL native sans +: {'✅' if '+' not in native_url else '❌'}")

print("\n✅ Tous les tests de format terminés.")
