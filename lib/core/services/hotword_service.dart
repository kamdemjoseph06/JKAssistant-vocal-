import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:vosk_flutter/vosk_flutter.dart';

/// Service d'écoute permanente du mot déclencheur "Hey Vocal"
/// Utilise VOSK (déjà installé) — aucune clé, aucun compte, 100% offline
///
/// COMMENT ÇA MARCHE :
/// Vosk écoute en continu à faible consommation
/// Dès qu'il entend "hey vocal" ou "hey" → déclenche l'assistant
/// Beaucoup plus léger que la reconnaissance complète

class HotwordService {
  static bool _isRunning = false;
  static bool get isRunning => _isRunning;

  // Mots déclencheurs acceptés (FR + EN)
  // Vosk peut mal prononcer certains mots → on accepte des variantes
  static const List<String> _hotwords = [
    // Français
    'hey vocal',
    'hey vocale',
    'vocal',
    'assistant',
    'hey assistant',
    'allô',
    'allo',
    // Anglais
    'hey',
    'listen',
    'wake up',
    'hello',
  ];

  final VoskFlutterPlugin _vosk = VoskFlutterPlugin.instance();
  Model? _model;
  Recognizer? _recognizer;
  SpeechService? _speechService;

  final StreamController<void> _wakeWordController =
      StreamController<void>.broadcast();

  /// Stream déclenché quand le mot déclencheur est détecté
  Stream<void> get onWakeWord => _wakeWordController.stream;

  // Timestamp dernier déclenchement (évite les doubles détections)
  DateTime? _lastTrigger;
  static const _cooldown = Duration(seconds: 3);

  /// Initialiser le service foreground Android
  static Future<void> initForegroundTask() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'vocal_hotword',
        channelName: 'Écoute vocale',
        channelDescription: 'Vocal Assist écoute "Hey Vocal" en arrière-plan',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        // ⚠️ ERRORS_LOG [E027]: iconData OBLIGATOIRE sinon service tué
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 10000,
        isOnceEvent: false,
        autoRunOnBoot: true,   // Redémarre après reboot téléphone
        allowWakeLock: true,   // CPU actif pour écouter
        allowWifiLock: false,
      ),
    );
  }

  /// Démarrer l'écoute permanente du mot déclencheur
  Future<void> startListening({Model? sharedModel}) async {
    if (_isRunning) return;

    try {
      // Démarrer le service foreground Android
      // (notification visible = service protégé par Android)
      await FlutterForegroundTask.startService(
        notificationTitle: '🎙️ Vocal Assist — En écoute',
        notificationText: 'Dites "Hey Vocal" pour activer',
        callback: _hotwordTaskCallback,
      );

      // Réutiliser le modèle Vosk déjà chargé si disponible
      // sinon charger le modèle FR (plus léger)
      _model = sharedModel;
      if (_model == null) {
        debugPrint('📥 HotwordService: chargement modèle Vosk...');
        _model = await _vosk.createModel(
          'assets/models/vosk-model-small-fr-0.22',
        );
      }

      // Créer un recognizer avec grammaire limitée aux hotwords
      // ⚠️ Grammaire restreinte = beaucoup plus rapide + économe
      final grammar = _buildGrammar();
      _recognizer = await _vosk.createRecognizer(
        model: _model!,
        sampleRate: 16000,
        grammar: grammar,
      );

      _speechService = await _vosk.initSpeechService(_recognizer!);

      // Écouter les résultats Vosk
      _speechService!.onResult().listen((result) {
        _checkForHotword(result);
      });

      _speechService!.onPartial().listen((partial) {
        _checkForHotword(partial);
      });

      await _speechService!.start();
      _isRunning = true;
      debugPrint('✅ HotwordService: écoute "Hey Vocal" démarrée (Vosk)');
    } catch (e) {
      debugPrint('❌ HotwordService.startListening error: $e');
      rethrow;
    }
  }

  /// Arrêter l'écoute
  Future<void> stopListening() async {
    if (!_isRunning) return;

    await _speechService?.stop();
    _speechService = null;
    _recognizer?.dispose();
    _recognizer = null;

    await FlutterForegroundTask.stopService();
    _isRunning = false;
    debugPrint('⏹️ HotwordService: écoute arrêtée');
  }

  /// Vérifier si le texte reconnu contient un mot déclencheur
  void _checkForHotword(String json) {
    // Extraire le texte du JSON Vosk
    final text = _extractText(json).toLowerCase().trim();
    if (text.isEmpty) return;

    // Cooldown — éviter les déclenchements multiples
    final now = DateTime.now();
    if (_lastTrigger != null &&
        now.difference(_lastTrigger!) < _cooldown) {
      return;
    }

    // Vérifier si un hotword est présent
    for (final hotword in _hotwords) {
      if (text.contains(hotword)) {
        _lastTrigger = now;
        debugPrint('🎙️ HOTWORD DÉTECTÉ: "$text" → "$hotword"');
        _wakeWordController.add(null);
        return;
      }
    }
  }

  /// Construire une grammaire Vosk limitée aux hotwords
  /// Cela rend la détection BEAUCOUP plus rapide et précise
  String _buildGrammar() {
    final words = <String>{};
    for (final hw in _hotwords) {
      words.addAll(hw.split(' '));
    }
    // Format JSON attendu par Vosk
    final wordList = words.map((w) => '"$w"').join(', ');
    return '[$wordList]';
  }

  /// Extraire le texte du JSON Vosk
  String _extractText(String json) {
    // Résultat final: {"text": "hey vocal"}
    var match = RegExp(r'"text"\s*:\s*"([^"]*)"').firstMatch(json);
    if (match != null) return match.group(1) ?? '';
    // Résultat partiel: {"partial": "hey"}
    match = RegExp(r'"partial"\s*:\s*"([^"]*)"').firstMatch(json);
    return match?.group(1) ?? '';
  }

  /// Déclencher manuellement pour les tests
  void triggerWakeWord() {
    debugPrint('🎙️ Wake word déclenché manuellement');
    _wakeWordController.add(null);
  }

  void dispose() {
    stopListening();
    _wakeWordController.close();
  }
}

/// Callback top-level obligatoire pour Android Alarm Manager
@pragma('vm:entry-point')
void _hotwordTaskCallback() {
  FlutterForegroundTask.setTaskHandler(_HotwordTaskHandler());
}

class _HotwordTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    debugPrint('🔄 HotwordTask démarré à $timestamp');
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // Vérification que le service est toujours actif
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    debugPrint('🔄 HotwordTask détruit');
  }
}
