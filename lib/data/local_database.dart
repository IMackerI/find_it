import 'dart:async';

/// Signature for functions that provide the current [DateTime].
typedef DateTimeProvider = DateTime Function();

/// The type of mutation represented inside the local outbox.
enum MutationType { upsert, delete }

/// A lightweight local database that keeps track of domain records, metadata
/// about their changes and an outbox with pending mutations to be processed by
/// a sync engine.
class LocalDatabase {
  LocalDatabase({DateTimeProvider? clock})
      : _clock = clock ?? DateTime.now,
        _state = _DatabaseState();

  /// Name of the table that stores space records.
  static const String spacesTable = 'spaces';

  /// Name of the outbox table that stores pending mutations.
  static const String outboxTable = 'outbox';

  final DateTimeProvider _clock;
  _DatabaseState _state;
  bool _isInTransaction = false;

  /// Runs [action] in a transactional context. All mutations performed inside
  /// the callback are committed atomically. If an error is thrown the state is
  /// rolled back to the point before the transaction started.
  Future<T> transaction<T>(Future<T> Function(DatabaseTransaction txn) action) async {
    if (_isInTransaction) {
      throw StateError('Nested transactions are not supported.');
    }

    _isInTransaction = true;
    final _DatabaseState workingState = _state.clone();
    final DatabaseTransaction transaction =
        DatabaseTransaction._(workingState, _clock);
    try {
      final T result = await action(transaction);
      _state = workingState;
      return result;
    } finally {
      _isInTransaction = false;
    }
  }

  /// Persists a record for the space identified by [id]. The record will have
  /// its metadata updated according to the mutation rules. When called outside a
  /// transaction a dedicated transaction will be opened.
  Future<LocalRecord> upsertSpace({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return transaction((DatabaseTransaction txn) async {
      return txn.upsertSpace(id: id, data: data);
    });
  }

  /// Marks the space identified by [id] as deleted.
  Future<LocalRecord> markSpaceDeleted(String id) {
    return transaction((DatabaseTransaction txn) async {
      return txn.markSpaceDeleted(id);
    });
  }

  /// Adds a mutation to the outbox outside of a broader transaction.
  Future<OutboxEntry> appendOutboxMutation({
    required String table,
    required String recordId,
    required MutationType type,
    required Map<String, dynamic> record,
  }) {
    return transaction((DatabaseTransaction txn) async {
      return txn.enqueueMutation(
        table: table,
        recordId: recordId,
        type: type,
        record: record,
      );
    });
  }

  /// Returns all pending mutations in the order they were enqueued.
  Future<List<OutboxEntry>> getPendingMutations() async {
    final List<OutboxEntry> entries = _state.outbox.values.toList()
      ..sort((OutboxEntry a, OutboxEntry b) => a.id.compareTo(b.id));
    return List<OutboxEntry>.unmodifiable(entries);
  }

  /// Removes the outbox entries identified by [ids]. The operation is executed
  /// inside a transaction to guarantee atomic behaviour.
  Future<void> clearOutboxEntries(Iterable<int> ids) {
    return transaction((DatabaseTransaction txn) async {
      txn.clearOutboxEntries(ids);
    });
  }

  /// Retrieves an immutable view of the space record identified by [id].
  Future<LocalRecord?> getSpaceRecord(String id) async {
    final _MutableRecord? record = _state.spaces[id];
    return record?.toImmutable();
  }

  /// Converts a [Map] that potentially contains non-string keys into a
  /// canonical `Map<String, dynamic>` with recursively cloned values.
  static Map<String, dynamic> normalizeDataMap(Map<dynamic, dynamic> map) {
    return _cloneMap(map);
  }
}

/// A view over the database state used during transactions. All mutations are
/// performed against a working copy until the transaction commits.
class DatabaseTransaction {
  DatabaseTransaction._(this._state, this._clock);

  final _DatabaseState _state;
  final DateTimeProvider _clock;

