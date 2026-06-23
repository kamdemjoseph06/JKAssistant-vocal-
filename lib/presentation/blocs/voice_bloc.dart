import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/voice/voice_recognizer.dart';
import '../../core/voice/voice_synthesizer.dart';
import '../../core/voice/command_parser.dart';
import '../../core/services/sms_service.dart';
import '../../core/services/whatsapp_service.dart';
import '../../core/services/alarm_service.dart';
import '../../core/services/hotword_service.dart';
import '../../core/services/car_mode_service.dart';
import '../../domain/usecases/call_usecases.dart';
import '../../data/repositories/contact_repository.dart';

// ══════════════════════════════════════════════════════════
// EVENTS
// ══════════════════════════════════════════════════════════
abstract class VoiceEvent extends Equatable {
  const VoiceEvent();
  @override
  List<Object?> get props => [];
}
class VoiceInitialized extends VoiceEvent {}
class VoiceStartListening extends VoiceEvent {}
class VoiceStopListening extends VoiceEvent {}
class VoiceWakeWordDetected extends VoiceEvent {}
class VoiceTextReceived extends VoiceEvent {
  final String text;
  const VoiceTextReceived(this.text);
  @override List<Object?> get props => [text];
}
class VoicePartialReceived extends VoiceEvent {
  final String partial;
  const VoicePartialReceived(this.partial);
  @override List<Object?> get props => [partial];
}
class VoiceLanguageChanged extends VoiceEvent {
  final VoiceLanguage language;
  const VoiceLanguageChanged(this.language);
  @override List<Object?> get props => [language];
}
class VoiceContactsSynced extends VoiceEvent {}
class VoiceCarModeToggled extends VoiceEvent {}
class VoiceHotwordToggled extends VoiceEvent {}
class VoiceConfirmed extends VoiceEvent {}
class VoiceDenied extends VoiceEvent {}

// ══════════════════════════════════════════════════════════
// STATE
// ══════════════════════════════════════════════════════════
enum AssistantStatus { initializing, ready, listening, processing, speaking, error }

class VoiceState extends Equatable {
  final AssistantStatus status;
  final String displayText;
  final String partialText;
  final String? lastCommand;
  final String? errorMessage;
  final VoiceLanguage language;
  final bool contactsSynced;
  final int contactsCount;
  final bool carModeActive;
  final bool hotwordActive;
  final String? pendingConfirmation;
  final VoiceCommand? pendingCommand;
  final double lastConfidence;

  const VoiceState({
    this.status = AssistantStatus.initializing,
    this.displayText = '',
    this.partialText = '',
    this.lastCommand,
    this.errorMessage,
    this.language = VoiceLanguage.french,
    this.contactsSynced = false,
    this.contactsCount = 0,
    this.carModeActive = false,
    this.hotwordActive = false,
    this.pendingConfirmation,
    this.pendingCommand,
    this.lastConfidence = 0.0,
  });

  VoiceState copyWith({
    AssistantStatus? status, String? displayText, String? partialText,
    String? lastCommand, String? errorMessage, VoiceLanguage? language,
    bool? contactsSynced, int? contactsCount,
    bool? carModeActive, bool? hotwordActive,
    String? pendingConfirmation, VoiceCommand? pendingCommand,
    double? lastConfidence,
    bool clearPendingCommand = false,
    bool clearPendingConfirmation = false,
  }) => VoiceState(
    status: status ?? this.status,
    displayText: displayText ?? this.displayText,
    partialText: partialText ?? this.partialText,
    lastCommand: lastCommand ?? this.lastCommand,
    errorMessage: errorMessage ?? this.errorMessage,
    language: language ?? this.language,
    contactsSynced: contactsSynced ?? this.contactsSynced,
    contactsCount: contactsCount ?? this.contactsCount,
    carModeActive: carModeActive ?? this.carModeActive,
    hotwordActive: hotwordActive ?? this.hotwordActive,
    pendingConfirmation: clearPendingConfirmation ? null : (pendingConfirmation ?? this.pendingConfirmation),
    pendingCommand: clearPendingCommand ? null : (pendingCommand ?? this.pendingCommand),
    lastConfidence: lastConfidence ?? this.lastConfidence,
  );

  @override
  List<Object?> get props => [
    status, displayText, partialText, lastCommand, errorMessage,
    language, contactsSynced, contactsCount, carModeActive, hotwordActive,
    pendingConfirmation, pendingCommand, lastConfidence,
  ];
}

