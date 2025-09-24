// ignore_for_file: avoid_redundant_argument_values

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart' show Offset, Size;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/item_model.dart';
import '../models/space_member.dart';
import '../models/space_model.dart';
import '../models/user_profile.dart';
import 'remote/models.dart';

part 'local_database.g.dart';

const _dbName = 'spaces.db';
const _syncStateTableName = 'sync_state';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, _dbName));
    return NativeDatabase(file, logStatements: false);
  });
}

@DataClassName('SpaceRow')
class SpacesTable extends Table {
  @override
  String get tableName => 'spaces';

  TextColumn get id => text()();

  TextColumn get name => text()();

  RealColumn get positionDx => real().named('position_dx')();

  RealColumn get positionDy => real().named('position_dy')();

  RealColumn get sizeWidth => real().named('size_width')();

  RealColumn get sizeHeight => real().named('size_height')();

  TextColumn get parentId => text()
      .named('parent_id')
      .nullable()
      .customConstraint('NULL REFERENCES spaces(id) ON DELETE CASCADE')();

  IntColumn get updatedAt => integer().named('updated_at')();

  IntColumn get version => integer()();

  BoolColumn get isDeleted =>
      boolean().named('is_deleted').withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ItemRow')
class ItemsTable extends Table {
  @override
  String get tableName => 'items';

  TextColumn get id => text()();

  TextColumn get spaceId => text()
      .named('space_id')
      .customConstraint('REFERENCES spaces(id) ON DELETE CASCADE NOT NULL')();

  TextColumn get name => text()();

  TextColumn get description => text()();

  TextColumn get locationSpecification =>
      text().named('location_specification').nullable()();

  TextColumn get tagsJson => text().named('tags_json').nullable()();

  TextColumn get imagePath => text().named('image_path').nullable()();

  IntColumn get updatedAt => integer().named('updated_at')();

  IntColumn get version => integer()();

  BoolColumn get isDeleted =>
      boolean().named('is_deleted').withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('UserRow')
class UsersTable extends Table {
  @override
  String get tableName => 'users';

  TextColumn get id => text()();

  TextColumn get email => text()();

  TextColumn get displayName => text().named('display_name').nullable()();

  TextColumn get avatarUrl => text().named('avatar_url').nullable()();

  BoolColumn get isCurrent =>
      boolean().named('is_current').withDefault(const Constant(false))();

  IntColumn get updatedAt => integer().named('updated_at')();

  IntColumn get version => integer()();

  BoolColumn get isDeleted =>
      boolean().named('is_deleted').withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MembershipRow')
class SpaceMembershipsTable extends Table {
  @override
  String get tableName => 'space_memberships';

  TextColumn get spaceId => text()
      .named('space_id')
      .customConstraint('REFERENCES spaces(id) ON DELETE CASCADE NOT NULL')();

  TextColumn get userId => text()
      .named('user_id')
      .customConstraint('REFERENCES users(id) ON DELETE CASCADE NOT NULL')();

  TextColumn get role => text()();

  IntColumn get joinedAt => integer().named('joined_at').nullable()();

  TextColumn get attachmentVisibility =>
      text().named('attachment_visibility')();

  IntColumn get updatedAt => integer().named('updated_at')();

  IntColumn get version => integer()();

  BoolColumn get isDeleted =>
      boolean().named('is_deleted').withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {spaceId, userId};
}

@DataClassName('OutboxEntryRow')
class OutboxEntriesTable extends Table {
  @override
  String get tableName => 'outbox';

  IntColumn get id => integer().autoIncrement()();

  TextColumn get entityType => text().named('entity_type')();

  TextColumn get entityId => text().named('entity_id')();

  TextColumn get spaceId => text().named('space_id').nullable()();

  TextColumn get operation => text()();

  TextColumn get payload => text()();

  IntColumn get updatedAt => integer().named('updated_at')();

  IntColumn get version => integer()();

