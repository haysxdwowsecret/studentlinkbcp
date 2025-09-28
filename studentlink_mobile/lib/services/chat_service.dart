import 'dart:async';
import 'dart:convert';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../config/app_config.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  PusherChannelsFlutter? _pusher;
  bool _isConnected = false;
  final Map<String, StreamController<Map<String, dynamic>>> _messageStreams = {};

  bool get isConnected => _isConnected;

  /// Initialize chat service and connect to WebSocket
  Future<void> initialize() async {
    try {
      print('💬 Initializing chat service...');

      _pusher = PusherChannelsFlutter.getInstance();
      
      await _pusher!.init(
        apiKey: AppConfig.pusherAppKey,
        cluster: AppConfig.pusherCluster,
        onConnectionStateChange: (String currentState, String previousState) {
          print('Pusher chat connection state: $previousState -> $currentState');
          _isConnected = currentState == 'connected';
        },
        onError: (String message, int? code, dynamic e) {
          print('Pusher chat error: $message (Code: $code)');
          _isConnected = false;
        },
        onSubscriptionSucceeded: (String channelName, dynamic data) {
          print('Successfully subscribed to chat channel: $channelName');
        },
        onSubscriptionError: (String message, dynamic e) {
          print('Chat subscription error: $message');
        },
        onEvent: (event) {
          print('Received chat event: ${event.eventName} on channel: ${event.channelName}');
          _handleChatEvent(event);
        },
      );

      await _pusher!.connect();
      _isConnected = true;
      print('✅ Chat service initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize chat service: $e');
      _isConnected = false;
    }
  }

  /// Subscribe to a chat room for real-time messages
  Future<void> subscribeToChatRoom(int chatRoomId) async {
    if (!_isConnected || _pusher == null) {
      print('❌ Chat service not connected, cannot subscribe to room $chatRoomId');
      return;
    }

    try {
      final channelName = 'private-chat.room.$chatRoomId';
      
      // Create message stream for this chat room
      if (!_messageStreams.containsKey(channelName)) {
        _messageStreams[channelName] = StreamController<Map<String, dynamic>>.broadcast();
      }

      await _pusher!.subscribe(channelName: channelName);
      print('✅ Subscribed to chat room: $chatRoomId');
    } catch (e) {
      print('❌ Failed to subscribe to chat room $chatRoomId: $e');
    }
  }

  /// Unsubscribe from a chat room
  Future<void> unsubscribeFromChatRoom(int chatRoomId) async {
    if (!_isConnected || _pusher == null) {
      return;
    }

    try {
      final channelName = 'private-chat.room.$chatRoomId';
      await _pusher!.unsubscribe(channelName: channelName);
      
      // Close and remove message stream
      _messageStreams[channelName]?.close();
      _messageStreams.remove(channelName);
      
      print('✅ Unsubscribed from chat room: $chatRoomId');
    } catch (e) {
      print('❌ Failed to unsubscribe from chat room $chatRoomId: $e');
    }
  }

  /// Get message stream for a chat room
  Stream<Map<String, dynamic>>? getMessageStream(int chatRoomId) {
    final channelName = 'private-chat.room.$chatRoomId';
    return _messageStreams[channelName]?.stream;
  }

  /// Handle incoming chat events
  void _handleChatEvent(PusherEvent event) {
    try {
      final channelName = event.channelName;
      final eventName = event.eventName;
      final data = event.data;

      print('📨 Chat event received: $eventName on $channelName');

      // Handle new message events
      if (eventName == 'new_message') {
        final messageData = data is String ? jsonDecode(data) : data;
        
        // Add to message stream
        if (_messageStreams.containsKey(channelName)) {
          _messageStreams[channelName]!.add(messageData);
        }
      }
    } catch (e) {
      print('❌ Error handling chat event: $e');
    }
  }

  /// Send message to chat room
  Future<Map<String, dynamic>> sendMessage({
    required int chatRoomId,
    required String message,
    String messageType = 'text',
    List<String>? attachments,
  }) async {
    try {
      // This will be implemented when the API service is updated
      print('📤 Sending message to chat room $chatRoomId: $message');
      return {'success': true, 'message': 'Message sent (placeholder)'};
    } catch (e) {
      print('❌ Failed to send message: $e');
      rethrow;
    }
  }

  /// Get chat room messages
  Future<Map<String, dynamic>> getMessages({
    required int chatRoomId,
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      // This will be implemented when the API service is updated
      print('📥 Getting messages for chat room $chatRoomId');
      return {'success': true, 'data': []};
    } catch (e) {
      print('❌ Failed to get messages: $e');
      rethrow;
    }
  }

  /// Mark messages as read
  Future<void> markAsRead(int chatRoomId) async {
    try {
      // This will be implemented when the API service is updated
      print('✅ Marking messages as read for chat room $chatRoomId');
    } catch (e) {
      print('❌ Failed to mark messages as read: $e');
    }
  }

  /// Get or create chat room for concern
  Future<Map<String, dynamic>> getOrCreateChatRoom(int concernId) async {
    try {
      // This will be implemented when the API service is updated
      print('🏠 Getting or creating chat room for concern $concernId');
      return {'success': true, 'data': {'id': concernId}};
    } catch (e) {
      print('❌ Failed to get or create chat room: $e');
      rethrow;
    }
  }

  /// Get active chat rooms
  Future<Map<String, dynamic>> getActiveChatRooms() async {
    try {
      // This will be implemented when the API service is updated
      print('📋 Getting active chat rooms');
      return {'success': true, 'data': []};
    } catch (e) {
      print('❌ Failed to get active chat rooms: $e');
      rethrow;
    }
  }

  /// Close chat room
  Future<void> closeChatRoom(int chatRoomId) async {
    try {
      // This will be implemented when the API service is updated
      print('🔒 Closing chat room $chatRoomId');
    } catch (e) {
      print('❌ Failed to close chat room: $e');
    }
  }

  /// Disconnect chat service
  Future<void> disconnect() async {
    try {
      if (_pusher != null) {
        await _pusher!.disconnect();
      }
      
      // Close all message streams
      for (var stream in _messageStreams.values) {
        stream.close();
      }
      _messageStreams.clear();
      
      _isConnected = false;
      print('✅ Chat service disconnected');
    } catch (e) {
      print('❌ Error disconnecting chat service: $e');
    }
  }
}