// ══════════════════════════════════════════════════════════
// BLOC
// ══════════════════════════════════════════════════════════
class VoiceBloc extends Bloc<VoiceEvent, VoiceState> {
  final VoiceRecognizer _recognizer;
  final VoiceSynthesizer _synthesizer;
  final CommandParser _parser;
  final MakeCallUseCase _makeCallUseCase;
  final SyncContactsUseCase _syncContactsUseCase;
  final ContactRepository _contactRepo;
  final SmsService _smsService;
  final WhatsAppService _whatsappService;
  final AlarmService _alarmService;
  final HotwordService _hotwordService;
  final CarModeService _carModeService;

  StreamSubscription<String>? _resultSub;
  StreamSubscription<String>? _partialSub;
  StreamSubscription<void>? _hotwordSub;

  VoiceBloc({
    required VoiceRecognizer recognizer,
    required VoiceSynthesizer synthesizer,
    required CommandParser parser,
    required MakeCallUseCase makeCallUseCase,
    required SyncContactsUseCase syncContactsUseCase,
    required ContactRepository contactRepo,
    required SmsService smsService,
    required WhatsAppService whatsappService,
    required AlarmService alarmService,
    required HotwordService hotwordService,
    required CarModeService carModeService,
  })  : _recognizer = recognizer,
        _synthesizer = synthesizer,
        _parser = parser,
        _makeCallUseCase = makeCallUseCase,
        _syncContactsUseCase = syncContactsUseCase,
        _contactRepo = contactRepo,
        _smsService = smsService,
        _whatsappService = whatsappService,
        _alarmService = alarmService,
        _hotwordService = hotwordService,
        _carModeService = carModeService,
        super(const VoiceState()) {
    on<VoiceInitialized>(_onInitialized);
    on<VoiceStartListening>(_onStartListening);
    on<VoiceStopListening>(_onStopListening);
    on<VoiceWakeWordDetected>(_onWakeWordDetected);
    on<VoiceTextReceived>(_onTextReceived);
    on<VoicePartialReceived>(_onPartialReceived);
    on<VoiceLanguageChanged>(_onLanguageChanged);
    on<VoiceContactsSynced>(_onContactsSynced);
    on<VoiceCarModeToggled>(_onCarModeToggled);
    on<VoiceHotwordToggled>(_onHotwordToggled);
    on<VoiceConfirmed>(_onConfirmed);
    on<VoiceDenied>(_onDenied);
  }

  Future<void> _onInitialized(VoiceInitialized event, Emitter<VoiceState> emit) async {
    try {
      emit(state.copyWith(status: AssistantStatus.initializing));
      await _recognizer.initialize();
      await _synthesizer.initialize();
      await AlarmService.initialize();
      final syncResult = await _syncContactsUseCase.execute();
      final count = syncResult.data ?? 0;
      _resultSub = _recognizer.onResult.listen((t) => add(VoiceTextReceived(t)));
      _partialSub = _recognizer.onPartial.listen((t) => add(VoicePartialReceived(t)));
      _hotwordSub = _hotwordService.onWakeWord.listen((_) => add(VoiceWakeWordDetected()));
      emit(state.copyWith(
        status: AssistantStatus.ready,
        displayText: 'Prêt. Dites "Appelle [nom]"',
        contactsSynced: true,
        contactsCount: count,
      ));
      await _synthesizer.speak(count > 0 ? 'Assistant prêt. $count contacts chargés.' : 'Assistant prêt.');
    } catch (e) {
      emit(state.copyWith(status: AssistantStatus.error, errorMessage: 'Erreur: $e'));
    }
  }

  Future<void> _onWakeWordDetected(VoiceWakeWordDetected event, Emitter<VoiceState> emit) async {
    if (state.status == AssistantStatus.listening) return;
    await _synthesizer.speak('Oui ?');
    await _recognizer.startListening();
    emit(state.copyWith(status: AssistantStatus.listening, displayText: 'Hey Vocal — J\'écoute...', partialText: ''));
  }

  Future<void> _onStartListening(VoiceStartListening event, Emitter<VoiceState> emit) async {
    await _recognizer.startListening();
    emit(state.copyWith(status: AssistantStatus.listening, displayText: 'J\'écoute...', partialText: ''));
  }

  Future<void> _onStopListening(VoiceStopListening event, Emitter<VoiceState> emit) async {
    await _recognizer.stopListening();
    emit(state.copyWith(status: AssistantStatus.ready, displayText: 'Appuyez pour parler', partialText: ''));
  }

