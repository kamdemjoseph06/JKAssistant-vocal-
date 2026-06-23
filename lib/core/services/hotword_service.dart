import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:vosk_flutter/vosk_flutter.dart';

class HotwordService {
  static bool _isRunning = false;
  static bool get isRunning => _isRunning;

  static const List<String> _hotwords = [
    'hey vocal', 'hey vocale', 'vocal', 'assistant', 'hey assistant',
    'allô', 'allo', 'hey', 'listen', 'wake up', 'hello',
  ];

  final VoskFlutterPlugin _vosk = VoskFlutterPlugin.instance();
  // [FIX E033] Le modèle est passé depuis VoiceRecognizer — pas rechargé ici
  Model? _model;
  bool _ownsModel = false; // true seulement si on a chargé le modèle nous-mêmes
  Recognizer? _recognizer;
  SpeechService? _speechService;

  final StreamController<void> _wakeWordController =
      StreamController<void>.broadcast();

  Stream<void> get onWakeWord => _wakeWordController.stream;

  DateTime? _lastTrigger;
  // [FIX E032] Cooldown 3s minimum — ne pas réduire
  static const _cooldown = Duration(seconds: 3);

  static Future<void> initForegroundTask() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'vocal_hotword',
        channelName: 'Écoute vocale',
        channelDescription:
            'Vocal Assist écoute "Hey Vocal" en arrière-plan',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(10000),
        // [FIX E028] autoRunOnBoot = true + permission RECEIVE_BOOT_COMPLETED dans AndroidManifest
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  /// Démarrer l'écoute hotword.
  /// [FIX E033] Passer sharedModel depuis VoiceRecognizer pour éviter double chargement.
  Future<void> startListening({Model? sharedModel}) async {
    if (_isRunning) return;

    try {
      await FlutterForegroundTask.startService(
        serviceId: 256,
        notificationTitle: '🎙️ Vocal Assist — En écoute',
        notificationText: 'Dites "Hey Vocal" pour activer',
        callback: _hotwordTaskCallback,
      );

      if (sharedModel != null) {
        // Utiliser le modèle partagé — pas de rechargement
        _model = sharedModel;
        _ownsModel = false;
        debugPrint('✅ HotwordService: utilise modèle partagé VoiceRecognizer');
      } else {
        // Fallback : charger le modèle si aucun partagé
        debugPrint('📥 HotwordService: chargement modèle Vosk (fallback)...');
        _model = await _vosk.createModel(
          'assets/models/vosk-model-small-fr-0.22',
        );
        _ownsModel = true;
      }

      // [FIX E031] Grammaire restreinte pour minimiser les faux positifs
      _recognizer = await _vosk.createRecognizer(
        model: _model!,
        sampleRate: 16000,
        grammar: _buildGrammar(),
      );

      _speechService = await _vosk.initSpeechService(_recognizer!);

      _speechService!.onResult().listen(_checkForHotword);
      _speechService!.onPartial().listen(_checkForHotword);

      await _speechService!.start();
      _isRunning = true;
      debugPrint('✅ HotwordService: écoute "Hey Vocal" démarrée (Vosk)');
    } catch (e) {
      debugPrint('❌ HotwordService.startListening error: $e');
      rethrow;
    }
  }

  Future<void> stopListening() async {
    if (!_isRunning) return;
    await _speechService?.stop();
    _speechService = null;
    _recognizer?.dispose();
    _recognizer = null;
    // [FIX E033] Ne disposer le modèle que si on en est propriétaire
    if (_ownsModel) {
      _model?.dispose();
    }
    _model = null;
    _ownsModel = false;
    await FlutterForegroundTask.stopService();
    _isRunning = false;
    debugPrint('⏹️ HotwordService: écoute arrêtée');
  }

  void _checkForHotword(String json) {
    final text = _extractText(json).toLowerCase().trim();
    if (text.isEmpty) return;
    final now = DateTime.now();
    // [FIX E032] Cooldown pour éviter double déclenchement
    if (_lastTrigger != null && now.difference(_lastTrigger!) < _cooldown) return;
    for (final hotword in _hotwords) {
      if (text.contains(hotword)) {
        _lastTrigger = now;
        debugPrint('🎙️ HOTWORD DÉTECTÉ: "$text" → "$hotword"');
        _wakeWordController.add(null);
        return;
      }
    }
  }

  List<String> _buildGrammar() {
    final words = <String>{};
    for (final hw in _hotwords) {
      words.addAll(hw.split(' '));
    }
    return words.toList();
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
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    debugPrint('🔄 HotwordTask détruit');
  }
}
