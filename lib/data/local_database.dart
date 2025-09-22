import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/item_model.dart';
import '../models/space_model.dart';

class LocalDatabase {
  LocalDatabase({DatabaseFactory? factory})
      : _databaseFactory = factory ?? databaseFactory;

  final DatabaseFactory _databaseFactory;
  Database? _database;

  static const _dbName = 'spaces.db';

  Future<Database> _openDatabase() async {
    final existing = _database;
    if (existing != null) {
      return existing;
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path, _dbName);
    final db = await _databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE spaces (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              position_dx REAL NOT NULL,
              position_dy REAL NOT NULL,
              size_width REAL NOT NULL,
              size_height REAL NOT NULL,
              parent_id TEXT,
              updated_at INTEGER NOT NULL,
              version INTEGER NOT NULL,
              is_deleted INTEGER NOT NULL
            );
          ''');

          await db.execute('''
            CREATE TABLE items (
              id TEXT PRIMARY KEY,
              space_id TEXT NOT NULL,
              name TEXT NOT NULL,
              description TEXT NOT NULL,
              location_specification TEXT,
              tags_json TEXT,
              image_path TEXT,
              updated_at INTEGER NOT NULL,
              version INTEGER NOT NULL,
              is_deleted INTEGER NOT NULL,
              FOREIGN KEY(space_id) REFERENCES spaces(id) ON DELETE CASCADE
            );
          ''');

          await db.execute(
            'CREATE INDEX idx_items_space_id ON items(space_id);',
          );
        },
      ),
    );
    _database = db;
    return db;
  }

  Future<void> replaceAllSpaces(List<SpaceModel> spaces) async {
    final db = await _openDatabase();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    await db.transaction((txn) async {
      await txn.delete('items');
      await txn.delete('spaces');

      Future<void> persistSpace(SpaceModel space, String? parentId) async {
        await txn.insert(
          'spaces',
          {
            'id': space.id,
            'name': space.name,
            'position_dx': space.position.dx,
            'position_dy': space.position.dy,
            'size_width': space.size.width,
            'size_height': space.size.height,
            'parent_id': parentId,
            'updated_at': timestamp,
            'version': 0,
            'is_deleted': 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        for (final item in space.items) {
          await txn.insert(
            'items',
            {
              'id': item.id,
              'space_id': space.id,
              'name': item.name,
              'description': item.description,
              'location_specification': item.locationSpecification,
              'tags_json': item.tags == null ? null : jsonEncode(item.tags),
              'image_path': item.imagePath,
              'updated_at': timestamp,
              'version': 0,
              'is_deleted': 0,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        for (final child in space.mySpaces) {
          await persistSpace(child, space.id);
        }
      }

      for (final root in spaces) {
        await persistSpace(root, null);
      }
    });
  }

  Future<List<SpaceModel>> loadSpaces() async {
    final db = await _openDatabase();

    final spaceRows = await db.query(
      'spaces',
      where: 'is_deleted = ?',
      whereArgs: [0],
    );

    if (spaceRows.isEmpty) {
      return [];
    }

    final itemRows = await db.query(
      'items',
      where: 'is_deleted = ?',
      whereArgs: [0],
    );

    final spacesById = <String, SpaceModel>{};
    for (final row in spaceRows) {
      final space = SpaceModel(
        id: row['id'] as String?,
        name: row['name'] as String,
        position: Offset(
          (row['position_dx'] as num).toDouble(),
          (row['position_dy'] as num).toDouble(),
        ),
        size: Size(
          (row['size_width'] as num).toDouble(),
          (row['size_height'] as num).toDouble(),
        ),
        mySpaces: const [],
        items: const [],
      );
      spacesById[space.id] = space;
    }

    for (final row in spaceRows) {
      final id = row['id'] as String;
      final parentId = row['parent_id'] as String?;
      final space = spacesById[id];
      if (space == null || parentId == null) {
        continue;
      }
      final parent = spacesById[parentId];
      if (parent != null) {
        space.parent = parent;
        parent.mySpaces.add(space);
      }
    }

    for (final row in itemRows) {
      final parentId = row['space_id'] as String;
      final parent = spacesById[parentId];
      if (parent == null) {
        continue;
      }
      final tagsJson = row['tags_json'] as String?;
      final tags = tagsJson == null
          ? null
          : List<String>.from(jsonDecode(tagsJson) as List<dynamic>);
      final item = ItemModel(
        id: row['id'] as String?,
        name: row['name'] as String,
        description: row['description'] as String,
        locationSpecification: row['location_specification'] as String?,
        tags: tags,
        imagePath: row['image_path'] as String?,
        parent: parent,
      );
      parent.items.add(item);
    }

    final roots = <SpaceModel>[];
    for (final space in spacesById.values) {
      if (space.parent == null) {
        roots.add(space);
      }
    }

    for (final space in roots) {
      space.assignParents();
    }

    return roots;
  }

  Future<void> dispose() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