  Future<void> _onTextReceived(VoiceTextReceived event, Emitter<VoiceState> emit) async {
    emit(state.copyWith(status: AssistantStatus.processing, displayText: event.text, partialText: ''));
    final command = _parser.parse(event.text);
    final lang = command.language;

    // [FIX E038] Si confidence entre 0.3 et 0.5, demander confirmation vocale
    // Si confidence < 0.3, commande trop incertaine → ignorer silencieusement avec feedback
    if (command.confidence < 0.3 && command.action != CommandAction.unknown) {
      final msg = lang == 'fr'
          ? 'Je n\'ai pas bien compris. Veuillez répéter.'
          : 'I didn\'t understand clearly. Please repeat.';
      await _synthesizer.speak(msg);
      emit(state.copyWith(
        status: AssistantStatus.ready,
        displayText: '❓ "${event.text}"',
        lastConfidence: command.confidence,
      ));
      return;
    }

    // [FIX E038] Confidence entre 0.3 et 0.75 sur commandes sensibles → demander confirmation
    if (command.confidence < 0.75 && command.confidence >= 0.3 &&
        _requiresConfirmation(command.action)) {
      final suggestion = _buildConfirmationText(command, lang);
      final confirmMsg = lang == 'fr'
          ? 'Vous voulez dire : $suggestion ?'
          : 'Did you mean: $suggestion?';
      await _synthesizer.speak(confirmMsg);
      emit(state.copyWith(
        status: AssistantStatus.ready,
        displayText: confirmMsg,
        pendingConfirmation: suggestion,
        pendingCommand: command,
        lastConfidence: command.confidence,
      ));
      return;
    }

    emit(state.copyWith(lastConfidence: command.confidence));
    await _dispatchCommand(command, event.text, emit);
  }

  /// Indique si une action nécessite une confirmation (actions sensibles)
  bool _requiresConfirmation(CommandAction action) {
    return action == CommandAction.call ||
        action == CommandAction.sendSms ||
        action == CommandAction.whatsappMessage ||
        action == CommandAction.whatsappCall;
  }

  /// Construire un texte de confirmation lisible
  String _buildConfirmationText(VoiceCommand command, String lang) {
    switch (command.action) {
      case CommandAction.call:
        return lang == 'fr'
            ? 'appeler ${command.contactName ?? "?"}'
            : 'call ${command.contactName ?? "?"}';
      case CommandAction.sendSms:
        return lang == 'fr'
            ? 'envoyer un SMS à ${command.contactName ?? "?"}'
            : 'send SMS to ${command.contactName ?? "?"}';
      case CommandAction.whatsappMessage:
        return lang == 'fr'
            ? 'envoyer WhatsApp à ${command.contactName ?? "?"}'
            : 'send WhatsApp to ${command.contactName ?? "?"}';
      case CommandAction.whatsappCall:
        return lang == 'fr'
            ? 'appel WhatsApp ${command.contactName ?? "?"}'
            : 'WhatsApp call ${command.contactName ?? "?"}';
      default:
        return command.rawText;
    }
  }

  Future<void> _dispatchCommand(VoiceCommand command, String rawText, Emitter<VoiceState> emit) async {
    final lang = command.language;
    switch (command.action) {
      case CommandAction.call:
        await _handleCall(command, emit);
      case CommandAction.answer:
        await _synthesizer.confirmAnswer(lang);
        emit(state.copyWith(status: AssistantStatus.ready, displayText: 'Appel décroché'));
      case CommandAction.hangup:
        await _synthesizer.confirmHangup(lang);
        emit(state.copyWith(status: AssistantStatus.ready, displayText: 'Appel terminé'));
      case CommandAction.whoCalling:
        await _synthesizer.speak(lang == 'fr' ? 'Consultation en cours' : 'Checking caller');
        emit(state.copyWith(status: AssistantStatus.ready));
      case CommandAction.sendSms:
        await _handleSendSms(command, emit);
      case CommandAction.readSms:
        await _handleReadSms(command, emit);
      case CommandAction.whatsappMessage:
        await _handleWhatsappMessage(command, emit);
      case CommandAction.whatsappCall:
        await _handleWhatsappCall(command, emit);
      case CommandAction.setAlarm:
        await _handleSetAlarm(command, emit);
      case CommandAction.setTimer:
        await _handleSetTimer(command, emit);
      case CommandAction.cancelAlarm:
        await _alarmService.cancelAlarm();
        final msg = lang == 'fr' ? 'Réveil annulé' : 'Alarm cancelled';
        await _synthesizer.speak(msg);
        emit(state.copyWith(status: AssistantStatus.ready, displayText: 'Réveil annulé'));
      case CommandAction.carModeOn:
        add(VoiceCarModeToggled());
      case CommandAction.carModeOff:
        add(VoiceCarModeToggled());
      case CommandAction.unknown:
        final msg = lang == 'fr' ? 'Commande non reconnue' : 'Command not recognized';
        await _synthesizer.speak(msg);
        emit(state.copyWith(status: AssistantStatus.ready, displayText: '? "$rawText"'));
    }
  }

