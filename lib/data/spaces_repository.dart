import 'package:find_it/data/local_database.dart';
import 'package:find_it/models/space_model.dart';

/// Repository responsible for persisting [SpaceModel] instances and enqueueing
/// mutations for the sync engine.
class SpacesRepository {
  SpacesRepository(this._database);

  final LocalDatabase _database;

  /// Saves [space] identified by [spaceId] and enqueues the resulting mutation.
  Future<void> saveSpace({
    required String spaceId,
    required SpaceModel space,
  }) async {
    await _database.transaction((DatabaseTransaction txn) async {
      final LocalRecord record = txn.upsertSpace(
        id: spaceId,
        data: LocalDatabase.normalizeDataMap(space.toJson()),
      );
      txn.enqueueMutation(
        table: LocalDatabase.spacesTable,
        recordId: spaceId,
        type: MutationType.upsert,
        record: record.toMap(),
      );
    });
  }

  /// Marks the space identified by [spaceId] as deleted and enqueues the
  /// mutation to the outbox.
  Future<void> deleteSpace(String spaceId) async {
    await _database.transaction((DatabaseTransaction txn) async {
      final LocalRecord record = txn.markSpaceDeleted(spaceId);
      txn.enqueueMutation(
        table: LocalDatabase.spacesTable,
        recordId: spaceId,
        type: MutationType.delete,
        record: record.toMap(),
      );
    });
  }
}
