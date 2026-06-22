import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/call_history_table.dart';

part 'call_history_dao.g.dart';

@DriftAccessor(tables: [CallHistoryTable])
class CallHistoryDao extends DatabaseAccessor<AppDatabase>
    with _$CallHistoryDaoMixin {
  CallHistoryDao(super.db);

  /// Récupérer tout l'historique, du plus récent au plus ancien
  Future<List<CallHistoryTableData>> getAllHistory() =>
      (select(callHistoryTable)
            ..orderBy([(t) => OrderingTerm.desc(t.calledAt)]))
          .get();

  /// Récupérer les N derniers appels
  Future<List<CallHistoryTableData>> getRecentCalls(int limit) =>
      (select(callHistoryTable)
            ..orderBy([(t) => OrderingTerm.desc(t.calledAt)])
            ..limit(limit))
          .get();

  /// Insérer un nouvel appel dans l'historique
  Future<int> insertCall(CallHistoryTableCompanion entry) =>
      into(callHistoryTable).insert(entry);

  /// Supprimer tout l'historique
  Future<int> clearHistory() => delete(callHistoryTable).go();

  /// Appels non synchronisés (pour future sync backend)
  Future<List<CallHistoryTableData>> getUnsyncedCalls() =>
      (select(callHistoryTable)
            ..where((t) => t.synced.equals(false)))
          .get();

  /// Marquer comme synchronisé
  Future<void> markSynced(int id) => (update(callHistoryTable)
        ..where((t) => t.id.equals(id)))
      .write(const CallHistoryTableCompanion(synced: Value(true)));
}