  Future<void> _handleCall(VoiceCommand command, Emitter<VoiceState> emit) async {
    if (command.contactName == null) return;
    final result = await _makeCallUseCase.execute(spokenName: command.contactName!, triggeredBy: 'VOICE');
    if (result.success) {
      await _synthesizer.confirmCall(result.data!, command.language);
      emit(state.copyWith(status: AssistantStatus.ready, displayText: 'Appel: ${result.data}'));
    } else {
      await _synthesizer.contactNotFound(command.contactName!, command.language);
      emit(state.copyWith(status: AssistantStatus.ready, displayText: 'Contact introuvable: ${command.contactName}'));
    }
  }

  Future<void> _handleSendSms(VoiceCommand command, Emitter<VoiceState> emit) async {
    // [FIX E037] Vérifier que le message n'est pas null avant d'envoyer
    if (command.contactName == null) {
      final msg = command.language == 'fr' ? 'À qui envoyer le SMS ?' : 'Who should I send the SMS to?';
      await _synthesizer.speak(msg);
      emit(state.copyWith(status: AssistantStatus.ready, displayText: msg));
      return;
    }
    if (command.messageText == null) {
      final msg = command.language == 'fr' ? 'Quel est le message ?' : 'What is the message?';
      await _synthesizer.speak(msg);
      emit(state.copyWith(status: AssistantStatus.ready, displayText: msg));
      return;
    }
    final contact = await _contactRepo.findContact(command.contactName!);
    if (contact == null) {
      await _synthesizer.contactNotFound(command.contactName!, command.language);
      emit(state.copyWith(status: AssistantStatus.ready, displayText: 'Contact introuvable'));
      return;
    }
    final result = await _smsService.sendSms(
      phoneNumber: contact.phoneNumber,
      contactName: contact.displayName,
      message: command.messageText!,
    );
    final msg = result.success
        ? (command.language == 'fr' ? 'SMS envoyé à ${contact.displayName}' : 'SMS sent to ${contact.displayName}')
        : result.message;
    await _synthesizer.speak(msg);
    emit(state.copyWith(status: AssistantStatus.ready, displayText: msg));
  }

  Future<void> _handleReadSms(VoiceCommand command, Emitter<VoiceState> emit) async {
    final messages = await _smsService.getRecentSms(limit: 3);
    final speech = _smsService.formatSmsForSpeech(messages, command.language);
    await _synthesizer.speak(speech);
    emit(state.copyWith(status: AssistantStatus.ready, displayText: '${messages.length} messages'));
  }

  Future<void> _handleWhatsappMessage(VoiceCommand command, Emitter<VoiceState> emit) async {
    if (command.contactName == null) {
      final msg = command.language == 'fr' ? 'À qui envoyer le WhatsApp ?' : 'Who should I WhatsApp?';
      await _synthesizer.speak(msg);
      emit(state.copyWith(status: AssistantStatus.ready, displayText: msg));
      return;
    }
    if (command.messageText == null) {
      final msg = command.language == 'fr' ? 'Quel est le message ?' : 'What is the message?';
      await _synthesizer.speak(msg);
      emit(state.copyWith(status: AssistantStatus.ready, displayText: msg));
      return;
    }
    final contact = await _contactRepo.findContact(command.contactName!);
    if (contact == null) {
      await _synthesizer.contactNotFound(command.contactName!, command.language);
      emit(state.copyWith(status: AssistantStatus.ready, displayText: 'Contact introuvable'));
      return;
    }
    final result = await _whatsappService.sendMessage(
      phoneNumber: contact.phoneNumber,
      contactName: contact.displayName,
      message: command.messageText!,
    );
    final msg = result.success ? 'WhatsApp → ${contact.displayName}' : result.message;
    await _synthesizer.speak(msg);
    emit(state.copyWith(status: AssistantStatus.ready, displayText: msg));
  }

