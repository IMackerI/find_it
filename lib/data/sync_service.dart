import 'dart:async';

import 'package:flutter/foundation.dart';

import 'local_database.dart';
import 'remote/models.dart';
import 'remote/remote_api_client.dart';

typedef ConnectivityCheck = Future<bool> Function();

class SyncService {
  SyncService({
    required LocalDatabase database,
    required RemoteApiClient apiClient,
    Duration pollInterval = const Duration(minutes: 5),
    int maxBatchSize = 50,
    ConnectivityCheck? connectivityCheck,
  })  : _database = database,
        _apiClient = apiClient,
        _pollInterval = pollInterval,
        _maxBatchSize = maxBatchSize,
        _connectivityCheck = connectivityCheck ?? _alwaysConnected;

  final LocalDatabase _database;
  final RemoteApiClient _apiClient;
  final Duration _pollInterval;
  final int _maxBatchSize;
  final ConnectivityCheck _connectivityCheck;

  Timer? _timer;
  bool _isRunning = false;
  bool _isSyncing = false;
  String? _cursor;
  bool _cursorLoaded = false;

  static Future<bool> _alwaysConnected() async => true;

  bool get isRunning => _isRunning;

  void start() {
    if (_isRunning) {
      return;
    }
    _isRunning = true;
    _timer = Timer.periodic(_pollInterval, (_) {
      unawaited(syncNow());
    });
    unawaited(syncNow());
  }

  Future<void> syncNow() async {
    if (_isSyncing) {
      return;
    }
    _isSyncing = true;
    try {
      if (!await _connectivityCheck()) {
        return;
      }
      await _ensureCursorLoaded();
      var nextCursor = _cursor;
      var hasMore = true;
      while (hasMore) {
        final pending = await _database.getPendingMutations(
          limit: _maxBatchSize,
        );
        final request = SyncRequest(
          mutations: pending.map((mutation) => mutation.toSyncMutation()).toList(),
          cursor: _cursor,
        );
        final response = await _apiClient.sync(request);
        await _database.applyRemoteChanges(response);
        if (pending.isNotEmpty) {
          await _database.markMutationsProcessed(
            pending.map((mutation) => mutation.id).toList(),
          );
        }
        if (response.cursor != null) {
          nextCursor = response.cursor;
        }
        _cursor = nextCursor;
        hasMore = pending.length == _maxBatchSize;
        if (!hasMore) {
          break;
        }
      }
      _cursor = nextCursor;
      await _database.saveSyncCursor(_cursor);
    } catch (error, stackTrace) {
      debugPrint('SyncService error: $error\n$stackTrace');
    } finally {
      _isSyncing = false;
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  Future<void> dispose() async {
    stop();
    await _apiClient.dispose();
  }

  Future<void> _ensureCursorLoaded() async {
    if (_cursorLoaded) {
      return;
    }
    _cursor = await _database.loadSyncCursor();
    _cursorLoaded = true;
  }
}
