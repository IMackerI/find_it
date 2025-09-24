import 'dart:convert';

typedef JsonMap = Map<String, dynamic>;

double _toDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.parse(value.toString());
}

class RemoteSpace {
  RemoteSpace({
    required this.id,
    required this.name,
    required this.positionDx,
    required this.positionDy,
    required this.sizeWidth,
    required this.sizeHeight,
    this.parentId,
    required this.version,
    required this.updatedAt,
    this.isDeleted = false,
  });

  final String id;
  final String name;
  final double positionDx;
  final double positionDy;
  final double sizeWidth;
  final double sizeHeight;
  final String? parentId;
  final int version;
  final DateTime updatedAt;
  final bool isDeleted;

  JsonMap toJson() {
    return {
      'id': id,
      'name': name,
      'positionDx': positionDx,
      'positionDy': positionDy,
      'sizeWidth': sizeWidth,
      'sizeHeight': sizeHeight,
      'parentId': parentId,
      'version': version,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
    };
  }

  factory RemoteSpace.fromJson(JsonMap json) {
    return RemoteSpace(
      id: json['id'] as String,
      name: json['name'] as String,
      positionDx: _toDouble(json['positionDx']),
      positionDy: _toDouble(json['positionDy']),
      sizeWidth: _toDouble(json['sizeWidth']),
      sizeHeight: _toDouble(json['sizeHeight']),
      parentId: json['parentId'] as String?,
      version: json['version'] as int,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        json['updatedAt'] as int,
      ),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }
}

class RemoteItem {
  RemoteItem({
    required this.id,
    required this.spaceId,
    required this.name,
    required this.description,
    this.locationSpecification,
    this.tags,
    this.imagePath,
    required this.version,
    required this.updatedAt,
    this.isDeleted = false,
  });

  final String id;
  final String spaceId;
  final String name;
  final String description;
  final String? locationSpecification;
  final List<String>? tags;
  final String? imagePath;
  final int version;
  final DateTime updatedAt;
  final bool isDeleted;

  JsonMap toJson() {
    return {
      'id': id,
      'spaceId': spaceId,
      'name': name,
      'description': description,
      'locationSpecification': locationSpecification,
      'tags': tags,
      'imagePath': imagePath,
      'version': version,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
    };
  }

  factory RemoteItem.fromJson(JsonMap json) {
    return RemoteItem(
      id: json['id'] as String,
      spaceId: json['spaceId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      locationSpecification: json['locationSpecification'] as String?,
      tags: json['tags'] == null
          ? null
          : List<String>.from(json['tags'] as List<dynamic>),
      imagePath: json['imagePath'] as String?,
      version: json['version'] as int,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        json['updatedAt'] as int,
      ),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }
}

class RemoteUser {
  RemoteUser({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    required this.isCurrentUser,
    required this.version,
    required this.updatedAt,
    this.isDeleted = false,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final bool isCurrentUser;
  final int version;
  final DateTime updatedAt;
  final bool isDeleted;

  JsonMap toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'isCurrentUser': isCurrentUser,
      'version': version,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
    };
  }

  factory RemoteUser.fromJson(JsonMap json) {
    return RemoteUser(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
      version: json['version'] as int,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        json['updatedAt'] as int,
      ),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }
}

class RemoteMembership {
  RemoteMembership({
    required this.spaceId,
    required this.userId,
    required this.role,
    required this.attachmentVisibility,
    this.joinedAt,
    required this.version,
    required this.updatedAt,
    this.isDeleted = false,
  });

  final String spaceId;
  final String userId;
  final String role;
  final String attachmentVisibility;
  final DateTime? joinedAt;
  final int version;
  final DateTime updatedAt;
  final bool isDeleted;

  JsonMap toJson() {
    return {
      'spaceId': spaceId,
      'userId': userId,
      'role': role,
      'attachmentVisibility': attachmentVisibility,
      'joinedAt': joinedAt?.millisecondsSinceEpoch,
      'version': version,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
    };
  }

  factory RemoteMembership.fromJson(JsonMap json) {
    return RemoteMembership(
      spaceId: json['spaceId'] as String,
      userId: json['userId'] as String,
      role: json['role'] as String,
      attachmentVisibility: json['attachmentVisibility'] as String,
      joinedAt: json['joinedAt'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(json['joinedAt'] as int),
      version: json['version'] as int,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        json['updatedAt'] as int,
      ),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }
}

class SyncMutation {
  SyncMutation({
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.version,
    required this.updatedAt,
    this.spaceId,
  });

  final String entityType;
  final String entityId;
  final String operation;
  final Map<String, dynamic> payload;
  final int version;
  final DateTime updatedAt;
  final String? spaceId;

  JsonMap toJson() {
    return {
      'entityType': entityType,
      'entityId': entityId,
      'operation': operation,
      'payload': payload,
      'version': version,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'spaceId': spaceId,
    };
  }

  factory SyncMutation.fromJson(JsonMap json) {
    final payloadDynamic = json['payload'];
    final payload = payloadDynamic is String
        ? jsonDecode(payloadDynamic) as Map<String, dynamic>
        : Map<String, dynamic>.from(payloadDynamic as Map<String, dynamic>);
    return SyncMutation(
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      operation: json['operation'] as String,
      payload: payload,
      version: json['version'] as int,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        json['updatedAt'] as int,
      ),
      spaceId: json['spaceId'] as String?,
    );
  }
}

class SyncRequest {
  SyncRequest({
    required this.mutations,
    this.cursor,
  });

  final List<SyncMutation> mutations;
  final String? cursor;

  JsonMap toJson() {
    return {
      'cursor': cursor,
      'mutations': mutations.map((mutation) => mutation.toJson()).toList(),
    };
  }

  factory SyncRequest.fromJson(JsonMap json) {
    final mutations = (json['mutations'] as List<dynamic>? ?? const [])
        .map(
          (dynamic entry) => SyncMutation.fromJson(
            Map<String, dynamic>.from(entry as Map),
          ),
        )
        .toList();
    return SyncRequest(
      mutations: mutations,
      cursor: json['cursor'] as String?,
    );
  }
}

class SyncResponse {
  SyncResponse({
    required this.spaces,
    required this.items,
    required this.users,
    required this.memberships,
    this.cursor,
  });

  final List<RemoteSpace> spaces;
  final List<RemoteItem> items;
  final List<RemoteUser> users;
  final List<RemoteMembership> memberships;
  final String? cursor;

  JsonMap toJson() {
    return {
      'cursor': cursor,
      'spaces': spaces.map((space) => space.toJson()).toList(),
      'items': items.map((item) => item.toJson()).toList(),
      'users': users.map((user) => user.toJson()).toList(),
      'memberships':
          memberships.map((member) => member.toJson()).toList(),
    };
  }

  factory SyncResponse.fromJson(JsonMap json) {
    List<T> parseList<T>(String key, T Function(JsonMap json) parser) {
      final value = json[key];
      if (value is List) {
        return value
            .map((entry) => parser(Map<String, dynamic>.from(entry as Map)))
            .toList();
      }
      return const [];
    }

    return SyncResponse(
      cursor: json['cursor'] as String?,
      spaces: parseList('spaces', RemoteSpace.fromJson),
      items: parseList('items', RemoteItem.fromJson),
      users: parseList('users', RemoteUser.fromJson),
      memberships: parseList('memberships', RemoteMembership.fromJson),
    );
  }

  factory SyncResponse.empty() {
    return SyncResponse(
      spaces: const [],
      items: const [],
      users: const [],
      memberships: const [],
    );
  }
}
