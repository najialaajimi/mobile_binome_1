class AppUser {
  final String id;
  final String fullName;
  final String email;
  final String password;
  final String role; // 'tenant', 'owner', 'admin'
  final bool isVerified;
  final String? avatarUrl;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
    this.isVerified = false,
    this.avatarUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'password': password,
        'role': role,
        'isVerified': isVerified,
        'avatarUrl': avatarUrl,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        password: json['password'] as String,
        role: json['role'] as String,
        isVerified: json['isVerified'] as bool? ?? false,
        avatarUrl: json['avatarUrl'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  AppUser copyWith({
    String? id,
    String? fullName,
    String? email,
    String? password,
    String? role,
    bool? isVerified,
    String? avatarUrl,
    DateTime? createdAt,
  }) =>
      AppUser(
        id: id ?? this.id,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        password: password ?? this.password,
        role: role ?? this.role,
        isVerified: isVerified ?? this.isVerified,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        createdAt: createdAt ?? this.createdAt,
      );

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }
}
