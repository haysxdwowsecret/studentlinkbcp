class Concern {
  final int id;
  final String referenceNumber;
  final String subject;
  final String description;
  final String type;
  final String priority;
  final String status;
  final bool isAnonymous;
  final StudentInfo student;
  final DepartmentInfo department;
  final FacilityInfo? facility;
  final AssigneeInfo? assignedTo;
  final List<String> attachments;
  final DateTime? dueDate;
  final DateTime? resolvedAt;
  final DateTime? closedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ConcernMessage>? messages;

  Concern({
    required this.id,
    required this.referenceNumber,
    required this.subject,
    required this.description,
    required this.type,
    required this.priority,
    required this.status,
    required this.isAnonymous,
    required this.student,
    required this.department,
    this.facility,
    this.assignedTo,
    required this.attachments,
    this.dueDate,
    this.resolvedAt,
    this.closedAt,
    required this.createdAt,
    required this.updatedAt,
    this.messages,
  });

  factory Concern.fromJson(Map<String, dynamic> json) {
    return Concern(
      id: json['id'],
      referenceNumber: json['reference_number'],
      subject: json['subject'],
      description: json['description'],
      type: json['type'],
      priority: json['priority'],
      status: json['status'],
      isAnonymous: json['is_anonymous'],
      student: StudentInfo.fromJson(json['student']),
      department: DepartmentInfo.fromJson(json['department']),
      facility: json['facility'] != null 
          ? FacilityInfo.fromJson(json['facility']) 
          : null,
      assignedTo: json['assigned_to'] != null 
          ? AssigneeInfo.fromJson(json['assigned_to']) 
          : null,
      attachments: List<String>.from(json['attachments'] ?? []),
      dueDate: json['due_date'] != null 
          ? DateTime.parse(json['due_date']) 
          : null,
      resolvedAt: json['resolved_at'] != null 
          ? DateTime.parse(json['resolved_at']) 
          : null,
      closedAt: json['closed_at'] != null 
          ? DateTime.parse(json['closed_at']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      messages: json['messages'] != null 
          ? (json['messages'] as List)
              .map((m) => ConcernMessage.fromJson(m))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference_number': referenceNumber,
      'subject': subject,
      'description': description,
      'type': type,
      'priority': priority,
      'status': status,
      'is_anonymous': isAnonymous,
      'student': student.toJson(),
      'department': department.toJson(),
      'facility': facility?.toJson(),
      'assigned_to': assignedTo?.toJson(),
      'attachments': attachments,
      'due_date': dueDate?.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'messages': messages?.map((m) => m.toJson()).toList(),
    };
  }

  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
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

  String get typeDisplayName {
    switch (type) {
      case 'academic':
        return 'Academic';
      case 'administrative':
        return 'Administrative';
      case 'technical':
        return 'Technical';
      case 'health':
        return 'Health';
      case 'safety':
        return 'Safety';
      case 'other':
        return 'Other';
      default:
        return type;
    }
  }
}

class StudentInfo {
  final int id;
  final String name;
  final String displayId;

  StudentInfo({
    required this.id,
    required this.name,
    required this.displayId,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
      id: json['id'],
      name: json['name'],
      displayId: json['display_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_id': displayId,
    };
  }
}

class DepartmentInfo {
  final int id;
  final String name;
  final String code;

  DepartmentInfo({
    required this.id,
    required this.name,
    required this.code,
  });

  factory DepartmentInfo.fromJson(Map<String, dynamic> json) {
    return DepartmentInfo(
      id: json['id'],
      name: json['name'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }
}

class FacilityInfo {
  final int id;
  final String name;

  FacilityInfo({
    required this.id,
    required this.name,
  });

  factory FacilityInfo.fromJson(Map<String, dynamic> json) {
    return FacilityInfo(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class AssigneeInfo {
  final int id;
  final String name;
  final String role;

  AssigneeInfo({
    required this.id,
    required this.name,
    required this.role,
  });

  factory AssigneeInfo.fromJson(Map<String, dynamic> json) {
    return AssigneeInfo(
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

class ConcernMessage {
  final int id;
  final String message;
  final String type;
  final AuthorInfo author;
  final List<String> attachments;
  final bool isInternal;
  final bool isAiGenerated;
  final DateTime? readAt;
  final DateTime createdAt;

  ConcernMessage({
    required this.id,
    required this.message,
    required this.type,
    required this.author,
    required this.attachments,
    required this.isInternal,
    required this.isAiGenerated,
    this.readAt,
    required this.createdAt,
  });

  factory ConcernMessage.fromJson(Map<String, dynamic> json) {
    return ConcernMessage(
      id: json['id'],
      message: json['message'],
      type: json['type'],
      author: AuthorInfo.fromJson(json['author']),
      attachments: List<String>.from(json['attachments'] ?? []),
      isInternal: json['is_internal'],
      isAiGenerated: json['is_ai_generated'],
      readAt: json['read_at'] != null 
          ? DateTime.parse(json['read_at']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'type': type,
      'author': author.toJson(),
      'attachments': attachments,
      'is_internal': isInternal,
      'is_ai_generated': isAiGenerated,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
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
