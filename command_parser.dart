import 'package:flutter/foundation.dart';
import 'intent_recognizer.dart';

// Garder CommandAction pour compatibilité avec le reste du projet
enum CommandAction {
  call, answer, hangup, whoCalling,
  sendSms, readSms,
  whatsappMessage, whatsappCall,
  setAlarm, setTimer, cancelAlarm,
  carModeOn, carModeOff,
  unknown,
}

class VoiceCommand {
  final CommandAction action;
  final String? contactName;
  final String? messageText;
  final String? timeText;
  final String language;
  final String rawText;
  final double confidence; // 0.0 → 1.0 — niveau de certitude

  const VoiceCommand({
    required this.action,
    required this.language,
    required this.rawText,
    this.contactName,
    this.messageText,
    this.timeText,
    this.confidence = 1.0,
  });

  @override
  String toString() =>
      'VoiceCommand(action: $action, contact: $contactName, '
      'msg: $messageText, time: $timeText, conf: ${confidence.toStringAsFixed(2)})';
}

/// Parser principal — utilise le moteur NLU IntentRecognizer
/// Comprend les phrases naturelles, les synonymes et les fautes légères
class CommandParser {
  final IntentRecognizer _nlu = IntentRecognizer();

  /// Parser une phrase vocale en commande exécutable
  VoiceCommand parse(String rawText) {
    if (rawText.trim().isEmpty) {
      return VoiceCommand(
        action: CommandAction.unknown,
        language: 'fr',
        rawText: rawText,
        confidence: 0.0,
      );
    }

    debugPrint('🎙️ CommandParser: "$rawText"');

    // Passer par le moteur NLU
    final intent = _nlu.recognize(rawText);

    debugPrint('🎯 Intent: ${intent.type} (conf: ${intent.confidence.toStringAsFixed(2)})');

    // Convertir l'Intent en VoiceCommand
    return VoiceCommand(
      action: _toCommandAction(intent.type),
      language: intent.language,
      rawText: rawText,
      contactName: intent.contact,
      messageText: intent.message,
      timeText: intent.time,
      confidence: intent.confidence,
    );
  }

  CommandAction _toCommandAction(IntentType type) {
    return switch (type) {
      IntentType.call            => CommandAction.call,
      IntentType.answer          => CommandAction.answer,
      IntentType.hangup          => CommandAction.hangup,
      IntentType.whoCalling      => CommandAction.whoCalling,
      IntentType.sendSms         => CommandAction.sendSms,
      IntentType.readSms         => CommandAction.readSms,
      IntentType.whatsappMessage => CommandAction.whatsappMessage,
      IntentType.whatsappCall    => CommandAction.whatsappCall,
      IntentType.setAlarm        => CommandAction.setAlarm,
      IntentType.setTimer        => CommandAction.setTimer,
      IntentType.cancelAlarm     => CommandAction.cancelAlarm,
      IntentType.carModeOn       => CommandAction.carModeOn,
      IntentType.carModeOff      => CommandAction.carModeOff,
      IntentType.unknown         => CommandAction.unknown,
    };
  }
}
