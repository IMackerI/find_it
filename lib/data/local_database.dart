import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/item_model.dart';
import '../models/space_member.dart';
import '../models/space_model.dart';
import '../models/user_profile.dart';
import 'remote/models.dart';

class LocalDatabase {
  LocalDatabase({DatabaseFactory? factory})
      : _databaseFactory = factory ?? databaseFactory;

  final DatabaseFactory _databaseFactory;
  Database? _database;

  static const _dbName = 'spaces.db';
  static const _dbVersion = 3;

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
        version: _dbVersion,
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

          await _createSharingTables(db);
          await _createSyncTables(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await _createSharingTables(db);
          }
          if (oldVersion < 3) {
            await _createSyncTables(db);
          }
        },
      ),
    );
    _database = db;
    return db;
  }

  static Future<void> _createSharingTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        display_name TEXT,
        avatar_url TEXT,
        is_current INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        version INTEGER NOT NULL,
        is_deleted INTEGER NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS space_memberships (
        space_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        role TEXT NOT NULL,
        joined_at INTEGER,
        attachment_visibility TEXT NOT NULL,
        updated_at INTEGER NOT NULL,
        version INTEGER NOT NULL,
        is_deleted INTEGER NOT NULL,
        PRIMARY KEY (space_id, user_id),
        FOREIGN KEY(space_id) REFERENCES spaces(id) ON DELETE CASCADE,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_space_memberships_space_id ON space_memberships(space_id);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_space_memberships_user_id ON space_memberships(user_id);',
    );
  }

  static Future<void> _createSyncTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS outbox (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        space_id TEXT,
        operation TEXT NOT NULL,
        payload TEXT NOT NULL,
        updated_at INTEGER NOT NULL,
        version INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      );
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_outbox_entity ON outbox(entity_type, entity_id);',
    );
  }

  Future<void> replaceAllSpaces(List<SpaceModel> spaces) async {
    final db = await _openDatabase();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final usersById = <String, UserProfile>{};

    void collectMembers(SpaceModel space) {
      for (final member in space.collaborators) {
        usersById[member.user.id] = member.user;
      }
      for (final child in space.mySpaces) {
        collectMembers(child);
      }
    }

    for (final root in spaces) {
      collectMembers(root);
    }

    await db.transaction((txn) async {
      final existingSpaces = await _loadRowsByPrimaryKey(txn, 'spaces', 'id');
      final existingItems = await _loadRowsByPrimaryKey(txn, 'items', 'id');
      final existingUsers = await _loadRowsByPrimaryKey(txn, 'users', 'id');
      final existingMemberships = await _loadMembershipRows(txn);

      Future<void> upsertUser(UserProfile user) async {
        final existing = existingUsers.remove(user.id);
        final newRow = <String, Object?>{
          'id': user.id,
          'email': user.email,
          'display_name': user.displayName,
          'avatar_url': user.avatarUrl,
          'is_current': user.isCurrentUser ? 1 : 0,
          'is_deleted': 0,
        };
        final shouldRevive = existing != null && _isDeleted(existing);
        final hasChanges = _hasChanged(
          existing,
          newRow,
          const ['email', 'display_name', 'avatar_url', 'is_current'],
        );
        if (existing == null) {
          final version = 1;
          await txn.insert(
            'users',
            {
              ...newRow,
              'updated_at': timestamp,
              'version': version,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          await _enqueueMutation(
            txn,
            entityType: 'user',
            entityId: user.id,
            operation: 'upsert',
            payload: _userPayload(
              id: user.id,
              email: user.email,
              displayName: user.displayName,
              avatarUrl: user.avatarUrl,
              isCurrentUser: user.isCurrentUser,
              isDeleted: false,
              updatedAt: timestamp,
              version: version,
            ),
            updatedAt: timestamp,
            version: version,
          );
        } else if (shouldRevive || hasChanges) {
          final version = ((existing['version'] as int?) ?? 0) + 1;
          await txn.update(
            'users',
            {
              ...newRow,
              'updated_at': timestamp,
              'version': version,
            },
            where: 'id = ?',
            whereArgs: [user.id],
          );
          await _enqueueMutation(
            txn,
            entityType: 'user',
            entityId: user.id,
            operation: 'upsert',
            payload: _userPayload(
              id: user.id,
              email: user.email,
              displayName: user.displayName,
              avatarUrl: user.avatarUrl,
              isCurrentUser: user.isCurrentUser,
              isDeleted: false,
              updatedAt: timestamp,
              version: version,
            ),
            updatedAt: timestamp,
            version: version,
          );
        }
      }

      for (final user in usersById.values) {
        await upsertUser(user);
      }

      Future<void> persistSpace(
        SpaceModel space,
        String? parentId,
      ) async {
        final spaceId = space.id;
        final existing = existingSpaces.remove(spaceId);
        final newRow = <String, Object?>{
          'id': spaceId,
          'name': space.name,
          'position_dx': space.position.dx,
          'position_dy': space.position.dy,
          'size_width': space.size.width,
          'size_height': space.size.height,
          'parent_id': parentId,
          'is_deleted': 0,
        };
        final shouldRevive = existing != null && _isDeleted(existing);
        final hasChanges = _hasChanged(
          existing,
          newRow,
          const [
            'name',
            'position_dx',
            'position_dy',
            'size_width',
            'size_height',
            'parent_id',
          ],
        );
        if (existing == null) {
          final version = 1;
          await txn.insert(
            'spaces',
            {
              ...newRow,
              'updated_at': timestamp,
              'version': version,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          await _enqueueMutation(
            txn,
            entityType: 'space',
            entityId: spaceId,
            operation: 'upsert',
            payload: _spacePayload(
              spaceId: spaceId,
              name: space.name,
              position: space.position,
              size: space.size,
              parentId: parentId,
              isDeleted: false,
              updatedAt: timestamp,
              version: version,
            ),
            updatedAt: timestamp,
            version: version,
            spaceId: spaceId,
          );
        } else if (shouldRevive || hasChanges) {
          final version = ((existing['version'] as int?) ?? 0) + 1;
          await txn.update(
            'spaces',
            {
              ...newRow,
              'updated_at': timestamp,
              'version': version,
            },
            where: 'id = ?',
            whereArgs: [spaceId],
          );
          await _enqueueMutation(
            txn,
            entityType: 'space',
            entityId: spaceId,
            operation: 'upsert',
            payload: _spacePayload(
              spaceId: spaceId,
              name: space.name,
              position: space.position,
              size: space.size,
              parentId: parentId,
              isDeleted: false,
              updatedAt: timestamp,
              version: version,
            ),
            updatedAt: timestamp,
            version: version,
            spaceId: spaceId,
          );
        }

        final itemIdsForSpace = <String>{};
        for (final item in space.items) {
          final itemId = item.id;
          itemIdsForSpace.add(itemId);
          final existingItem = existingItems.remove(itemId);
          final tagsJson =
              item.tags == null ? null : jsonEncode(List<String>.from(item.tags!));
          final newItemRow = <String, Object?>{
            'id': itemId,
            'space_id': spaceId,
            'name': item.name,
            'description': item.description,
            'location_specification': item.locationSpecification,
            'tags_json': tagsJson,
            'image_path': item.imagePath,
            'is_deleted': 0,
          };
          final itemRevived = existingItem != null && _isDeleted(existingItem);
          final itemChanged = _hasChanged(
            existingItem,
            newItemRow,
            const [
              'space_id',
              'name',
              'description',
              'location_specification',
              'tags_json',
              'image_path',
            ],
          );
          if (existingItem == null) {
            final version = 1;
            await txn.insert(
              'items',
              {
                ...newItemRow,
                'updated_at': timestamp,
                'version': version,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            await _enqueueMutation(
              txn,
              entityType: 'item',
              entityId: itemId,
              operation: 'upsert',
              payload: _itemPayload(
                id: itemId,
                spaceId: spaceId,
                name: item.name,
                description: item.description,
                locationSpecification: item.locationSpecification,
                tags: item.tags,
                imagePath: item.imagePath,
                isDeleted: false,
                updatedAt: timestamp,
                version: version,
              ),
              updatedAt: timestamp,
              version: version,
              spaceId: spaceId,
            );
          } else if (itemRevived || itemChanged) {
            final version = ((existingItem['version'] as int?) ?? 0) + 1;
            await txn.update(
              'items',
              {
                ...newItemRow,
                'updated_at': timestamp,
                'version': version,
              },
              where: 'id = ?',
              whereArgs: [itemId],
            );
            await _enqueueMutation(
              txn,
              entityType: 'item',
              entityId: itemId,
              operation: 'upsert',
              payload: _itemPayload(
                id: itemId,
                spaceId: spaceId,
                name: item.name,
                description: item.description,
                locationSpecification: item.locationSpecification,
                tags: item.tags,
                imagePath: item.imagePath,
                isDeleted: false,
                updatedAt: timestamp,
                version: version,
              ),
              updatedAt: timestamp,
              version: version,
              spaceId: spaceId,
            );
          }
        }

        for (final itemEntry in existingItems.entries.toList()) {
          final row = itemEntry.value;
          if (row['space_id'] != spaceId) {
            continue;
          }
          final itemId = itemEntry.key;
          if (itemIdsForSpace.contains(itemId)) {
            continue;
          }
          if (_isDeleted(row)) {
            existingItems.remove(itemId);
            continue;
          }
          final version = ((row['version'] as int?) ?? 0) + 1;
          await txn.update(
            'items',
            {
              'is_deleted': 1,
              'updated_at': timestamp,
              'version': version,
            },
            where: 'id = ?',
            whereArgs: [itemId],
          );
          await _enqueueMutation(
            txn,
            entityType: 'item',
            entityId: itemId,
            operation: 'delete',
            payload: {
              'id': itemId,
              'spaceId': row['space_id'],
              'isDeleted': true,
              'updatedAt': timestamp,
              'version': version,
            },
            updatedAt: timestamp,
            version: version,
            spaceId: row['space_id'] as String?,
          );
          existingItems.remove(itemId);
        }

        final membershipsForSpace = <String>{};
        for (final member in space.collaborators) {
          final membershipKey = _membershipKey(spaceId, member.user.id);
          membershipsForSpace.add(membershipKey);
          final existingMembership = existingMemberships.remove(membershipKey);
          final newMembershipRow = <String, Object?>{
            'space_id': spaceId,
            'user_id': member.user.id,
            'role': member.role.name,
            'joined_at': member.joinedAt?.millisecondsSinceEpoch,
            'attachment_visibility':
                member.defaultAttachmentVisibility.name,
            'is_deleted': 0,
          };
          final membershipRevived =
              existingMembership != null && _isDeleted(existingMembership);
          final membershipChanged = _hasChanged(
            existingMembership,
            newMembershipRow,
            const [
              'role',
              'joined_at',
              'attachment_visibility',
            ],
          );
          if (existingMembership == null) {
            final version = 1;
            await txn.insert(
              'space_memberships',
              {
                ...newMembershipRow,
                'updated_at': timestamp,
                'version': version,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            await _enqueueMutation(
              txn,
              entityType: 'space_membership',
              entityId: membershipKey,
              operation: 'upsert',
              payload: _membershipPayload(
                spaceId: spaceId,
                userId: member.user.id,
                role: member.role.name,
                attachmentVisibility:
                    member.defaultAttachmentVisibility.name,
                joinedAt: member.joinedAt,
                isDeleted: false,
                updatedAt: timestamp,
                version: version,
              ),
              updatedAt: timestamp,
              version: version,
              spaceId: spaceId,
            );
          } else if (membershipRevived || membershipChanged) {
            final version = ((existingMembership['version'] as int?) ?? 0) + 1;
            await txn.update(
              'space_memberships',
              {
                ...newMembershipRow,
                'updated_at': timestamp,
                'version': version,
              },
              where: 'space_id = ? AND user_id = ?',
              whereArgs: [spaceId, member.user.id],
            );
            await _enqueueMutation(
              txn,
              entityType: 'space_membership',
              entityId: membershipKey,
              operation: 'upsert',
              payload: _membershipPayload(
                spaceId: spaceId,
                userId: member.user.id,
                role: member.role.name,
                attachmentVisibility:
                    member.defaultAttachmentVisibility.name,
                joinedAt: member.joinedAt,
                isDeleted: false,
                updatedAt: timestamp,
                version: version,
              ),
              updatedAt: timestamp,
              version: version,
              spaceId: spaceId,
            );
          }
        }

        for (final membershipEntry in existingMemberships.entries.toList()) {
          final row = membershipEntry.value;
          if (row['space_id'] != spaceId) {
            continue;
          }
          final key = membershipEntry.key;
          if (membershipsForSpace.contains(key)) {
            continue;
          }
          if (_isDeleted(row)) {
            existingMemberships.remove(key);
            continue;
          }
          final version = ((row['version'] as int?) ?? 0) + 1;
          final spaceIdValue = row['space_id'] as String;
          final userIdValue = row['user_id'] as String;
          await txn.update(
            'space_memberships',
            {
              'is_deleted': 1,
              'updated_at': timestamp,
              'version': version,
            },
            where: 'space_id = ? AND user_id = ?',
            whereArgs: [spaceIdValue, userIdValue],
          );
          await _enqueueMutation(
            txn,
            entityType: 'space_membership',
            entityId: key,
            operation: 'delete',
            payload: {
              'spaceId': spaceIdValue,
              'userId': userIdValue,
              'isDeleted': true,
              'updatedAt': timestamp,
              'version': version,
            },
            updatedAt: timestamp,
            version: version,
            spaceId: spaceIdValue,
          );
          existingMemberships.remove(key);
        }

        for (final child in space.mySpaces) {
          await persistSpace(child, spaceId);
        }
      }

      for (final root in spaces) {
        await persistSpace(root, null);
      }

      for (final entry in existingSpaces.entries) {
        final row = entry.value;
        if (_isDeleted(row)) {
          continue;
        }
        final version = ((row['version'] as int?) ?? 0) + 1;
        await txn.update(
          'spaces',
          {
            'is_deleted': 1,
            'updated_at': timestamp,
            'version': version,
          },
          where: 'id = ?',
          whereArgs: [entry.key],
        );
        await _enqueueMutation(
          txn,
          entityType: 'space',
          entityId: entry.key,
          operation: 'delete',
          payload: {
            'id': entry.key,
            'isDeleted': true,
            'updatedAt': timestamp,
            'version': version,
          },
          updatedAt: timestamp,
          version: version,
          spaceId: entry.key,
        );
      }

      for (final entry in existingItems.entries) {
        final row = entry.value;
        if (_isDeleted(row)) {
          continue;
        }
        final version = ((row['version'] as int?) ?? 0) + 1;
        await txn.update(
          'items',
          {
            'is_deleted': 1,
            'updated_at': timestamp,
            'version': version,
          },
          where: 'id = ?',
          whereArgs: [entry.key],
        );
        await _enqueueMutation(
          txn,
          entityType: 'item',
          entityId: entry.key,
          operation: 'delete',
          payload: {
            'id': entry.key,
            'spaceId': entry.value['space_id'],
            'isDeleted': true,
            'updatedAt': timestamp,
            'version': version,
          },
          updatedAt: timestamp,
          version: version,
          spaceId: entry.value['space_id'] as String?,
        );
      }

      for (final entry in existingMemberships.entries) {
        final row = entry.value;
        if (_isDeleted(row)) {
          continue;
        }
        final version = ((row['version'] as int?) ?? 0) + 1;
        final spaceIdValue = row['space_id'] as String;
        final userIdValue = row['user_id'] as String;
        await txn.update(
          'space_memberships',
          {
            'is_deleted': 1,
            'updated_at': timestamp,
            'version': version,
          },
          where: 'space_id = ? AND user_id = ?',
          whereArgs: [spaceIdValue, userIdValue],
        );
        await _enqueueMutation(
          txn,
          entityType: 'space_membership',
          entityId: _membershipKey(spaceIdValue, userIdValue),
          operation: 'delete',
          payload: {
            'spaceId': spaceIdValue,
            'userId': userIdValue,
            'isDeleted': true,
            'updatedAt': timestamp,
            'version': version,
          },
          updatedAt: timestamp,
          version: version,
          spaceId: spaceIdValue,
        );
      }

      for (final entry in existingUsers.entries) {
        final row = entry.value;
        if (_isDeleted(row)) {
          continue;
        }
        if ((row['is_current'] as int? ?? 0) == 1) {
          continue;
        }
        final version = ((row['version'] as int?) ?? 0) + 1;
        await txn.update(
          'users',
          {
            'is_deleted': 1,
            'updated_at': timestamp,
            'version': version,
          },
          where: 'id = ?',
          whereArgs: [entry.key],
        );
        await _enqueueMutation(
          txn,
          entityType: 'user',
          entityId: entry.key,
          operation: 'delete',
          payload: {
            'id': entry.key,
            'isDeleted': true,
            'updatedAt': timestamp,
            'version': version,
          },
          updatedAt: timestamp,
          version: version,
        );
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

    final userRows = await db.query(
      'users',
      where: 'is_deleted = ?',
      whereArgs: [0],
    );

    final membershipRows = await db.query(
      'space_memberships',
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

    final usersById = <String, UserProfile>{};
    for (final row in userRows) {
      final id = row['id'] as String;
      usersById[id] = UserProfile(
        id: id,
        email: row['email'] as String,
        displayName: row['display_name'] as String?,
        avatarUrl: row['avatar_url'] as String?,
        isCurrentUser: (row['is_current'] as int) == 1,
      );
    }

    for (final row in membershipRows) {
      final spaceId = row['space_id'] as String;
      final space = spacesById[spaceId];
      if (space == null) {
        continue;
      }

      final userId = row['user_id'] as String;
      final user = usersById[userId];
      if (user == null) {
        continue;
      }

      final roleValue = row['role'] as String;
      final attachmentValue = row['attachment_visibility'] as String;
      final joinedAtValue = row['joined_at'] as int?;
      space.collaborators.add(
        SpaceMember(
          user: user,
          role: spaceRoleFromName(roleValue),
          joinedAt: joinedAtValue == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(joinedAtValue),
          defaultAttachmentVisibility:
              attachmentVisibilityFromName(attachmentValue),
        ),
      );
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

  Future<List<PendingMutation>> getPendingMutations({int limit = 50}) async {
    final db = await _openDatabase();
    final rows = await db.query(
      'outbox',
      orderBy: 'id ASC',
      limit: limit,
    );
    return rows
        .map(
          (row) => PendingMutation(
            id: row['id'] as int,
            entityType: row['entity_type'] as String,
            entityId: row['entity_id'] as String,
            spaceId: row['space_id'] as String?,
            operation: row['operation'] as String,
            payload: Map<String, dynamic>.from(
              jsonDecode(row['payload'] as String) as Map<String, dynamic>,
            ),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(
              row['updated_at'] as int,
            ),
            version: row['version'] as int,
          ),
        )
        .toList();
  }

  Future<void> markMutationsProcessed(List<int> ids) async {
    if (ids.isEmpty) {
      return;
    }
    final db = await _openDatabase();
    await db.transaction((txn) async {
      final placeholders = List.filled(ids.length, '?').join(',');
      await txn.rawDelete('DELETE FROM outbox WHERE id IN ($placeholders)', ids);
    });
  }

  Future<void> applyRemoteChanges(SyncResponse response) async {
    final db = await _openDatabase();
    await db.transaction((txn) async {
      await _applyRemoteUsers(txn, response.users);
      await _applyRemoteSpaces(txn, response.spaces);
      await _applyRemoteItems(txn, response.items);
      await _applyRemoteMemberships(txn, response.memberships);
    });
  }

  Future<void> _applyRemoteUsers(
    Transaction txn,
    List<RemoteUser> users,
  ) async {
    for (final user in users) {
      final rows = await txn.query(
        'users',
        where: 'id = ?',
        whereArgs: [user.id],
        limit: 1,
      );
      final existing = rows.isEmpty ? null : rows.first;
      final localVersion = existing == null ? 0 : (existing['version'] as int? ?? 0);
      final localUpdatedAt =
          existing == null ? 0 : (existing['updated_at'] as int? ?? 0);
      final remoteUpdatedAt = user.updatedAt.millisecondsSinceEpoch;
      if (localVersion > user.version) {
        continue;
      }
      if (localVersion == user.version && localUpdatedAt >= remoteUpdatedAt) {
        continue;
      }
      final data = <String, Object?>{
        'email': user.email,
        'display_name': user.displayName,
        'avatar_url': user.avatarUrl,
        'is_current': user.isCurrentUser ? 1 : 0,
        'is_deleted': user.isDeleted ? 1 : 0,
        'version': user.version,
        'updated_at': remoteUpdatedAt,
      };
      if (existing == null) {
        await txn.insert(
          'users',
          {
            'id': user.id,
            ...data,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else {
        await txn.update(
          'users',
          data,
          where: 'id = ?',
          whereArgs: [user.id],
        );
      }
    }
  }

  Future<void> _applyRemoteSpaces(
    Transaction txn,
    List<RemoteSpace> spaces,
  ) async {
    for (final space in spaces) {
      final rows = await txn.query(
        'spaces',
        where: 'id = ?',
        whereArgs: [space.id],
        limit: 1,
      );
      final existing = rows.isEmpty ? null : rows.first;
      final localVersion = existing == null ? 0 : (existing['version'] as int? ?? 0);
      final localUpdatedAt =
          existing == null ? 0 : (existing['updated_at'] as int? ?? 0);
      final remoteUpdatedAt = space.updatedAt.millisecondsSinceEpoch;
      if (localVersion > space.version) {
        continue;
      }
      if (localVersion == space.version && localUpdatedAt >= remoteUpdatedAt) {
        continue;
      }
      final data = <String, Object?>{
        'name': space.name,
        'position_dx': space.positionDx,
        'position_dy': space.positionDy,
        'size_width': space.sizeWidth,
        'size_height': space.sizeHeight,
        'parent_id': space.parentId,
        'is_deleted': space.isDeleted ? 1 : 0,
        'version': space.version,
        'updated_at': remoteUpdatedAt,
      };
      if (existing == null) {
        await txn.insert(
          'spaces',
          {
            'id': space.id,
            ...data,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else {
        await txn.update(
          'spaces',
          data,
          where: 'id = ?',
          whereArgs: [space.id],
        );
      }
    }
  }

  Future<void> _applyRemoteItems(
    Transaction txn,
    List<RemoteItem> items,
  ) async {
    for (final item in items) {
      final rows = await txn.query(
        'items',
        where: 'id = ?',
        whereArgs: [item.id],
        limit: 1,
      );
      final existing = rows.isEmpty ? null : rows.first;
      final localVersion = existing == null ? 0 : (existing['version'] as int? ?? 0);
      final localUpdatedAt =
          existing == null ? 0 : (existing['updated_at'] as int? ?? 0);
      final remoteUpdatedAt = item.updatedAt.millisecondsSinceEpoch;
      if (localVersion > item.version) {
        continue;
      }
      if (localVersion == item.version && localUpdatedAt >= remoteUpdatedAt) {
        continue;
      }
      final data = <String, Object?>{
        'space_id': item.spaceId,
        'name': item.name,
        'description': item.description,
        'location_specification': item.locationSpecification,
        'tags_json': item.tags == null ? null : jsonEncode(item.tags),
        'image_path': item.imagePath,
        'is_deleted': item.isDeleted ? 1 : 0,
        'version': item.version,
        'updated_at': remoteUpdatedAt,
      };
      if (existing == null) {
        await txn.insert(
          'items',
          {
            'id': item.id,
            ...data,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else {
        await txn.update(
          'items',
          data,
          where: 'id = ?',
          whereArgs: [item.id],
        );
      }
    }
  }

  Future<void> _applyRemoteMemberships(
    Transaction txn,
    List<RemoteMembership> memberships,
  ) async {
    for (final membership in memberships) {
      final rows = await txn.query(
        'space_memberships',
        where: 'space_id = ? AND user_id = ?',
        whereArgs: [membership.spaceId, membership.userId],
        limit: 1,
      );
      final existing = rows.isEmpty ? null : rows.first;
      final localVersion = existing == null ? 0 : (existing['version'] as int? ?? 0);
      final localUpdatedAt =
          existing == null ? 0 : (existing['updated_at'] as int? ?? 0);
      final remoteUpdatedAt = membership.updatedAt.millisecondsSinceEpoch;
      if (localVersion > membership.version) {
        continue;
      }
      if (localVersion == membership.version &&
          localUpdatedAt >= remoteUpdatedAt) {
        continue;
      }
      final data = <String, Object?>{
        'role': membership.role,
        'joined_at': membership.joinedAt?.millisecondsSinceEpoch,
        'attachment_visibility': membership.attachmentVisibility,
        'is_deleted': membership.isDeleted ? 1 : 0,
        'version': membership.version,
        'updated_at': remoteUpdatedAt,
      };
      if (existing == null) {
        await txn.insert(
          'space_memberships',
          {
            'space_id': membership.spaceId,
            'user_id': membership.userId,
            ...data,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else {
        await txn.update(
          'space_memberships',
          data,
          where: 'space_id = ? AND user_id = ?',
          whereArgs: [membership.spaceId, membership.userId],
        );
      }
    }
  }

  Future<void> dispose() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

Future<Map<String, Map<String, Object?>>> _loadRowsByPrimaryKey(
  Transaction txn,
  String table,
  String column,
) async {
  final rows = await txn.query(table);
  final map = <String, Map<String, Object?>>{};
  for (final row in rows) {
    final id = row[column];
    if (id is String) {
      map[id] = Map<String, Object?>.from(row);
    }
  }
  return map;
}

Future<Map<String, Map<String, Object?>>> _loadMembershipRows(
  Transaction txn,
) async {
  final rows = await txn.query('space_memberships');
  final map = <String, Map<String, Object?>>{};
  for (final row in rows) {
    final spaceId = row['space_id'];
    final userId = row['user_id'];
    if (spaceId is String && userId is String) {
      map[_membershipKey(spaceId, userId)] = Map<String, Object?>.from(row);
    }
  }
  return map;
}

String _membershipKey(String spaceId, String userId) => '$spaceId|$userId';

bool _isDeleted(Map<String, Object?> row) => (row['is_deleted'] as int? ?? 0) == 1;

bool _hasChanged(
  Map<String, Object?>? existing,
  Map<String, Object?> updated,
  List<String> keys,
) {
  if (existing == null) {
    return true;
  }
  for (final key in keys) {
    final existingValue = existing[key];
    final updatedValue = updated[key];
    if (!_valueEquals(existingValue, updatedValue)) {
      return true;
    }
  }
  return false;
}

bool _valueEquals(Object? a, Object? b) {
  if (a == null || b == null) {
    return a == b;
  }
  if (a is num && b is num) {
    return (a.toDouble() - b.toDouble()).abs() < 0.000001;
  }
  return a == b;
}

Future<void> _enqueueMutation(
  Transaction txn, {
  required String entityType,
  required String entityId,
  String? spaceId,
  required String operation,
  required Map<String, dynamic> payload,
  required int updatedAt,
  required int version,
}) async {
  await txn.insert('outbox', {
    'entity_type': entityType,
    'entity_id': entityId,
    'space_id': spaceId,
    'operation': operation,
    'payload': jsonEncode(payload),
    'updated_at': updatedAt,
    'version': version,
    'created_at': DateTime.now().millisecondsSinceEpoch,
  });
}

Map<String, dynamic> _spacePayload({
  required String spaceId,
  required String name,
  required Offset position,
  required Size size,
  String? parentId,
  required bool isDeleted,
  required int updatedAt,
  required int version,
}) {
  return {
    'id': spaceId,
    'name': name,
    'positionDx': position.dx,
    'positionDy': position.dy,
    'sizeWidth': size.width,
    'sizeHeight': size.height,
    'parentId': parentId,
    'isDeleted': isDeleted,
    'updatedAt': updatedAt,
    'version': version,
  };
}

Map<String, dynamic> _itemPayload({
  required String id,
  required String spaceId,
  required String name,
  required String description,
  String? locationSpecification,
  List<String>? tags,
  String? imagePath,
  required bool isDeleted,
  required int updatedAt,
  required int version,
}) {
  return {
    'id': id,
    'spaceId': spaceId,
    'name': name,
    'description': description,
    'locationSpecification': locationSpecification,
    'tags': tags,
    'imagePath': imagePath,
    'isDeleted': isDeleted,
    'updatedAt': updatedAt,
    'version': version,
  };
}

Map<String, dynamic> _membershipPayload({
  required String spaceId,
  required String userId,
  required String role,
  required String attachmentVisibility,
  DateTime? joinedAt,
  required bool isDeleted,
  required int updatedAt,
  required int version,
}) {
  return {
    'spaceId': spaceId,
    'userId': userId,
    'role': role,
    'attachmentVisibility': attachmentVisibility,
    'joinedAt': joinedAt?.millisecondsSinceEpoch,
    'isDeleted': isDeleted,
    'updatedAt': updatedAt,
    'version': version,
  };
}

Map<String, dynamic> _userPayload({
  required String id,
  required String email,
  String? displayName,
  String? avatarUrl,
  required bool isCurrentUser,
  required bool isDeleted,
  required int updatedAt,
  required int version,
}) {
  return {
    'id': id,
    'email': email,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
    'isCurrentUser': isCurrentUser,
    'isDeleted': isDeleted,
    'updatedAt': updatedAt,
    'version': version,
  };
}

class PendingMutation {
  PendingMutation({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.updatedAt,
    required this.version,
    this.spaceId,
  });

  final int id;
  final String entityType;
  final String entityId;
  final String operation;
  final Map<String, dynamic> payload;
  final DateTime updatedAt;
  final int version;
  final String? spaceId;

  SyncMutation toSyncMutation() {
    return SyncMutation(
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      payload: payload,
      version: version,
      updatedAt: updatedAt,
      spaceId: spaceId,
    );
  }
}
