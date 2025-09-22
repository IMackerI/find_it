import 'dart:io';

import 'package:find_it/data/local_database.dart';
import 'package:find_it/models/item_model.dart';
import 'package:find_it/models/space_model.dart';
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
    final toolbox = SpaceModel(
      name: 'Toolbox',
      position: const Offset(5, 8),
      size: const Size(60, 40),
      items: [
        ItemModel(name: 'Hammer', description: 'Claw hammer'),
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

    final loadedToolbox = loadedGarage.mySpaces.single;
    expect(loadedToolbox.name, toolbox.name);
    expect(loadedToolbox.parent, same(loadedGarage));
    expect(loadedToolbox.position, toolbox.position);
    expect(loadedToolbox.size, toolbox.size);
    expect(loadedToolbox.items.single.name, 'Hammer');
    expect(loadedToolbox.items.single.parent, same(loadedToolbox));
  });
}