  /// Upserts the space identified by [id] with the provided [data]. Metadata
  /// fields are updated on every mutation.
  LocalRecord upsertSpace({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final Map<String, dynamic> normalizedData = _cloneMap(data);
    final DateTime now = _clock();
    final _MutableRecord? existing = _state.spaces[id];

    if (existing == null) {
      final _MutableRecord record = _MutableRecord(
        id: id,
        data: normalizedData,
        updatedAt: now,
        version: 1,
        isDeleted: false,
      );
      _state.spaces[id] = record;
      return record.toImmutable();
    }

    existing
      ..data = normalizedData
      ..updatedAt = now
      ..version = existing.version + 1
      ..isDeleted = false;

    return existing.toImmutable();
  }

  /// Marks the space identified by [id] as deleted and increments its version.
  LocalRecord markSpaceDeleted(String id) {
    final DateTime now = _clock();
    final _MutableRecord? existing = _state.spaces[id];

    if (existing == null) {
      final _MutableRecord record = _MutableRecord(
        id: id,
        data: const <String, dynamic>{},
        updatedAt: now,
        version: 1,
        isDeleted: true,
      );
      _state.spaces[id] = record;
      return record.toImmutable();
    }

    existing
      ..updatedAt = now
      ..version = existing.version + 1
      ..isDeleted = true;

    return existing.toImmutable();
  }

  /// Enqueues a new mutation in the outbox and returns the resulting entry.
  OutboxEntry enqueueMutation({
    required String table,
    required String recordId,
    required MutationType type,
    required Map<String, dynamic> record,
  }) {
    final int id = _state.nextOutboxId++;
    final DateTime createdAt = _clock();
    final OutboxEntry entry = OutboxEntry(
      id: id,
      table: table,
      recordId: recordId,
      type: type,
      record: record,
      createdAt: createdAt,
    );
    _state.outbox[id] = entry;
    return entry;
  }

  /// Removes the outbox entries identified by [ids]. If any of the identifiers
  /// does not exist the operation will throw a [StateError] and no entries are
  /// removed.
  void clearOutboxEntries(Iterable<int> ids) {
    final List<int> idList = List<int>.from(ids);
    for (final int id in idList) {
      if (!_state.outbox.containsKey(id)) {
        throw StateError('Outbox entry $id does not exist.');
      }
    }
    for (final int id in idList) {
      _state.outbox.remove(id);
    }
  }
}

/// Immutable view of a locally stored record.
class LocalRecord {
  LocalRecord({
    required this.id,
    required Map<String, dynamic> data,
    required this.updatedAt,
    required this.version,
    required this.isDeleted,
  }) : data = Map<String, dynamic>.unmodifiable(_cloneMap(data));

  final String id;
  final Map<String, dynamic> data;
  final DateTime updatedAt;
  final int version;
  final bool isDeleted;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'data': _cloneMap(data),
      'updated_at': updatedAt,
      'version': version,
      'is_deleted': isDeleted,
    };
  }
}

/// Entry inside the outbox with metadata about the pending mutation.
class OutboxEntry {
  OutboxEntry({
    required this.id,
    required this.table,
    required this.recordId,
    required this.type,
    required Map<String, dynamic> record,
    required this.createdAt,
  }) : record = Map<String, dynamic>.unmodifiable(_cloneMap(record));

  final int id;
  final String table;
  final String recordId;
  final MutationType type;
  final Map<String, dynamic> record;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'table': table,
      'record_id': recordId,
      'mutation_type': type.name,
      'record': _cloneMap(record),
      'created_at': createdAt,
    };
  }
}

class _DatabaseState {
  _DatabaseState({
    Map<String, _MutableRecord>? spaces,
    Map<int, OutboxEntry>? outbox,
    this.nextOutboxId = 1,
  })  : spaces = spaces ?? <String, _MutableRecord>{},
        outbox = outbox ?? <int, OutboxEntry>{};

  final Map<String, _MutableRecord> spaces;
  final Map<int, OutboxEntry> outbox;
  int nextOutboxId;

  _DatabaseState clone() {
    final Map<String, _MutableRecord> clonedSpaces =
        <String, _MutableRecord>{};
    spaces.forEach((String key, _MutableRecord value) {
      clonedSpaces[key] = value.copy();
    });
    final Map<int, OutboxEntry> clonedOutbox = <int, OutboxEntry>{};
    outbox.forEach((int key, OutboxEntry value) {
      clonedOutbox[key] = value;
    });
    return _DatabaseState(
      spaces: clonedSpaces,
      outbox: clonedOutbox,
      nextOutboxId: nextOutboxId,
    );
  }
}

class _MutableRecord {
  _MutableRecord({
    required this.id,
    required Map<String, dynamic> data,
    required this.updatedAt,
    required this.version,
    required this.isDeleted,
  }) : data = _cloneMap(data);

  final String id;
  Map<String, dynamic> data;
  DateTime updatedAt;
  int version;
  bool isDeleted;

  _MutableRecord copy() {
    return _MutableRecord(
      id: id,
      data: data,
      updatedAt: updatedAt,
      version: version,
      isDeleted: isDeleted,
    );
  }

  LocalRecord toImmutable() {
    return LocalRecord(
      id: id,
      data: data,
      updatedAt: updatedAt,
      version: version,
      isDeleted: isDeleted,
    );
  }
}

dynamic _cloneValue(dynamic value) {
  if (value is Map) {
    return _cloneMap(Map<dynamic, dynamic>.from(value));
  }
  if (value is Iterable) {
    return value.map(_cloneValue).toList();
  }
  if (value is DateTime) {
    return DateTime.fromMillisecondsSinceEpoch(
      value.millisecondsSinceEpoch,
      isUtc: value.isUtc,
    );
  }
  return value;
}

Map<String, dynamic> _cloneMap(Map<dynamic, dynamic> map) {
  final Map<String, dynamic> result = <String, dynamic>{};
  map.forEach((dynamic key, dynamic value) {
    result[key.toString()] = _cloneValue(value);
  });
  return result;
}
