import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class AlarmService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Initialiser le service au démarrage
  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings =
        InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('🔔 Notification tappée: ${details.payload}');
      },
    );

    await AndroidAlarmManager.initialize();
    _initialized = true;
    debugPrint('✅ AlarmService initialisé');
  }

  /// Parser une heure depuis du texte vocal
  /// Exemples : "7 heures", "8h30", "midi", "7 hours", "8:30"
  DateTime? parseTimeText(String timeText) {
    final now = DateTime.now();
    final text = timeText.toLowerCase().trim();

    // ── Cas spéciaux FR ──
    if (text == 'midi') {
      return DateTime(now.year, now.month, now.day, 12, 0);
    }
    if (text == 'minuit') {
      return DateTime(now.year, now.month, now.day + 1, 0, 0);
    }

    // ── Format "8h30" ou "8h" ──
    final hhmm = RegExp(r'^(\d{1,2})h(\d{2})?$').firstMatch(text);
    if (hhmm != null) {
      final hour = int.parse(hhmm.group(1)!);
      final minute = int.tryParse(hhmm.group(2) ?? '0') ?? 0;
      var dt = DateTime(now.year, now.month, now.day, hour, minute);
      if (dt.isBefore(now)) dt = dt.add(const Duration(days: 1));
      return dt;
    }

    // ── Format "8:30" ──
    final colon = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(text);
    if (colon != null) {
      final hour = int.parse(colon.group(1)!);
      final minute = int.parse(colon.group(2)!);
      var dt = DateTime(now.year, now.month, now.day, hour, minute);
      if (dt.isBefore(now)) dt = dt.add(const Duration(days: 1));
      return dt;
    }

    // ── Format "7 heures" / "7 hours" ──
    final heures = RegExp(r'^(\d{1,2})\s+(?:heures?|hours?)$').firstMatch(text);
    if (heures != null) {
      final hour = int.parse(heures.group(1)!);
      var dt = DateTime(now.year, now.month, now.day, hour, 0);
      if (dt.isBefore(now)) dt = dt.add(const Duration(days: 1));
      return dt;
    }

    // ── Format "7 heures 30" ──
    final heuresMin = RegExp(
            r'^(\d{1,2})\s+(?:heures?|hours?)\s+(?:et\s+)?(\d{1,2})(?:\s+(?:minutes?|mins?))?$')
        .firstMatch(text);
    if (heuresMin != null) {
      final hour = int.parse(heuresMin.group(1)!);
      final minute = int.parse(heuresMin.group(2)!);
      var dt = DateTime(now.year, now.month, now.day, hour, minute);
      if (dt.isBefore(now)) dt = dt.add(const Duration(days: 1));
      return dt;
    }

    debugPrint('⚠️ Impossible de parser l\'heure: "$timeText"');
    return null;
  }

  /// Parser une durée depuis du texte vocal
  /// Exemples : "5 minutes", "30 secondes", "2 heures"
  Duration? parseDuration(String timeText) {
    final text = timeText.toLowerCase().trim();

    // "5 minutes" / "5 mins"
    final mins = RegExp(r'^(\d+)\s+(?:minutes?|mins?)$').firstMatch(text);
    if (mins != null) {
      return Duration(minutes: int.parse(mins.group(1)!));
    }

    // "30 secondes" / "30 seconds"
    final secs =
        RegExp(r'^(\d+)\s+(?:secondes?|seconds?|secs?)$').firstMatch(text);
    if (secs != null) {
      return Duration(seconds: int.parse(secs.group(1)!));
    }

    // "2 heures" / "2 hours"
    final hrs = RegExp(r'^(\d+)\s+(?:heures?|hours?)$').firstMatch(text);
    if (hrs != null) {
      return Duration(hours: int.parse(hrs.group(1)!));
    }

    // "1 heure 30" / "1 hour 30"
    final hrsMin = RegExp(
            r'^(\d+)\s+(?:heures?|hours?)\s+(?:et\s+)?(\d+)\s+(?:minutes?|mins?)?$')
        .firstMatch(text);
    if (hrsMin != null) {
      return Duration(
        hours: int.parse(hrsMin.group(1)!),
        minutes: int.parse(hrsMin.group(2)!),
      );
    }

    return null;
  }

  /// Créer un réveil à une heure précise
  Future<AlarmResult> setAlarm(String timeText, String lang) async {
    final alarmTime = parseTimeText(timeText);

    if (alarmTime == null) {
      final msg = lang == 'fr'
          ? 'Je n\'ai pas compris l\'heure. Dites par exemple: 7 heures 30'
          : 'I didn\'t understand the time. Say for example: 7 thirty';
      return AlarmResult.failure(msg);
    }

    try {
      const int alarmId = 1;

      // Programmer l'alarme native Android
      await AndroidAlarmManager.oneShotAt(
        alarmTime,
        alarmId,
        _alarmCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );

      // Afficher une notification confirmant l'alarme
      final timeFormatted =
          '${alarmTime.hour.toString().padLeft(2, '0')}:${alarmTime.minute.toString().padLeft(2, '0')}';

      await _showConfirmNotification(
        id: alarmId,
        title: lang == 'fr' ? '⏰ Réveil programmé' : '⏰ Alarm set',
        body: lang == 'fr'
            ? 'Réveil à $timeFormatted'
            : 'Alarm at $timeFormatted',
      );

      final msg = lang == 'fr'
          ? 'Réveil programmé à $timeFormatted'
          : 'Alarm set for $timeFormatted';

      debugPrint('✅ Alarme programmée à $alarmTime');
      return AlarmResult.success(msg, alarmTime);
    } catch (e) {
      debugPrint('❌ AlarmService.setAlarm error: $e');
      return AlarmResult.failure('Erreur création alarme: $e');
    }
  }

  /// Créer une minuterie (compte à rebours)
  Future<AlarmResult> setTimer(String timeText, String lang) async {
    final duration = parseDuration(timeText);

    if (duration == null) {
      final msg = lang == 'fr'
          ? 'Je n\'ai pas compris la durée. Dites par exemple: 5 minutes'
          : 'I didn\'t understand. Say for example: 5 minutes';
      return AlarmResult.failure(msg);
    }

    try {
      final triggerTime = DateTime.now().add(duration);
      const int timerId = 2;

      await AndroidAlarmManager.oneShotAt(
        triggerTime,
        timerId,
        _timerCallback,
        exact: true,
        wakeup: true,
      );

      // Formater la durée pour le retour vocal
      String durationStr;
      if (duration.inHours > 0) {
        durationStr = lang == 'fr'
            ? '${duration.inHours} heure${duration.inHours > 1 ? 's' : ''}'
            : '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
      } else if (duration.inMinutes > 0) {
        durationStr = lang == 'fr'
            ? '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}'
            : '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
      } else {
        durationStr = lang == 'fr'
            ? '${duration.inSeconds} secondes'
            : '${duration.inSeconds} seconds';
      }

      await _showConfirmNotification(
        id: timerId,
        title: lang == 'fr' ? '⏱️ Minuterie démarrée' : '⏱️ Timer started',
        body: lang == 'fr'
            ? 'Minuterie de $durationStr'
            : 'Timer for $durationStr',
      );

      final msg = lang == 'fr'
          ? 'Minuterie de $durationStr démarrée'
          : 'Timer for $durationStr started';

      debugPrint('✅ Timer: $duration');
      return AlarmResult.success(msg, triggerTime);
    } catch (e) {
      debugPrint('❌ AlarmService.setTimer error: $e');
      return AlarmResult.failure('Erreur minuterie: $e');
    }
  }

  /// Annuler le réveil / la minuterie
  Future<void> cancelAlarm() async {
    await AndroidAlarmManager.cancel(1);
    await AndroidAlarmManager.cancel(2);
    await _notifications.cancelAll();
    debugPrint('✅ Alarmes annulées');
  }

  /// Notification de confirmation
  Future<void> _showConfirmNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Alarmes',
      channelDescription: 'Notifications de réveil et minuterie',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }

  // Callbacks statiques pour Android Alarm Manager
  @pragma('vm:entry-point')
  static void _alarmCallback() {
    debugPrint('⏰ RÉVEIL DÉCLENCHÉ');
    // TODO: Jouer le son de réveil + notification
  }

  @pragma('vm:entry-point')
  static void _timerCallback() {
    debugPrint('⏱️ MINUTERIE TERMINÉE');
    // TODO: Jouer le son de minuterie + notification
  }
}

class AlarmResult {
  final bool success;
  final String message;
  final DateTime? scheduledTime;

  const AlarmResult.success(this.message, this.scheduledTime)
      : success = true;
  const AlarmResult.failure(this.message)
      : success = false,
        scheduledTime = null;
}
