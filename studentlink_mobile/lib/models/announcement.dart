class Announcement {
  final int id;
  final String title;
  final String content;
  final String? excerpt;
  final String type;
  final String priority;
  final String status;
  final AuthorInfo author;
  final List<int>? targetDepartments;
  final List<String>? targetRoles;
  final DateTime? publishedAt;
  final DateTime? expiresAt;
  final String? featuredImage;
  final int viewCount;
  final int bookmarkCount;
  final bool isBookmarked;
  final DateTime createdAt;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    this.excerpt,
    required this.type,
    required this.priority,
    required this.status,
    required this.author,
    this.targetDepartments,
    this.targetRoles,
    this.publishedAt,
    this.expiresAt,
    this.featuredImage,
    required this.viewCount,
    required this.bookmarkCount,
    required this.isBookmarked,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      excerpt: json['excerpt'],
      type: json['type'],
      priority: json['priority'],
      status: json['status'],
      author: AuthorInfo.fromJson(json['author']),
      targetDepartments: json['target_departments'] != null 
          ? List<int>.from(json['target_departments']) 
          : null,
      targetRoles: json['target_roles'] != null 
          ? List<String>.from(json['target_roles']) 
          : null,
      publishedAt: json['published_at'] != null 
          ? DateTime.parse(json['published_at']) 
          : null,
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at']) 
          : null,
      featuredImage: json['featured_image'],
      viewCount: json['view_count'] ?? 0,
      bookmarkCount: json['bookmark_count'] ?? 0,
      isBookmarked: json['is_bookmarked'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'excerpt': excerpt,
      'type': type,
      'priority': priority,
      'status': status,
      'author': author.toJson(),
      'target_departments': targetDepartments,
      'target_roles': targetRoles,
      'published_at': publishedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'featured_image': featuredImage,
      'view_count': viewCount,
      'bookmark_count': bookmarkCount,
      'is_bookmarked': isBookmarked,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get typeDisplayName {
    switch (type) {
      case 'general':
        return 'General';
      case 'academic':
        return 'Academic';
      case 'administrative':
        return 'Administrative';
      case 'event':
        return 'Event';
      case 'emergency':
        return 'Emergency';
      default:
        return type;
    }
  }

  String get priorityDisplayName {
    switch (priority) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      case 'urgent':
        return 'Urgent';
      default:
        return priority;
    }
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isPublished {
    return status == 'published' && 
           (publishedAt == null || DateTime.now().isAfter(publishedAt!));
  }
}

class AuthorInfo {
  final int id;
  final String name;
  final String role;

  AuthorInfo({
    required this.id,
    required this.name,
    required this.role,
  });

  factory AuthorInfo.fromJson(Map<String, dynamic> json) {
    return AuthorInfo(
      id: json['id'],
      name: json['name'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
    };
  }
}
