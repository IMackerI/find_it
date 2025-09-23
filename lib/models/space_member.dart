import 'user_profile.dart';

enum SpaceRole {
  owner,
  editor,
  viewer,
}

enum AttachmentVisibility {
  shared,
  private,
}

SpaceRole spaceRoleFromName(String value) {
  return SpaceRole.values.firstWhere(
    (role) => role.name == value,
    orElse: () => SpaceRole.viewer,
  );
}

AttachmentVisibility attachmentVisibilityFromName(String value) {
  return AttachmentVisibility.values.firstWhere(
    (visibility) => visibility.name == value,
    orElse: () => AttachmentVisibility.shared,
  );
}

class SpaceMember {
  SpaceMember({
    required this.user,
    required this.role,
    this.joinedAt,
    this.defaultAttachmentVisibility = AttachmentVisibility.shared,
  });

  final UserProfile user;
  final SpaceRole role;
  final DateTime? joinedAt;
  final AttachmentVisibility defaultAttachmentVisibility;

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'role': role.name,
      'joinedAt': joinedAt?.toIso8601String(),
      'attachmentVisibility': defaultAttachmentVisibility.name,
    };
  }

  factory SpaceMember.fromJson(Map<String, dynamic> json) {
    final dynamic userJson = json['user'];
    final UserProfile user;
    if (userJson is Map<String, dynamic>) {
      user = UserProfile.fromJson(userJson);
    } else {
      user = UserProfile(
        id: json['userId'] as String?,
        email: (json['email'] ?? '') as String,
      );
    }
    return SpaceMember(
      user: user,
      role: spaceRoleFromName(json['role'] as String? ?? SpaceRole.viewer.name),
      joinedAt: json['joinedAt'] is String
          ? DateTime.tryParse(json['joinedAt'] as String)
          : null,
      defaultAttachmentVisibility: attachmentVisibilityFromName(
        json['attachmentVisibility'] as String? ??
            AttachmentVisibility.shared.name,
      ),
    );
  }
}
