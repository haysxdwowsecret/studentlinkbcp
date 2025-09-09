class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String department;
  final int departmentId;
  final String? displayId;
  final String? avatar;
  final Map<String, dynamic>? preferences;
  final DateTime? lastLoginAt;
  final int unreadNotificationsCount;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.departmentId,
    this.displayId,
    this.avatar,
    this.preferences,
    this.lastLoginAt,
    this.unreadNotificationsCount = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      department: json['department'],
      departmentId: json['department_id'],
      displayId: json['display_id'],
      avatar: json['avatar'],
      preferences: json['preferences'],
      lastLoginAt: json['last_login_at'] != null 
          ? DateTime.parse(json['last_login_at']) 
          : null,
      unreadNotificationsCount: json['unread_notifications_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'department': department,
      'department_id': departmentId,
      'display_id': displayId,
      'avatar': avatar,
      'preferences': preferences,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'unread_notifications_count': unreadNotificationsCount,
    };
  }

  bool get isStudent => role == 'student';
  bool get isFaculty => role == 'faculty';
  bool get isStaff => role == 'staff';
  bool get isDepartmentHead => role == 'department_head';
  bool get isAdmin => role == 'admin';

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? department,
    int? departmentId,
    String? displayId,
    String? avatar,
    Map<String, dynamic>? preferences,
    DateTime? lastLoginAt,
    int? unreadNotificationsCount,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      department: department ?? this.department,
      departmentId: departmentId ?? this.departmentId,
      displayId: displayId ?? this.displayId,
      avatar: avatar ?? this.avatar,
      preferences: preferences ?? this.preferences,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      unreadNotificationsCount: unreadNotificationsCount ?? this.unreadNotificationsCount,
    );
  }
}
