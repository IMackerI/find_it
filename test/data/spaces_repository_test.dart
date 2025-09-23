import 'package:flutter_test/flutter_test.dart';
import 'package:find_it/data/local_database.dart';
import 'package:find_it/data/spaces_repository.dart';
import 'package:find_it/models/space_model.dart';

class FakeClock {
  FakeClock(this._current);

  DateTime _current;

  DateTime now() => _current;

  DateTime get value => _current;

  void advance([Duration amount = const Duration(minutes: 1)]) {
    _current = _current.add(amount);
  }
}

void main() {
  group('SpacesRepository', () {
    late FakeClock clock;
    late LocalDatabase database;
    late SpacesRepository repository;

    setUp(() {
      clock = FakeClock(DateTime.utc(2024, 1, 1, 12));
      database = LocalDatabase(clock: clock.now);
      repository = SpacesRepository(database);
    });

    test('saveSpace enqueues mutation with updated metadata', () async {
      final SpaceModel space = SpaceModel(name: 'Kitchen');

      await repository.saveSpace(spaceId: 'space-1', space: space);

      final List<OutboxEntry> outbox = await database.getPendingMutations();
      expect(outbox, hasLength(1));

      final OutboxEntry entry = outbox.single;
      expect(entry.table, LocalDatabase.spacesTable);
      expect(entry.recordId, 'space-1');
      expect(entry.type, MutationType.upsert);

      final Map<String, dynamic> record = entry.record;
      expect(record['id'], 'space-1');
      expect(record['version'], 1);
      expect(record['is_deleted'], isFalse);
      expect(record['updated_at'], clock.value);

      final Map<String, dynamic> data =
          Map<String, dynamic>.from(record['data'] as Map<String, dynamic>);
      expect(data['name'], 'Kitchen');
    });

    test('saveSpace increments version on subsequent updates', () async {
      final SpaceModel space = SpaceModel(name: 'Office');
      await repository.saveSpace(spaceId: 'space-1', space: space);
      final DateTime firstUpdate =
          (await database.getPendingMutations()).single.record['updated_at']
              as DateTime;

      clock.advance(const Duration(minutes: 5));

      await repository.saveSpace(
        spaceId: 'space-1',
        space: SpaceModel(name: 'Office updated'),
      );

      final List<OutboxEntry> outbox = await database.getPendingMutations();
      expect(outbox, hasLength(2));

      final OutboxEntry second = outbox.last;
      final Map<String, dynamic> record = second.record;
      expect(record['version'], 2);
      expect(record['is_deleted'], isFalse);
      final DateTime secondUpdate = record['updated_at'] as DateTime;
      expect(secondUpdate.isAfter(firstUpdate), isTrue);
    });

    test('deleteSpace enqueues delete mutation with incremented version', () async {
      final SpaceModel space = SpaceModel(name: 'Garage');
      await repository.saveSpace(spaceId: 'space-2', space: space);
      clock.advance(const Duration(seconds: 30));

      await repository.deleteSpace('space-2');

      final List<OutboxEntry> outbox = await database.getPendingMutations();
      expect(outbox, hasLength(2));
      expect(outbox.first.type, MutationType.upsert);
      expect(outbox.last.type, MutationType.delete);

      final Map<String, dynamic> record = outbox.last.record;
      expect(record['version'], 2);
      expect(record['is_deleted'], isTrue);
      final DateTime deletedAt = record['updated_at'] as DateTime;
      expect(deletedAt.isAfter(clock.value.subtract(const Duration(seconds: 30))),
          isTrue);
    });
  });

  group('LocalDatabase', () {
    late FakeClock clock;
    late LocalDatabase database;
    late SpacesRepository repository;

    setUp(() {
      clock = FakeClock(DateTime.utc(2024, 2, 1));
      database = LocalDatabase(clock: clock.now);
      repository = SpacesRepository(database);
    });

    test('clearing the outbox rolls back on failure', () async {
      await repository.saveSpace(spaceId: 'space-1', space: SpaceModel(name: 'A'));
      clock.advance();
      await repository.saveSpace(spaceId: 'space-2', space: SpaceModel(name: 'B'));

      final List<int> ids =
          (await database.getPendingMutations()).map((e) => e.id).toList();

      expect(
        () => database.transaction((DatabaseTransaction txn) async {
          txn.clearOutboxEntries(<int>[ids.first, 999]);
        }),
        throwsStateError,
      );

      final List<int> persistedIds =
          (await database.getPendingMutations()).map((e) => e.id).toList();
      expect(persistedIds, ids);

      await database.clearOutboxEntries(ids);
      expect(await database.getPendingMutations(), isEmpty);
    });
  });
}
