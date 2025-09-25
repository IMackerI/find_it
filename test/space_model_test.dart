import 'dart:io';

import 'package:find_it/data/local_database.dart';
import 'package:find_it/data/spaces_repository.dart';
import 'package:find_it/models/item_model.dart';
import 'package:find_it/models/space_member.dart';
import 'package:find_it/models/space_model.dart';
import 'package:find_it/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this._documentsPath);

  final String _documentsPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => _documentsPath;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PathProviderPlatform originalPlatform;

  setUp(() {
    originalPlatform = PathProviderPlatform.instance;
  });

  tearDown(() {
    SpaceModel.updateCurrentSpaces(const <SpaceModel>[]);
    PathProviderPlatform.instance = originalPlatform;
  });

  group('SpaceModel serialization', () {
    test('toJson/fromJson preserves hierarchy and parents', () {
      final owner = UserProfile(
        id: 'user-owner',
        email: 'owner@example.com',
        displayName: 'Owner',
      );

      final closet = SpaceModel(
        name: 'Closet',
        position: const Offset(10, 20),
        size: const Size(30, 40),
        items: [
          ItemModel(
            name: 'Umbrella',
            description: 'Black umbrella',
          ),
        ],
      );

      final hallway = SpaceModel(
        name: 'Hallway',
        position: const Offset(1, 2),
        size: const Size(100, 200),
        mySpaces: [closet],
        items: [
          ItemModel(
            name: 'Shoes',
            description: 'Running shoes',
          ),
        ],
        collaborators: [
          SpaceMember(
            user: owner,
            role: SpaceRole.owner,
            joinedAt: DateTime.utc(2023, 4, 5),
          ),
        ],
      );

      final encoded = hallway.toJson();
      final decoded = SpaceModel.fromJson(encoded);

      expect(decoded.name, hallway.name);
      expect(decoded.position, hallway.position);
      expect(decoded.size, hallway.size);
      expect(decoded.mySpaces, hasLength(1));
      expect(decoded.items, hasLength(1));
      expect(decoded.collaborators, hasLength(1));
      expect(decoded.collaborators.single.user.email, owner.email);
      expect(decoded.collaborators.single.role, SpaceRole.owner);
      expect(decoded.collaborators.single.joinedAt?.toUtc(),
          DateTime.utc(2023, 4, 5));

      final decodedCloset = decoded.mySpaces.single;
      expect(decodedCloset.name, closet.name);
      expect(decodedCloset.parent, same(decoded));
      expect(decodedCloset.position, closet.position);
      expect(decodedCloset.size, closet.size);

      final decodedHallwayItem = decoded.items.single;
      expect(decodedHallwayItem.name, 'Shoes');
      expect(decodedHallwayItem.parent, same(decoded));

      final decodedClosetItem = decodedCloset.items.single;
      expect(decodedClosetItem.name, 'Umbrella');
      expect(decodedClosetItem.parent, same(decodedCloset));
    });

    test('assignParents attaches parent references recursively', () {
      final drawer = SpaceModel(
        name: 'Drawer',
        items: [
          ItemModel(name: 'Keys', description: 'Car keys'),
        ],
      );

      final bedroom = SpaceModel(
        name: 'Bedroom',
        mySpaces: [drawer],
        items: [
          ItemModel(name: 'Lamp', description: 'Desk lamp'),
        ],
      );

      final apartment = SpaceModel(
        name: 'Apartment',
        mySpaces: [bedroom],
      );

      apartment.assignParents();

      expect(apartment.parent, isNull);
      final assignedBedroom = apartment.mySpaces.single;
      expect(assignedBedroom.parent, same(apartment));

      final assignedDrawer = assignedBedroom.mySpaces.single;
      expect(assignedDrawer.parent, same(assignedBedroom));

      final bedroomItem = assignedBedroom.items.single;
      expect(bedroomItem.parent, same(assignedBedroom));

      final drawerItem = assignedDrawer.items.single;
      expect(drawerItem.parent, same(assignedDrawer));
    });

    test('saveItems and loadItems persist spaces via sqlite storage', () async {
      final tempDir = await Directory.systemTemp.createTemp('find_it_test');
      PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);

      final database = LocalDatabase();
      SpaceModel.configureStorage(SpacesRepository(database: database));

      final deskDrawer = SpaceModel(
        name: 'Desk drawer',
        items: [
          ItemModel(name: 'Notebook', description: 'Project notes'),
        ],
      );

      final office = SpaceModel(
        name: 'Home office',
        mySpaces: [deskDrawer],
        items: [
          ItemModel(name: 'Laptop', description: 'Work laptop'),
        ],
      );

      SpaceModel.updateCurrentSpaces([office]);

      final success = await SpaceModel.saveItems();
      expect(success, isTrue);

      final savedDatabase = File(p.join(tempDir.path, 'spaces.db'));
      expect(savedDatabase.existsSync(), isTrue);

      SpaceModel.updateCurrentSpaces(const <SpaceModel>[]);

      await SpaceModel.loadItems();

      expect(SpaceModel.currentSpaces, hasLength(1));
      final loadedOffice = SpaceModel.currentSpaces.single;
      expect(loadedOffice.name, office.name);
      expect(loadedOffice.items.single.name, 'Laptop');
      expect(loadedOffice.items.single.parent, same(loadedOffice));
      final loadedDrawer = loadedOffice.mySpaces.single;
      expect(loadedDrawer.name, deskDrawer.name);
      expect(loadedDrawer.parent, same(loadedOffice));
      expect(loadedDrawer.items.single.name, 'Notebook');
      expect(loadedDrawer.items.single.parent, same(loadedDrawer));

      await database.dispose();
      await tempDir.delete(recursive: true);
    });
  });
}
