import 'dart:io';

import 'package:find_it/data/local_database.dart';
import 'package:find_it/data/remote/models.dart';
import 'package:find_it/data/remote/remote_api_client.dart';
import 'package:find_it/data/sync_service.dart';
import 'package:find_it/models/item_model.dart';
import 'package:find_it/models/space_member.dart';
import 'package:find_it/models/space_model.dart';
import 'package:find_it/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this._documentsPath);

  final String _documentsPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => _documentsPath;
}

class FakeRemoteApiClient implements RemoteApiClient {
  FakeRemoteApiClient({this.handler});

  SyncResponse Function(SyncRequest request)? handler;
  final List<SyncRequest> capturedRequests = [];

  @override
  Future<SyncResponse> sync(SyncRequest request) async {
    capturedRequests.add(request);
    if (handler != null) {
      return handler!(request);
    }
    return SyncResponse.empty();
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Directory tempDir;
  late PathProviderPlatform originalPlatform;
  late LocalDatabase database;
  late FakeRemoteApiClient remoteApiClient;
  late SyncService syncService;

  setUp(() async {
    originalPlatform = PathProviderPlatform.instance;
    tempDir = await Directory.systemTemp.createTemp('sync_service_test');
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);
    database = LocalDatabase(factory: databaseFactoryFfi);
    remoteApiClient = FakeRemoteApiClient();
    syncService = SyncService(
      database: database,
      apiClient: remoteApiClient,
      pollInterval: const Duration(minutes: 10),
    );
  });

  tearDown(() async {
    await syncService.dispose();
    await database.dispose();
    PathProviderPlatform.instance = originalPlatform;
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('syncNow flushes outbox mutations and applies remote updates', () async {
    final owner = UserProfile(
      id: 'owner-user',
      email: 'owner@example.com',
      isCurrentUser: true,
    );

    final closet = SpaceModel(
      name: 'Closet',
      items: [
        ItemModel(name: 'Hat', description: 'Sun hat'),
      ],
      collaborators: [
        SpaceMember(user: owner, role: SpaceRole.owner),
      ],
    );
    closet.assignParents();

    await database.replaceAllSpaces([closet]);
    final pendingBefore = await database.getPendingMutations();
    expect(pendingBefore, isNotEmpty);

    final remoteNewItem = RemoteItem(
      id: 'remote-item-1',
      spaceId: closet.id,
      name: 'Scarf',
      description: 'Wool scarf',
      version: 1,
      updatedAt: DateTime.now().toUtc(),
      isDeleted: false,
    );

    final remoteSpace = RemoteSpace(
      id: closet.id,
      name: closet.name,
      positionDx: closet.position.dx,
      positionDy: closet.position.dy,
      sizeWidth: closet.size.width,
      sizeHeight: closet.size.height,
      parentId: null,
      version: 1,
      updatedAt: DateTime.now().toUtc(),
      isDeleted: false,
    );

    remoteApiClient.handler = (request) {
      expect(request.mutations, isNotEmpty);
      return SyncResponse(
        spaces: [remoteSpace],
        items: [remoteNewItem],
        users: const [],
        memberships: const [],
        cursor: 'cursor-1',
      );
    };

    await syncService.syncNow();

    final pendingAfter = await database.getPendingMutations();
    expect(pendingAfter, isEmpty);

    final loadedSpaces = await database.loadSpaces();
    expect(loadedSpaces, hasLength(1));
    final loadedCloset = loadedSpaces.single;
    expect(loadedCloset.items, hasLength(2));
    expect(
      loadedCloset.items.map((item) => item.name),
      containsAll(['Hat', 'Scarf']),
    );

    final dbFile = File(p.join(tempDir.path, 'spaces.db'));
    expect(dbFile.existsSync(), isTrue);
  });
}
