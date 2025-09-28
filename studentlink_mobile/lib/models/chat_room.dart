import 'concern.dart';
import 'user.dart';

class ChatRoom {
  final int id;
  final int concernId;
  final String roomName;
  final String status;
  final DateTime? lastActivityAt;
  final Map<String, dynamic>? participants;
  final Map<String, dynamic>? settings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Concern? concern;
  final ChatMessage? latestMessage;
  final int unreadCount;

  ChatRoom({
    required this.id,
    required this.concernId,
    required this.roomName,
    required this.status,
    this.lastActivityAt,
    this.participants,
    this.settings,
    required this.createdAt,
    required this.updatedAt,
    this.concern,
    this.latestMessage,
    this.unreadCount = 0,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] ?? 0,
      concernId: json['concern_id'] ?? 0,
      roomName: json['room_name'] ?? '',
      status: json['status'] ?? 'active',
      lastActivityAt: json['last_activity_at'] != null 
          ? DateTime.parse(json['last_activity_at']) 
          : null,
      participants: json['participants'],
      settings: json['settings'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
      concern: json['concern'] != null ? Concern.fromJson(json['concern']) : null,
      latestMessage: json['latest_message'] != null 
          ? ChatMessage.fromJson(json['latest_message']) 
          : null,
      unreadCount: _parseUnreadCount(json['unread_count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'concern_id': concernId,
      'room_name': roomName,
      'status': status,
      'last_activity_at': lastActivityAt?.toIso8601String(),
      'participants': participants,
      'settings': settings,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'concern': concern?.toJson(),
      'latest_message': latestMessage?.toJson(),
      'unread_count': unreadCount,
    };
  }

  bool get isActive => status == 'active';
  bool get isClosed => status == 'closed';
  bool get isArchived => status == 'archived';

  static int _parseUnreadCount(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }
}

class ChatMessage {
  final int id;
  final int concernId;
  final int? chatRoomId;
  final int authorId;
  final String message;
  final String messageType;
  final bool isInternal;
  final bool isTyping;
  final List<String>? attachments;
  final Map<String, dynamic>? metadata;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final Map<String, dynamic>? reactions;
  final int? replyToId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? author;
  final ChatMessage? replyTo;

  ChatMessage({
    required this.id,
    required this.concernId,
    this.chatRoomId,
    required this.authorId,
    required this.message,
    required this.messageType,
    required this.isInternal,
    required this.isTyping,
    this.attachments,
    this.metadata,
    this.deliveredAt,
    this.readAt,
    this.reactions,
    this.replyToId,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.replyTo,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      concernId: json['concern_id'] ?? 0,
      chatRoomId: json['chat_room_id'],
      authorId: json['author_id'] ?? 0,
      message: json['message'] ?? '',
      messageType: json['message_type'] ?? json['type'] ?? 'text',
      isInternal: json['is_internal'] ?? false,
      isTyping: json['is_typing'] ?? false,
      attachments: json['attachments'] != null 
          ? List<String>.from(json['attachments']) 
          : null,
      metadata: json['metadata'],
      deliveredAt: json['delivered_at'] != null 
          ? DateTime.parse(json['delivered_at']) 
          : null,
      readAt: json['read_at'] != null 
          ? DateTime.parse(json['read_at']) 
          : null,
      reactions: json['reactions'],
      replyToId: json['reply_to_id'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
      author: json['author'] != null ? User.fromJson(json['author']) : null,
      replyTo: json['reply_to'] != null ? ChatMessage.fromJson(json['reply_to']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'concern_id': concernId,
      'chat_room_id': chatRoomId,
      'author_id': authorId,
      'message': message,
      'message_type': messageType,
      'is_internal': isInternal,
      'is_typing': isTyping,
      'attachments': attachments,
      'metadata': metadata,
      'delivered_at': deliveredAt?.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'reactions': reactions,
      'reply_to_id': replyToId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'author': author?.toJson(),
      'reply_to': replyTo?.toJson(),
    };
  }

  bool get isText => messageType == 'text';
  bool get isImage => messageType == 'image';
  bool get isFile => messageType == 'file';
  bool get isSystem => messageType == 'system';
  bool get isStatusChange => messageType == 'status_change';
  bool get isResolutionConfirmation => messageType == 'resolution_confirmation';
  bool get isResolutionDispute => messageType == 'resolution_dispute';
  bool get isChatClosure => messageType == 'chat_closure';
  bool get isChatReopened => messageType == 'chat_reopened';
  bool get isRead => readAt != null;
  bool get isDelivered => deliveredAt != null;
}
