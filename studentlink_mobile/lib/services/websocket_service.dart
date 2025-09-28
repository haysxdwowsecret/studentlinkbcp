
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../config/app_config.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  bool _isConnected = false;
  PusherChannelsFlutter? _pusher;
  final Map<String, Function(Map<String, dynamic>)> _listeners = {};

  bool get isConnected => _isConnected;

  void connect() async {
    if (_isConnected) return;

    try {
      // Initialize Pusher with real configuration
      _pusher = PusherChannelsFlutter.getInstance();
      
      await _pusher!.init(
        apiKey: AppConfig.pusherAppKey,
        cluster: AppConfig.pusherCluster,
        onConnectionStateChange: (String currentState, String previousState) {
          print('Pusher connection state changed: $previousState -> $currentState');
          _isConnected = currentState == 'connected';
        },
        onError: (String message, int? code, dynamic e) {
          print('Pusher error: $message (Code: $code)');
          _isConnected = false;
        },
        onSubscriptionSucceeded: (String channelName, dynamic data) {
          print('Successfully subscribed to channel: $channelName');
        },
        onSubscriptionError: (String message, dynamic e) {
          print('Subscription error: $message');
        },
        onEvent: (event) {
          print('Received event: ${event.eventName} on channel: ${event.channelName}');
          _handleEvent(event);
        },
      );

      await _pusher!.connect();
      _isConnected = true;
      print('✅ Pusher WebSocket service connected successfully');
    } catch (e) {
      print('❌ Failed to connect to Pusher WebSocket: $e');
      _isConnected = false;
    }
  }

  void disconnect() async {
    if (_pusher != null) {
      await _pusher!.disconnect();
    }
    _isConnected = false;
    _listeners.clear();
    print('WebSocket service disconnected');
  }

  void _handleEvent(PusherEvent event) {
    final channelName = event.channelName;
    final eventName = event.eventName;
    final data = event.data;

    print('Handling event: $eventName on channel: $channelName');

    // Find the appropriate listener
    final listener = _listeners[channelName];
    if (listener != null) {
      try {
        // Parse the data and call the listener
        final eventData = {
          'type': eventName,
          'data': data,
          'channel': channelName,
        };
        listener(eventData);
      } catch (e) {
        print('Error handling event: $e');
      }
    }
  }

  void subscribeToConcerns(Function(Map<String, dynamic>) callback) {
    if (_pusher == null || !_isConnected) {
      print('Pusher not connected, cannot subscribe to concerns');
      return;
    }

    _listeners['concerns'] = callback;
    _pusher!.subscribe(channelName: 'concerns');
    print('✅ Subscribed to concerns channel');
  }

  void subscribeToResolutionUpdates(Function(Map<String, dynamic>) callback) {
    if (_pusher == null || !_isConnected) {
      print('Pusher not connected, cannot subscribe to resolution updates');
      return;
    }

    _listeners['resolution_updates'] = callback;
    _pusher!.subscribe(channelName: 'resolution_updates');
    print('✅ Subscribed to resolution updates channel');
  }

  void subscribeToDepartmentConcerns(int departmentId, Function(Map<String, dynamic>) callback) {
    if (_pusher == null || !_isConnected) {
      print('Pusher not connected, cannot subscribe to department concerns');
      return;
    }

    final channelName = 'concerns.department.$departmentId';
    _listeners[channelName] = callback;
    _pusher!.subscribe(channelName: channelName);
    print('✅ Subscribed to department concerns channel: $channelName');
  }

  // Chat-specific methods
  void subscribeToChatRoom(int chatRoomId, Function(Map<String, dynamic>) callback) {
    if (_pusher == null || !_isConnected) {
      print('Pusher not connected, cannot subscribe to chat room');
      return;
    }

    final channelName = 'private-chat.room.$chatRoomId';
    _listeners[channelName] = callback;
    _pusher!.subscribe(channelName: channelName);
    print('✅ Subscribed to chat room: $channelName');
  }

  void subscribeToUserChat(int userId, Function(Map<String, dynamic>) callback) {
    if (_pusher == null || !_isConnected) {
      print('Pusher not connected, cannot subscribe to user chat');
      return;
    }

    final channelName = 'private-chat.user.$userId';
    _listeners[channelName] = callback;
    print('Subscribed to user chat: $channelName');
  }

  void sendTypingStatus(int chatRoomId, int userId, bool isTyping) {
    if (_pusher == null || !_isConnected) {
      print('Pusher not connected, cannot send typing status');
      return;
    }

    final channelName = 'private-chat.room.$chatRoomId';
    final eventData = {
      'user_id': userId,
      'is_typing': isTyping,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    _pusher!.trigger(
      PusherEvent(
        channelName: channelName,
        eventName: 'typing_status',
        data: eventData,
      ),
    );

    print('✅ Sent typing status: User $userId is ${isTyping ? 'typing' : 'not typing'} in room $chatRoomId');
  }

  void sendMessage(int chatRoomId, String message, {String messageType = 'text', int? replyToId}) {
    if (_pusher == null || !_isConnected) {
      print('Pusher not connected, cannot send message');
      return;
    }

    final channelName = 'private-chat.room.$chatRoomId';
    final eventData = {
      'message': message,
      'message_type': messageType,
      'reply_to_id': replyToId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    _pusher!.trigger(
      PusherEvent(
        channelName: channelName,
        eventName: 'new_message',
        data: eventData,
      ),
    );

    print('✅ Sent message to room $chatRoomId: $message');
  }

  void unsubscribeFromChannel(String channelName) {
    if (_pusher != null && _isConnected) {
      _pusher!.unsubscribe(channelName: channelName);
    }
    _listeners.remove(channelName);
    print('✅ Unsubscribed from channel: $channelName');
  }

  void unsubscribeFromAllChannels() {
    if (_pusher != null && _isConnected) {
      for (final channelName in _listeners.keys) {
        _pusher!.unsubscribe(channelName: channelName);
      }
    }
    _listeners.clear();
    print('✅ Unsubscribed from all channels');
  }
}