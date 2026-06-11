import 'package:drift/drift.dart';

/// Table historique des appels
class CallHistoryTable extends Table {
  @override
  String get tableName => 'call_history';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get contactName => text().withLength(min: 1, max: 150)();
  TextColumn get phoneNumber => text().withLength(min: 1, max: 30)();
  TextColumn get callType => text()(); // OUTGOING | INCOMING | MISSED
  TextColumn get triggeredBy => text()(); // VOICE | MANUAL
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
  DateTimeColumn get calledAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}