  Future<void> _handleWhatsappCall(VoiceCommand command, Emitter<VoiceState> emit) async {
    if (command.contactName == null) return;
    final contact = await _contactRepo.findContact(command.contactName!);
    if (contact == null) {
      await _synthesizer.contactNotFound(command.contactName!, command.language);
      emit(state.copyWith(status: AssistantStatus.ready));
      return;
    }
    await _whatsappService.makeCall(
      phoneNumber: contact.phoneNumber,
      contactName: contact.displayName,
    );
    final msg = command.language == 'fr'
        ? 'Appel WhatsApp ${contact.displayName}'
        : 'WhatsApp call ${contact.displayName}';
    await _synthesizer.speak(msg);
    emit(state.copyWith(status: AssistantStatus.ready, displayText: msg));
  }

  Future<void> _handleSetAlarm(VoiceCommand command, Emitter<VoiceState> emit) async {
    if (command.timeText == null) return;
    final result = await _alarmService.setAlarm(command.timeText!, command.language);
    await _synthesizer.speak(result.message);
    emit(state.copyWith(
      status: AssistantStatus.ready,
      displayText: result.message,
    ));
  }

  Future<void> _handleSetTimer(VoiceCommand command, Emitter<VoiceState> emit) async {
    if (command.timeText == null) return;
    final result = await _alarmService.setTimer(command.timeText!, command.language);
    await _synthesizer.speak(result.message);
    emit(state.copyWith(
      status: AssistantStatus.ready,
      displayText: result.message,
    ));
  }

  Future<void> _onCarModeToggled(VoiceCarModeToggled event, Emitter<VoiceState> emit) async {
    if (state.carModeActive) {
      final result = await _carModeService.deactivate();
      await _synthesizer.speak(result.message);
      emit(state.copyWith(carModeActive: false, displayText: 'Mode voiture désactivé'));
    } else {
      final result = await _carModeService.activate();
      await _synthesizer.speak(result.message);
      await _recognizer.startListening();
      emit(state.copyWith(
        carModeActive: true,
        status: AssistantStatus.listening,
        displayText: 'Mode voiture actif',
      ));
    }
  }

  Future<void> _onHotwordToggled(VoiceHotwordToggled event, Emitter<VoiceState> emit) async {
    if (state.hotwordActive) {
      await _hotwordService.stopListening();
      emit(state.copyWith(hotwordActive: false, displayText: 'Écoute permanente désactivée'));
    } else {
      // [FIX E033] Passer le modèle partagé pour éviter double chargement mémoire
      await _hotwordService.startListening(sharedModel: _recognizer.frModel);
      emit(state.copyWith(hotwordActive: true, displayText: 'Dites "Hey Vocal"'));
    }
  }

  Future<void> _onConfirmed(VoiceConfirmed event, Emitter<VoiceState> emit) async {
    if (state.pendingCommand != null) {
      await _dispatchCommand(state.pendingCommand!, state.pendingCommand!.rawText, emit);
    }
    emit(state.copyWith(
      clearPendingConfirmation: true,
      clearPendingCommand: true,
    ));
  }

  Future<void> _onDenied(VoiceDenied event, Emitter<VoiceState> emit) async {
    await _synthesizer.speak("D'accord, je recommence");
    emit(state.copyWith(
      clearPendingConfirmation: true,
      clearPendingCommand: true,
      status: AssistantStatus.ready,
      displayText: "J'écoute de nouveau...",
    ));
  }

  void _onPartialReceived(VoicePartialReceived event, Emitter<VoiceState> emit) {
    emit(state.copyWith(partialText: event.partial));
  }

  Future<void> _onLanguageChanged(VoiceLanguageChanged event, Emitter<VoiceState> emit) async {
    await _recognizer.setLanguage(event.language);
    emit(state.copyWith(
      language: event.language,
      displayText: event.language == VoiceLanguage.french ? 'Langue: Français' : 'Language: English',
    ));
  }

  Future<void> _onContactsSynced(VoiceContactsSynced event, Emitter<VoiceState> emit) async {
    final result = await _syncContactsUseCase.execute();
    emit(state.copyWith(contactsCount: result.data ?? 0, contactsSynced: result.success));
  }

  // [FIX E017] Toujours annuler les StreamSubscriptions dans close()
  @override
  Future<void> close() {
    _resultSub?.cancel();
    _partialSub?.cancel();
    _hotwordSub?.cancel();
    _recognizer.dispose();
    _synthesizer.dispose();
    _hotwordService.dispose();
    _carModeService.dispose();
    return super.close();
  }
}
