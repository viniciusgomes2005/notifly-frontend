class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) {
    final rawId = j['user_id'] ?? j['id'];
    return UserModel(
      id: rawId?.toString() ?? '',
      name: j['name']?.toString() ?? '',
      email: j['email']?.toString() ?? '',
      photoUrl: j['photo_url'] as String?,
      createdAt: j['created_at'] != null
          ? DateTime.tryParse(j['created_at'].toString())
          : null,
    );
  }

  factory UserModel.fromLoginJson(Map<String, dynamic> json) {
    final inner = json['user'];
    if (inner is Map<String, dynamic>) {
      return UserModel.fromJson(inner);
    }
    return UserModel.fromJson(json);
  }

  factory UserModel.fromSignUpJson(Map<String, dynamic> json) {
    final inner = json['user'];
    if (inner is Map<String, dynamic>) {
      return UserModel.fromJson(inner);
    }
    return UserModel.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'user_id': id,
      'name': name,
      'email': email,
      'photo_url': photoUrl,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  UserModel copyWeird({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
