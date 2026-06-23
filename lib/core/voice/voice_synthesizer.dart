import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceSynthesizer {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  Future<void> initialize() async {
    try {
      await _tts.setSharedInstance(true);
      // [FIX E013] awaitSpeakCompletion DOIT être true pour éviter superposition
      await _tts.awaitSpeakCompletion(true);
      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await setLanguage('fr-FR');

      _isInitialized = true;
      debugPrint('✅ VoiceSynthesizer initialisé');
    } catch (e) {
      debugPrint('❌ VoiceSynthesizer init error: $e');
      rethrow;
    }
  }

  // [FIX E014] Fallback langue si fr-FR non installé sur l'appareil
  Future<void> setLanguage(String languageCode) async {
    try {
      final available = await _tts.isLanguageAvailable(languageCode);
      if (available == true) {
        await _tts.setLanguage(languageCode);
      } else {
        // Tenter le code court (ex: 'fr' au lieu de 'fr-FR')
        final shortCode = languageCode.split('-').first;
        final shortAvailable = await _tts.isLanguageAvailable(shortCode);
        if (shortAvailable == true) {
          await _tts.setLanguage(shortCode);
          debugPrint('⚠️ Langue $languageCode indisponible, fallback sur $shortCode');
        } else {
          debugPrint('⚠️ Langue $languageCode et $shortCode indisponibles, langue système conservée');
        }
      }
    } catch (e) {
      debugPrint('❌ setLanguage error pour $languageCode: $e');
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) await initialize();
    await _tts.stop();
    debugPrint('🔊 TTS: $text');
    await _tts.speak(text);
  }

  Future<void> confirmCall(String contactName, String lang) async {
    final message = lang == 'fr'
        ? 'Appel de $contactName en cours'
        : 'Calling $contactName';
    await setLanguage(lang == 'fr' ? 'fr-FR' : 'en-US');
    await speak(message);
  }

  Future<void> confirmAnswer(String lang) async {
    final message = lang == 'fr' ? 'Appel décroché' : 'Call answered';
    await setLanguage(lang == 'fr' ? 'fr-FR' : 'en-US');
    await speak(message);
  }

  Future<void> confirmHangup(String lang) async {
    final message = lang == 'fr' ? 'Appel terminé' : 'Call ended';
    await setLanguage(lang == 'fr' ? 'fr-FR' : 'en-US');
    await speak(message);
  }

  Future<void> contactNotFound(String name, String lang) async {
    final message = lang == 'fr'
        ? 'Contact $name introuvable'
        : 'Contact $name not found';
    await setLanguage(lang == 'fr' ? 'fr-FR' : 'en-US');
    await speak(message);
  }

  Future<void> announceIncomingCall(String callerName, String lang) async {
    final message = lang == 'fr'
        ? 'Appel entrant de $callerName. Dites décroche ou raccroche.'
        : 'Incoming call from $callerName. Say answer or hang up.';
    await setLanguage(lang == 'fr' ? 'fr-FR' : 'en-US');
    await speak(message);
  }

  Future<void> stop() async => await _tts.stop();

  void dispose() {
    _tts.stop();
  }
}
