import 'package:drift/drift.dart';

/// Cache local des contacts du téléphone
class ContactsCacheTable extends Table {
  @override
  String get tableName => 'contacts_cache';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get contactId => text()(); // ID natif Android
  TextColumn get displayName => text().withLength(min: 1, max: 150)();
  TextColumn get normalizedName => text()(); // minuscule sans accents
  TextColumn get phoneNumber => text().withLength(min: 1, max: 30)();
  TextColumn get phoneLabel => text().withDefault(const Constant('mobile'))();
  DateTimeColumn get cachedAt => dateTime()();
}

/// Commandes vocales reconnues (FR + EN)
class VoiceCommandsTable extends Table {
  @override
  String get tableName => 'voice_commands';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get pattern => text()(); // ex: "appelle %", "raccroche"
  TextColumn get action => text()();  // CALL | ANSWER | HANGUP | WHO_CALLING
  TextColumn get language => text()(); // fr | en
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}
