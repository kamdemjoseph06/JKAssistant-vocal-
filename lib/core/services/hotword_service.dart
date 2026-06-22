import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:vosk_flutter/vosk_flutter.dart';

/// Service d'écoute permanente du mot déclencheur "Hey Vocal"
/// Utilise VOSK (déjà installé) — aucune clé, aucun compte, 100% offline
class HotwordService {
  static bool _isRunning = false;
  static bool get isRunning => _isRunning;

  static const List<String> _hotwords = [
    'hey vocal', 'hey vocale', 'vocal', 'assistant', 'hey assistant',
    'allô', 'allo', 'hey', 'listen', 'wake up', 'hello',
  ];

  final VoskFlutterPlugin _vosk = VoskFlutterPlugin.instance();
  Model? _model;
  Recognizer? _recognizer;
  SpeechService? _speechService;

  final StreamController<void> _wakeWordController =
      StreamController<void>.broadcast();

  Stream<void> get onWakeWord => _wakeWordController.stream;

  DateTime? _lastTrigger;
  static const _cooldown = Duration(seconds: 3);

  /// Initialiser le service foreground Android (API v8.x)
  static Future<void> initForegroundTask() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'vocal_hotword',
        channelName: 'Écoute vocale',
        channelDescription:
            'Vocal Assist écoute "Hey Vocal" en arrière-plan',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(10000),
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  /// Démarrer l'écoute permanente du mot déclencheur
  Future<void> startListening({Model? sharedModel}) async {
    if (_isRunning) return;

    try {
      await FlutterForegroundTask.startService(
        serviceId: 256,
        notificationTitle: '🎙️ Vocal Assist — En écoute',
        notificationText: 'Dites "Hey Vocal" pour activer',
        callback: _hotwordTaskCallback,
      );

      _model = sharedModel;
      if (_model == null) {
        debugPrint('📥 HotwordService: chargement modèle Vosk...');
        _model = await _vosk.createModel(
          'assets/models/vosk-model-small-fr-0.22',
        );
      }

      final grammar = _buildGrammar();
      _recognizer = await _vosk.createRecognizer(
        model: _model!,
        sampleRate: 16000,
        grammar: grammar,
      );

      _speechService = await _vosk.initSpeechService(_recognizer!);

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

  void _checkForHotword(String json) {
    final text = _extractText(json).toLowerCase().trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    if (_lastTrigger != null &&
        now.difference(_lastTrigger!) < _cooldown) return;

    for (final hotword in _hotwords) {
      if (text.contains(hotword)) {
        _lastTrigger = now;
        debugPrint('🎙️ HOTWORD DÉTECTÉ: "$text" → "$hotword"');
        _wakeWordController.add(null);
        return;
      }
    }
  }

  String _buildGrammar() {
    final words = <String>{};
    for (final hw in _hotwords) {
      words.addAll(hw.split(' '));
    }
    final wordList = words.map((w) => '"$w"').join(', ');
    return '[$wordList]';
  }

  String _extractText(String json) {
    var match = RegExp(r'"text"\s*:\s*"([^"]*)"').firstMatch(json);
    if (match != null) return match.group(1) ?? '';
    match = RegExp(r'"partial"\s*:\s*"([^"]*)"').firstMatch(json);
    return match?.group(1) ?? '';
  }

  void triggerWakeWord() {
    debugPrint('🎙️ Wake word déclenché manuellement');
    _wakeWordController.add(null);
  }

  void dispose() {
    stopListening();
    _wakeWordController.close();
  }
}

/// Callback top-level obligatoire pour Flutter Foreground Task
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
    // Vérification périodique que le service est actif
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    debugPrint('🔄 HotwordTask détruit');
  }
}