  IntColumn get createdAt => integer().named('created_at')();
}

@DriftDatabase(tables: [
  SpacesTable,
  ItemsTable,
  UsersTable,
  SpaceMembershipsTable,
  OutboxEntriesTable,
])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase({QueryExecutor? executor})
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(usersTable);
            await m.createTable(spaceMembershipsTable);
          }
          if (from < 3) {
            await m.createTable(outboxEntriesTable);
          }
        },
        beforeOpen: (details) async {
          await _ensureSyncStateTable();
        },
      );

  Future<void> replaceAllSpaces(List<SpaceModel> spaces) async {
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

    await transaction(() async {
      final existingSpaces = {
        for (final row in await select(spacesTable).get()) row.id: row,
      };
      final existingItems = {
        for (final row in await select(itemsTable).get()) row.id: row,
      };
      final existingUsers = {
        for (final row in await select(usersTable).get()) row.id: row,
      };
      final existingMemberships = {
        for (final row in await select(spaceMembershipsTable).get())
          _membershipKey(row.spaceId, row.userId): row,
      };

      Future<void> upsertUser(UserProfile user) async {
        final existing = existingUsers.remove(user.id);
        final shouldRevive = existing?.isDeleted ?? false;
        final hasChanges = existing == null ||
            existing.email != user.email ||
            existing.displayName != user.displayName ||
            existing.avatarUrl != user.avatarUrl ||
            existing.isCurrent != user.isCurrentUser;
        if (existing == null) {
          const version = 1;
          await into(usersTable).insert(
            UsersTableCompanion.insert(
              id: user.id,
              email: user.email,
              displayName: Value(user.displayName),
              avatarUrl: Value(user.avatarUrl),
              isCurrent: Value(user.isCurrentUser),
              updatedAt: timestamp,
              version: version,
              isDeleted: const Value(false),
            ),
          );
          await _enqueueMutation(
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
          final version = existing.version + 1;
          await (update(usersTable)..where((tbl) => tbl.id.equals(user.id)))
              .write(
            UsersTableCompanion(
              email: Value(user.email),
              displayName: Value(user.displayName),
              avatarUrl: Value(user.avatarUrl),
              isCurrent: Value(user.isCurrentUser),
              updatedAt: Value(timestamp),
              version: Value(version),
              isDeleted: const Value(false),
            ),
          );
          await _enqueueMutation(
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

      Future<void> persistSpace(SpaceModel space, String? parentId) async {
        final existing = existingSpaces.remove(space.id);
        final shouldRevive = existing?.isDeleted ?? false;
        final hasChanges = existing == null ||
            existing.name != space.name ||
            !_doubleEquals(existing.positionDx, space.position.dx) ||
            !_doubleEquals(existing.positionDy, space.position.dy) ||
            !_doubleEquals(existing.sizeWidth, space.size.width) ||
            !_doubleEquals(existing.sizeHeight, space.size.height) ||
            existing.parentId != parentId;
        if (existing == null) {
          const version = 1;
          await into(spacesTable).insert(
            SpacesTableCompanion.insert(
              id: space.id,
              name: space.name,
              positionDx: space.position.dx,
              positionDy: space.position.dy,
              sizeWidth: space.size.width,
              sizeHeight: space.size.height,
              parentId: Value(parentId),
              updatedAt: timestamp,
              version: version,
              isDeleted: const Value(false),
            ),
          );
          await _enqueueMutation(
            entityType: 'space',
            entityId: space.id,
            operation: 'upsert',
            payload: _spacePayload(
              spaceId: space.id,
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
            spaceId: space.id,
          );
        } else if (shouldRevive || hasChanges) {
          final version = existing.version + 1;
          await (update(spacesTable)..where((tbl) => tbl.id.equals(space.id)))
              .write(
            SpacesTableCompanion(
              name: Value(space.name),
              positionDx: Value(space.position.dx),
              positionDy: Value(space.position.dy),
              sizeWidth: Value(space.size.width),
              sizeHeight: Value(space.size.height),
              parentId: Value(parentId),
              updatedAt: Value(timestamp),
              version: Value(version),
              isDeleted: const Value(false),
            ),
          );
          await _enqueueMutation(
            entityType: 'space',
            entityId: space.id,
            operation: 'upsert',
            payload: _spacePayload(
              spaceId: space.id,
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
            spaceId: space.id,
          );
        }

        final itemIdsForSpace = <String>{};
        for (final item in space.items) {
          final existingItem = existingItems.remove(item.id);
          final tagsJson = item.tags == null
              ? null
              : jsonEncode(List<String>.from(item.tags!));
          final shouldReviveItem = existingItem?.isDeleted ?? false;
          final itemChanged = existingItem == null ||
              existingItem.spaceId != space.id ||
              existingItem.name != item.name ||
              existingItem.description != item.description ||
              existingItem.locationSpecification !=
                  item.locationSpecification ||
              existingItem.tagsJson != tagsJson ||
              existingItem.imagePath != item.imagePath;
          itemIdsForSpace.add(item.id);
          if (existingItem == null) {
            const version = 1;
            await into(itemsTable).insert(
              ItemsTableCompanion.insert(
                id: item.id,
                spaceId: space.id,
                name: item.name,
                description: item.description,
                locationSpecification: Value(item.locationSpecification),
                tagsJson: Value(tagsJson),
                imagePath: Value(item.imagePath),
                updatedAt: timestamp,
                version: version,
                isDeleted: const Value(false),
              ),
            );
            await _enqueueMutation(
              entityType: 'item',
              entityId: item.id,
              operation: 'upsert',
              payload: _itemPayload(
                id: item.id,
                spaceId: space.id,
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
              spaceId: space.id,
            );
          } else if (shouldReviveItem || itemChanged) {
            final version = existingItem.version + 1;
            await (update(itemsTable)..where((tbl) => tbl.id.equals(item.id)))
                .write(
              ItemsTableCompanion(
                spaceId: Value(space.id),
                name: Value(item.name),
                description: Value(item.description),
                locationSpecification: Value(item.locationSpecification),
                tagsJson: Value(tagsJson),
                imagePath: Value(item.imagePath),
                updatedAt: Value(timestamp),
                version: Value(version),
                isDeleted: const Value(false),
              ),
            );
            await _enqueueMutation(
              entityType: 'item',
              entityId: item.id,
              operation: 'upsert',
              payload: _itemPayload(
                id: item.id,
                spaceId: space.id,
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
              spaceId: space.id,
            );
          }
        }

        for (final entry in existingItems.entries.toList()) {
          final row = entry.value;
          if (row.spaceId != space.id || itemIdsForSpace.contains(entry.key)) {
            continue;
          }
          if (row.isDeleted) {
            existingItems.remove(entry.key);
            continue;
          }
          final version = row.version + 1;
          await (update(itemsTable)..where((tbl) => tbl.id.equals(entry.key)))
              .write(
            ItemsTableCompanion(
              isDeleted: const Value(true),
              updatedAt: Value(timestamp),
              version: Value(version),
            ),
          );
          await _enqueueMutation(
            entityType: 'item',
            entityId: entry.key,
            operation: 'delete',
            payload: {
              'id': entry.key,
              'spaceId': row.spaceId,
              'isDeleted': true,
              'updatedAt': timestamp,
              'version': version,
            },
            updatedAt: timestamp,
            version: version,
            spaceId: row.spaceId,
          );
          existingItems.remove(entry.key);
        }

        final membershipKeys = <String>{};
        for (final member in space.collaborators) {
          final key = _membershipKey(space.id, member.user.id);
          membershipKeys.add(key);
          final existingMembership = existingMemberships.remove(key);
          final shouldReviveMembership = existingMembership?.isDeleted ?? false;
          final joinedAt = member.joinedAt?.millisecondsSinceEpoch;
          final membershipChanged = existingMembership == null ||
              existingMembership.role != member.role.name ||
              existingMembership.joinedAt != joinedAt ||
              existingMembership.attachmentVisibility !=
                  member.defaultAttachmentVisibility.name;
          if (existingMembership == null) {
            const version = 1;
            await into(spaceMembershipsTable).insert(
              SpaceMembershipsTableCompanion.insert(
                spaceId: space.id,
                userId: member.user.id,
                role: member.role.name,
                joinedAt: Value(joinedAt),
                attachmentVisibility: member.defaultAttachmentVisibility.name,
                updatedAt: timestamp,
                version: version,
                isDeleted: const Value(false),
              ),
            );
            await _enqueueMutation(
              entityType: 'space_membership',
              entityId: key,
              operation: 'upsert',
              payload: _membershipPayload(
                spaceId: space.id,
                userId: member.user.id,
                role: member.role.name,
                attachmentVisibility: member.defaultAttachmentVisibility.name,
                joinedAt: member.joinedAt,
                isDeleted: false,
                updatedAt: timestamp,
                version: version,
              ),
              updatedAt: timestamp,
              version: version,
              spaceId: space.id,
            );
          } else if (shouldReviveMembership || membershipChanged) {
            final version = existingMembership.version + 1;
            await (update(spaceMembershipsTable)
                  ..where((tbl) =>
                      tbl.spaceId.equals(space.id) &
                      tbl.userId.equals(member.user.id)))
                .write(
              SpaceMembershipsTableCompanion(
                role: Value(member.role.name),
                joinedAt: Value(joinedAt),
                attachmentVisibility:
                    Value(member.defaultAttachmentVisibility.name),
                updatedAt: Value(timestamp),
                version: Value(version),
                isDeleted: const Value(false),
              ),
            );
            await _enqueueMutation(
              entityType: 'space_membership',
              entityId: key,
              operation: 'upsert',
              payload: _membershipPayload(
                spaceId: space.id,
                userId: member.user.id,
                role: member.role.name,
                attachmentVisibility: member.defaultAttachmentVisibility.name,
                joinedAt: member.joinedAt,
                isDeleted: false,
                updatedAt: timestamp,
                version: version,
              ),
              updatedAt: timestamp,
              version: version,
              spaceId: space.id,
            );
          }
        }

        for (final entry in existingMemberships.entries.toList()) {
          final row = entry.value;
          if (row.spaceId != space.id || membershipKeys.contains(entry.key)) {
            continue;
          }
          if (row.isDeleted) {
            existingMemberships.remove(entry.key);
            continue;
          }
          final version = row.version + 1;
          await (update(spaceMembershipsTable)
                ..where((tbl) =>
                    tbl.spaceId.equals(row.spaceId) &
                    tbl.userId.equals(row.userId)))
              .write(
            SpaceMembershipsTableCompanion(
              isDeleted: const Value(true),
              updatedAt: Value(timestamp),
              version: Value(version),
            ),
          );
          await _enqueueMutation(
            entityType: 'space_membership',
            entityId: entry.key,
            operation: 'delete',
            payload: {
              'spaceId': row.spaceId,
              'userId': row.userId,
              'isDeleted': true,
              'updatedAt': timestamp,
              'version': version,
            },
            updatedAt: timestamp,
            version: version,
            spaceId: row.spaceId,
          );
          existingMemberships.remove(entry.key);
        }

        for (final child in space.mySpaces) {
          await persistSpace(child, space.id);
        }
      }

      for (final user in usersById.values) {
        await upsertUser(user);
      }

      for (final root in spaces) {
        await persistSpace(root, null);
      }

      for (final entry in existingSpaces.entries) {
        final row = entry.value;
        if (row.isDeleted) {
          continue;
        }
        final version = row.version + 1;
        await (update(spacesTable)..where((tbl) => tbl.id.equals(row.id)))
            .write(
          SpacesTableCompanion(
            isDeleted: const Value(true),
            updatedAt: Value(timestamp),
            version: Value(version),
          ),
        );
        await _enqueueMutation(
          entityType: 'space',
          entityId: row.id,
          operation: 'delete',
          payload: {
            'id': row.id,
            'isDeleted': true,
            'updatedAt': timestamp,
            'version': version,
          },
          updatedAt: timestamp,
          version: version,
          spaceId: row.id,
        );
      }

      for (final entry in existingItems.entries) {
        final row = entry.value;
        if (row.isDeleted) {
          continue;
        }
        final version = row.version + 1;
        await (update(itemsTable)..where((tbl) => tbl.id.equals(row.id))).write(
          ItemsTableCompanion(
            isDeleted: const Value(true),
            updatedAt: Value(timestamp),
            version: Value(version),
          ),
        );
        await _enqueueMutation(
          entityType: 'item',
          entityId: row.id,
          operation: 'delete',
          payload: {
            'id': row.id,
            'spaceId': row.spaceId,
            'isDeleted': true,
            'updatedAt': timestamp,
            'version': version,
          },
          updatedAt: timestamp,
          version: version,
          spaceId: row.spaceId,
        );
      }

      for (final entry in existingMemberships.entries) {
        final row = entry.value;
        if (row.isDeleted) {
          continue;
        }
        final version = row.version + 1;
        await (update(spaceMembershipsTable)
              ..where((tbl) =>
                  tbl.spaceId.equals(row.spaceId) &
                  tbl.userId.equals(row.userId)))
            .write(
          SpaceMembershipsTableCompanion(
            isDeleted: const Value(true),
            updatedAt: Value(timestamp),
            version: Value(version),
          ),
        );
        await _enqueueMutation(
          entityType: 'space_membership',
          entityId: _membershipKey(row.spaceId, row.userId),
          operation: 'delete',
          payload: {
            'spaceId': row.spaceId,
            'userId': row.userId,
            'isDeleted': true,
            'updatedAt': timestamp,
            'version': version,
          },
          updatedAt: timestamp,
          version: version,
          spaceId: row.spaceId,
        );
      }

      for (final entry in existingUsers.entries) {
        final row = entry.value;
        if (row.isDeleted || row.isCurrent) {
          continue;
        }
        final version = row.version + 1;
        await (update(usersTable)..where((tbl) => tbl.id.equals(row.id))).write(
          UsersTableCompanion(
            isDeleted: const Value(true),
            updatedAt: Value(timestamp),
            version: Value(version),
          ),
        );
        await _enqueueMutation(
          entityType: 'user',
          entityId: row.id,
          operation: 'delete',
          payload: {
            'id': row.id,
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
    final spaceRows = await (select(spacesTable)
          ..where((tbl) => tbl.isDeleted.equals(false)))
        .get();
    if (spaceRows.isEmpty) {
      return [];
    }

    final itemRows = await (select(itemsTable)
          ..where((tbl) => tbl.isDeleted.equals(false)))
        .get();
    final userRows = await (select(usersTable)
          ..where((tbl) => tbl.isDeleted.equals(false)))
        .get();
    final membershipRows = await (select(spaceMembershipsTable)
          ..where((tbl) => tbl.isDeleted.equals(false)))
        .get();

    final spacesById = <String, SpaceModel>{};
    for (final row in spaceRows) {
      spacesById[row.id] = SpaceModel(
        id: row.id,
        name: row.name,
        position: Offset(row.positionDx, row.positionDy),
        size: Size(row.sizeWidth, row.sizeHeight),
        mySpaces: const [],
        items: const [],
      );
    }

    for (final row in spaceRows) {
      final parentId = row.parentId;
      if (parentId == null) {
        continue;
      }
      final space = spacesById[row.id];
      final parent = spacesById[parentId];
      if (space != null && parent != null) {
        space.parent = parent;
        parent.mySpaces.add(space);
      }
    }

    for (final row in itemRows) {
      final space = spacesById[row.spaceId];
      if (space == null) {
        continue;
      }
      final tags = row.tagsJson == null
          ? null
          : List<String>.from(jsonDecode(row.tagsJson!) as List<dynamic>);
      final item = ItemModel(
        id: row.id,
        name: row.name,
        description: row.description,
        locationSpecification: row.locationSpecification,
        tags: tags,
        imagePath: row.imagePath,
        parent: space,
      );
      space.items.add(item);
    }

    final usersById = <String, UserProfile>{};
    for (final row in userRows) {
      usersById[row.id] = UserProfile(
        id: row.id,
        email: row.email,
        displayName: row.displayName,
        avatarUrl: row.avatarUrl,
        isCurrentUser: row.isCurrent,
      );
    }

    for (final row in membershipRows) {
      final space = spacesById[row.spaceId];
      final user = usersById[row.userId];
      if (space == null || user == null) {
        continue;
      }
      space.collaborators.add(
        SpaceMember(
          user: user,
          role: spaceRoleFromName(row.role),
          joinedAt: row.joinedAt == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(row.joinedAt!),
          defaultAttachmentVisibility:
              attachmentVisibilityFromName(row.attachmentVisibility),
        ),
      );
    }

    final roots =
        spacesById.values.where((space) => space.parent == null).toList();
    for (final space in roots) {
      space.assignParents();
    }
    return roots;
  }

  Future<List<PendingMutation>> getPendingMutations({int limit = 50}) async {
    final rows = await (select(outboxEntriesTable)
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.id)])
          ..limit(limit))
        .get();
    return rows
        .map(
          (row) => PendingMutation(
            id: row.id,
            entityType: row.entityType,
            entityId: row.entityId,
            spaceId: row.spaceId,
            operation: row.operation,
            payload: Map<String, dynamic>.from(
              jsonDecode(row.payload) as Map<String, dynamic>,
            ),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
            version: row.version,
          ),
        )
        .toList();
  }

  Future<void> markMutationsProcessed(List<int> ids) async {
    if (ids.isEmpty) {
      return;
    }
    await (delete(outboxEntriesTable)..where((tbl) => tbl.id.isIn(ids))).go();
  }

  Future<bool> applyRemoteChanges(SyncResponse response) async {
    var changed = false;
    await transaction(() async {
      final usersChanged = await _applyRemoteUsers(response.users);
      final spacesChanged = await _applyRemoteSpaces(response.spaces);
      final itemsChanged = await _applyRemoteItems(response.items);
      final membershipsChanged =
          await _applyRemoteMemberships(response.memberships);
      changed =
          usersChanged || spacesChanged || itemsChanged || membershipsChanged;
    });
    return changed;
  }

  Future<void> saveSyncCursor(String? cursor) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await customStatement(
      'UPDATE $_syncStateTableName SET cursor = ?, updated_at = ? WHERE id = 1',
      [cursor, timestamp],
    );
  }

  Future<String?> loadSyncCursor() async {
    final row = await customSelect(
      'SELECT cursor FROM $_syncStateTableName WHERE id = 1',
    ).getSingleOrNull();
    return row?.readNullable<String>('cursor');
  }

  Future<bool> _applyRemoteUsers(List<RemoteUser> users) async {
    var changed = false;
    for (final user in users) {
      final existing = await (select(usersTable)
            ..where((tbl) => tbl.id.equals(user.id)))
          .getSingleOrNull();
      final localVersion = existing?.version ?? 0;
      final localUpdatedAt = existing?.updatedAt ?? 0;
      final remoteUpdatedAt = user.updatedAt.millisecondsSinceEpoch;
      if (localVersion > user.version) {
        continue;
      }
      if (localVersion == user.version && localUpdatedAt >= remoteUpdatedAt) {
        continue;
      }
      final data = UsersTableCompanion(
        email: Value(user.email),
        displayName: Value(user.displayName),
        avatarUrl: Value(user.avatarUrl),
        isCurrent: Value(user.isCurrentUser),
        isDeleted: Value(user.isDeleted),
        updatedAt: Value(remoteUpdatedAt),
        version: Value(user.version),
      );
      if (existing == null) {
        await into(usersTable).insert(
          data.copyWith(id: Value(user.id)),
          mode: InsertMode.insertOrReplace,
        );
        changed = true;
      } else {
        await (update(usersTable)..where((tbl) => tbl.id.equals(user.id)))
            .write(data);
        changed = true;
      }
    }
    return changed;
  }

  Future<bool> _applyRemoteSpaces(List<RemoteSpace> spaces) async {
    var changed = false;
    for (final space in spaces) {
      final existing = await (select(spacesTable)
            ..where((tbl) => tbl.id.equals(space.id)))
          .getSingleOrNull();
      final localVersion = existing?.version ?? 0;
      final localUpdatedAt = existing?.updatedAt ?? 0;
      final remoteUpdatedAt = space.updatedAt.millisecondsSinceEpoch;
      if (localVersion > space.version) {
        continue;
      }
      if (localVersion == space.version && localUpdatedAt >= remoteUpdatedAt) {
        continue;
      }
      final data = SpacesTableCompanion(
        name: Value(space.name),
        positionDx: Value(space.positionDx),
        positionDy: Value(space.positionDy),
        sizeWidth: Value(space.sizeWidth),
        sizeHeight: Value(space.sizeHeight),
        parentId: Value(space.parentId),
        isDeleted: Value(space.isDeleted),
        updatedAt: Value(remoteUpdatedAt),
        version: Value(space.version),
      );
      if (existing == null) {
        await into(spacesTable).insert(
          data.copyWith(id: Value(space.id)),
          mode: InsertMode.insertOrReplace,
        );
        changed = true;
      } else {
        await (update(spacesTable)..where((tbl) => tbl.id.equals(space.id)))
            .write(data);
        changed = true;
      }
    }
    return changed;
  }

  Future<bool> _applyRemoteItems(List<RemoteItem> items) async {
    var changed = false;
    for (final item in items) {
      final existing = await (select(itemsTable)
            ..where((tbl) => tbl.id.equals(item.id)))
          .getSingleOrNull();
      final localVersion = existing?.version ?? 0;
      final localUpdatedAt = existing?.updatedAt ?? 0;
      final remoteUpdatedAt = item.updatedAt.millisecondsSinceEpoch;
      if (localVersion > item.version) {
        continue;
      }
      if (localVersion == item.version && localUpdatedAt >= remoteUpdatedAt) {
        continue;
      }
      final data = ItemsTableCompanion(
        spaceId: Value(item.spaceId),
        name: Value(item.name),
        description: Value(item.description),
        locationSpecification: Value(item.locationSpecification),
        tagsJson: Value(item.tags == null ? null : jsonEncode(item.tags)),
        imagePath: Value(item.imagePath),
        isDeleted: Value(item.isDeleted),
        updatedAt: Value(remoteUpdatedAt),
        version: Value(item.version),
      );
      if (existing == null) {
        await into(itemsTable).insert(
          data.copyWith(id: Value(item.id)),
          mode: InsertMode.insertOrReplace,
        );
        changed = true;
      } else {
        await (update(itemsTable)..where((tbl) => tbl.id.equals(item.id)))
            .write(data);
        changed = true;
      }
    }
    return changed;
  }

  Future<bool> _applyRemoteMemberships(
      List<RemoteMembership> memberships) async {
    var changed = false;
    for (final membership in memberships) {
      final existing = await (select(spaceMembershipsTable)
            ..where((tbl) =>
                tbl.spaceId.equals(membership.spaceId) &
                tbl.userId.equals(membership.userId)))
          .getSingleOrNull();
      final localVersion = existing?.version ?? 0;
      final localUpdatedAt = existing?.updatedAt ?? 0;
      final remoteUpdatedAt = membership.updatedAt.millisecondsSinceEpoch;
      if (localVersion > membership.version) {
        continue;
      }
      if (localVersion == membership.version &&
          localUpdatedAt >= remoteUpdatedAt) {
        continue;
      }
      final data = SpaceMembershipsTableCompanion(
        role: Value(membership.role),
        joinedAt: Value(membership.joinedAt?.millisecondsSinceEpoch),
        attachmentVisibility: Value(membership.attachmentVisibility),
        isDeleted: Value(membership.isDeleted),
        updatedAt: Value(remoteUpdatedAt),
        version: Value(membership.version),
      );
      if (existing == null) {
        await into(spaceMembershipsTable).insert(
          data.copyWith(
            spaceId: Value(membership.spaceId),
            userId: Value(membership.userId),
          ),
          mode: InsertMode.insertOrReplace,
        );
        changed = true;
      } else {
        await (update(spaceMembershipsTable)
              ..where((tbl) =>
                  tbl.spaceId.equals(membership.spaceId) &
                  tbl.userId.equals(membership.userId)))
            .write(data);
        changed = true;
      }
    }
    return changed;
  }

  Future<void> dispose() async {
    await close();
  }

  Future<void> _ensureSyncStateTable() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS $_syncStateTableName (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        cursor TEXT,
        updated_at INTEGER NOT NULL
      )
    ''');
    await customStatement('''
      INSERT OR IGNORE INTO $_syncStateTableName (id, cursor, updated_at)
      VALUES (1, NULL, 0)
    ''');
  }

  Future<void> _enqueueMutation({
    required String entityType,
    required String entityId,
    String? spaceId,
    required String operation,
    required Map<String, dynamic> payload,
    required int updatedAt,
    required int version,
  }) async {
    await into(outboxEntriesTable).insert(
      OutboxEntriesTableCompanion.insert(
        entityType: entityType,
        entityId: entityId,
        spaceId: Value(spaceId),
        operation: operation,
        payload: jsonEncode(payload),
        updatedAt: updatedAt,
        version: version,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}

String _membershipKey(String spaceId, String userId) => '$spaceId|$userId';

bool _doubleEquals(double a, double b) => (a - b).abs() < 0.000001;

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
