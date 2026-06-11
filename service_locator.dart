import 'package:get_it/get_it.dart';
import 'core/voice/voice_recognizer.dart';
import 'core/voice/voice_synthesizer.dart';
import 'core/voice/command_parser.dart';
import 'core/services/sms_service.dart';
import 'core/services/whatsapp_service.dart';
import 'core/services/alarm_service.dart';
import 'core/services/hotword_service.dart';
import 'core/services/car_mode_service.dart';
import 'data/database/app_database.dart';
import 'data/repositories/contact_repository.dart';
import 'data/repositories/call_repository.dart';
import 'domain/usecases/call_usecases.dart';
import 'presentation/blocs/voice_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // ── Base de données SQL ───────────────────────────────────
  getIt.registerSingleton<AppDatabase>(AppDatabase());

  // ── Repositories ─────────────────────────────────────────
  getIt.registerSingleton<ContactRepository>(ContactRepository(getIt<AppDatabase>()));
  getIt.registerSingleton<CallRepository>(CallRepository(getIt<AppDatabase>()));

  // ── UseCases ─────────────────────────────────────────────
  getIt.registerSingleton<MakeCallUseCase>(MakeCallUseCase(getIt<ContactRepository>(), getIt<CallRepository>()));
  getIt.registerSingleton<SyncContactsUseCase>(SyncContactsUseCase(getIt<ContactRepository>()));
  getIt.registerSingleton<FindContactUseCase>(FindContactUseCase(getIt<ContactRepository>()));

  // ── Voix ─────────────────────────────────────────────────
  getIt.registerSingleton<VoiceRecognizer>(VoiceRecognizer());
  getIt.registerSingleton<VoiceSynthesizer>(VoiceSynthesizer());
  getIt.registerSingleton<CommandParser>(CommandParser());

  // ── Nouveaux services ─────────────────────────────────────
  getIt.registerSingleton<SmsService>(SmsService());
  getIt.registerSingleton<WhatsAppService>(WhatsAppService());
  getIt.registerSingleton<AlarmService>(AlarmService());
  getIt.registerSingleton<HotwordService>(HotwordService());
  getIt.registerSingleton<CarModeService>(CarModeService());

  // Initialiser le service foreground pour le hotword
  await HotwordService.initForegroundTask();

  // ── BLoC ─────────────────────────────────────────────────
  getIt.registerFactory<VoiceBloc>(
    () => VoiceBloc(
      recognizer: getIt<VoiceRecognizer>(),
      synthesizer: getIt<VoiceSynthesizer>(),
      parser: getIt<CommandParser>(),
      makeCallUseCase: getIt<MakeCallUseCase>(),
      syncContactsUseCase: getIt<SyncContactsUseCase>(),
      contactRepo: getIt<ContactRepository>(),
      smsService: getIt<SmsService>(),
      whatsappService: getIt<WhatsAppService>(),
      alarmService: getIt<AlarmService>(),
      hotwordService: getIt<HotwordService>(),
      carModeService: getIt<CarModeService>(),
    ),
  );
}
