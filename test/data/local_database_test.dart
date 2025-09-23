import 'dart:io';

import 'package:find_it/data/local_database.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Directory tempDir;
  late PathProviderPlatform originalPlatform;
  late LocalDatabase database;

  setUp(() async {
    originalPlatform = PathProviderPlatform.instance;
    tempDir = await Directory.systemTemp.createTemp('local_database_test');
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);
    database = LocalDatabase(factory: databaseFactoryFfi);
  });

  tearDown(() async {
    await database.dispose();
    PathProviderPlatform.instance = originalPlatform;
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('round-trips spaces and items while restoring parents', () async {
    final owner = UserProfile(
      id: 'user-owner',
      email: 'owner@example.com',
      displayName: 'Owner',
      isCurrentUser: true,
    );

    final viewer = UserProfile(
      id: 'user-viewer',
      email: 'viewer@example.com',
      displayName: 'Viewer',
    );

    final toolbox = SpaceModel(
      name: 'Toolbox',
      position: const Offset(5, 8),
      size: const Size(60, 40),
      items: [
        ItemModel(name: 'Hammer', description: 'Claw hammer'),
      ],
      collaborators: [
        SpaceMember(
          user: owner,
          role: SpaceRole.editor,
          defaultAttachmentVisibility: AttachmentVisibility.private,
        ),
      ],
    );

    final garage = SpaceModel(
      name: 'Garage',
      position: const Offset(1, 2),
      size: const Size(200, 150),
      mySpaces: [toolbox],
      items: [
        ItemModel(name: 'Bike', description: 'Mountain bike'),
      ],
      collaborators: [
        SpaceMember(
          user: owner,
          role: SpaceRole.owner,
          joinedAt: DateTime.utc(2023, 1, 10),
        ),
        SpaceMember(
          user: viewer,
          role: SpaceRole.viewer,
          defaultAttachmentVisibility: AttachmentVisibility.private,
        ),
      ],
    );

    await database.replaceAllSpaces([garage]);

    final dbFile = File(p.join(tempDir.path, 'spaces.db'));
    expect(dbFile.existsSync(), isTrue);

    final loaded = await database.loadSpaces();
    expect(loaded, hasLength(1));

    final loadedGarage = loaded.single;
    expect(loadedGarage.name, garage.name);
    expect(loadedGarage.position, garage.position);
    expect(loadedGarage.size, garage.size);
    expect(loadedGarage.items, hasLength(1));
    expect(loadedGarage.items.single.name, 'Bike');
    expect(loadedGarage.items.single.parent, same(loadedGarage));

    expect(loadedGarage.collaborators, hasLength(2));
    final loadedOwner = loadedGarage.collaborators
        .firstWhere((member) => member.role == SpaceRole.owner);
    expect(loadedOwner.user.email, owner.email);
    expect(loadedOwner.user.isCurrentUser, isTrue);
    expect(loadedOwner.joinedAt?.toUtc(), DateTime.utc(2023, 1, 10));
    expect(loadedOwner.defaultAttachmentVisibility,
        AttachmentVisibility.shared);

    final loadedViewer = loadedGarage.collaborators
        .firstWhere((member) => member.role == SpaceRole.viewer);
    expect(loadedViewer.user.email, viewer.email);
    expect(loadedViewer.defaultAttachmentVisibility,
        AttachmentVisibility.private);

    final loadedToolbox = loadedGarage.mySpaces.single;
    expect(loadedToolbox.name, toolbox.name);
    expect(loadedToolbox.parent, same(loadedGarage));
    expect(loadedToolbox.position, toolbox.position);
    expect(loadedToolbox.size, toolbox.size);
    expect(loadedToolbox.items.single.name, 'Hammer');
    expect(loadedToolbox.items.single.parent, same(loadedToolbox));
    expect(loadedToolbox.collaborators, hasLength(1));
    expect(loadedToolbox.collaborators.single.role, SpaceRole.editor);
    expect(loadedToolbox.collaborators.single.defaultAttachmentVisibility,
        AttachmentVisibility.private);
  });

  test('replaceAllSpaces enqueues mutations only when data changes', () async {
    final owner = UserProfile(
      id: 'owner',
      email: 'owner@example.com',
      isCurrentUser: true,
    );

    final drawer = SpaceModel(
      name: 'Drawer',
      items: [
        ItemModel(name: 'Keys', description: 'Car keys'),
      ],
      collaborators: [
        SpaceMember(
          user: owner,
          role: SpaceRole.owner,
        ),
      ],
    );

    final hallway = SpaceModel(
      name: 'Hallway',
      mySpaces: [drawer],
    );
    hallway.assignParents();

    await database.replaceAllSpaces([hallway]);
    final initialMutations = await database.getPendingMutations();
    expect(initialMutations, isNotEmpty);
    await database.markMutationsProcessed(
      initialMutations.map((mutation) => mutation.id).toList(),
    );

    final unchangedCopy = SpaceModel.fromJson(hallway.toJson());
    unchangedCopy.assignParents();
    await database.replaceAllSpaces([unchangedCopy]);
    final noChangeMutations = await database.getPendingMutations();
    expect(noChangeMutations, isEmpty);

    final renamed = SpaceModel.fromJson(hallway.toJson());
    renamed.name = 'Renovated Hallway';
    renamed.assignParents();
    await database.replaceAllSpaces([renamed]);
    final updatedMutations = await database.getPendingMutations();
    expect(
      updatedMutations.where((mutation) =>
          mutation.entityType == 'space' && mutation.operation == 'upsert'),
      isNotEmpty,
    );
    await database.markMutationsProcessed(
      updatedMutations.map((mutation) => mutation.id).toList(),
    );
  });
}
