import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:vosk_flutter/vosk_flutter.dart';

enum VoiceLanguage { french, english }

enum RecognizerStatus { idle, loading, ready, listening, error }

class VoiceRecognizer {
  static const _modelPaths = {
    VoiceLanguage.french: 'assets/models/vosk-model-small-fr-0.22.zip',
    VoiceLanguage.english: 'assets/models/vosk-model-small-en-us-0.15.zip',
  };

  final VoskFlutterPlugin _vosk = VoskFlutterPlugin.instance();
  final ModelLoader _modelLoader = ModelLoader();
  Model? _frModel;
  Model? _enModel;
  Recognizer? _currentRecognizer;
  SpeechService? _speechService;

  RecognizerStatus _status = RecognizerStatus.idle;
  RecognizerStatus get status => _status;

  VoiceLanguage _currentLanguage = VoiceLanguage.french;
  VoiceLanguage get currentLanguage => _currentLanguage;

  // [FIX E033] Exposer les modèles chargés pour partage avec HotwordService
  // Évite de charger le modèle deux fois → prévient les OOM
  Model? get frModel => _frModel;
  Model? get enModel => _enModel;

  final StreamController<String> _resultController =
      StreamController<String>.broadcast();
  Stream<String> get onResult => _resultController.stream;

  final StreamController<String> _partialController =
      StreamController<String>.broadcast();
  Stream<String> get onPartial => _partialController.stream;

  /// Initialiser les deux modèles au démarrage
  Future<void> initialize() async {
    _status = RecognizerStatus.loading;
    try {
      // createModel attend un dossier extrait, pas un chemin d’asset.
      // ModelLoader décompresse les archives dans le stockage de l’application.
      final frPath = await _modelLoader.loadFromAssets(
        _modelPaths[VoiceLanguage.french]!,
      );
      final enPath = await _modelLoader.loadFromAssets(
        _modelPaths[VoiceLanguage.english]!,
      );
      _frModel = await _vosk.createModel(frPath);
      _enModel = await _vosk.createModel(enPath);
      _status = RecognizerStatus.ready;
      debugPrint('✅ VoiceRecognizer: Modèles FR + EN chargés');
    } catch (e) {
      _status = RecognizerStatus.error;
      debugPrint('❌ VoiceRecognizer init error: $e');
      rethrow;
    }
  }

  /// Changer la langue d'écoute
  Future<void> setLanguage(VoiceLanguage language) async {
    if (_currentLanguage == language) return;
    await stopListening();
    _currentLanguage = language;
    debugPrint('🌐 Langue changée: ${language.name}');
  }

  /// Démarrer l'écoute
  Future<void> startListening() async {
    if (_status != RecognizerStatus.ready) {
      debugPrint('⚠️ Recognizer pas prêt: $_status');
      return;
    }

    final model = _currentLanguage == VoiceLanguage.french
        ? _frModel
        : _enModel;

    if (model == null) {
      debugPrint('❌ Modèle non chargé pour $_currentLanguage');
      return;
    }

    try {
      _currentRecognizer = await _vosk.createRecognizer(
        model: model,
        sampleRate: 16000,
      );

      _speechService = await _vosk.initSpeechService(_currentRecognizer!);

      _speechService!.onResult().listen((result) {
        final text = _extractText(result);
        if (text.isNotEmpty) {
          debugPrint('🎙️ Résultat final: $text');
          _resultController.add(text);
        }
      });

      _speechService!.onPartial().listen((partial) {
        final text = _extractPartialText(partial);
        if (text.isNotEmpty) {
          _partialController.add(text);
        }
      });

      final started = await _speechService!.start(
        onRecognitionError: (Object error) {
          _status = RecognizerStatus.error;
          debugPrint('❌ Erreur du flux microphone/Vosk: $error');
        },
      );
      if (started == false) {
        throw StateError('Le service de reconnaissance Vosk n’a pas démarré');
      }
      _status = RecognizerStatus.listening;
      debugPrint('🎙️ Écoute démarrée (${_currentLanguage.name})');
    } catch (e) {
      _status = RecognizerStatus.error;
      debugPrint('❌ Erreur démarrage écoute: $e');
      rethrow;
    }
  }

  /// Arrêter l'écoute
  Future<void> stopListening() async {
    await _speechService?.stop();
    _speechService = null;
    _currentRecognizer?.dispose();
    _currentRecognizer = null;
    if (_status == RecognizerStatus.listening) {
      _status = RecognizerStatus.ready;
    }
    debugPrint('⏹️ Écoute arrêtée');
  }

  /// Extraire le texte du JSON Vosk: {"text": "appelle jean"}
  String _extractText(String json) {
    final match = RegExp(r'"text"\s*:\s*"([^"]*)"').firstMatch(json);
    return match?.group(1)?.trim() ?? '';
  }

  String _extractPartialText(String json) {
    final match = RegExp(r'"partial"\s*:\s*"([^"]*)"').firstMatch(json);
    return match?.group(1)?.trim() ?? '';
  }

  void dispose() {
    stopListening();
    _frModel?.dispose();
    _enModel?.dispose();
    _resultController.close();
    _partialController.close();
  }
}
