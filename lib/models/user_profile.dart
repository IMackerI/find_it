import 'package:uuid/uuid.dart';

class UserProfile {
  UserProfile({
    String? id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.isCurrentUser = false,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final bool isCurrentUser;

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    bool? isCurrentUser,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'isCurrentUser': isCurrentUser,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String?,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
    );
  }
}
