import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';
import '../../../services/api_service.dart';
import '../../../services/websocket_service.dart';
import '../../../models/chat_room.dart';
import '../../../models/concern.dart';
import 'resolution_confirmation_widget.dart';

class EnhancedConcernChatScreen extends StatefulWidget {
  final Map<String, dynamic> concern;
  final VoidCallback? onResolutionUpdated;

  const EnhancedConcernChatScreen({
    Key? key,
    required this.concern,
    this.onResolutionUpdated,
  }) : super(key: key);

  @override
  State<EnhancedConcernChatScreen> createState() => _EnhancedConcernChatScreenState();
}

class _EnhancedConcernChatScreenState extends State<EnhancedConcernChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ChatMessage> _messages = [];
  ChatRoom? _chatRoom;
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChatData();
    _setupWebSocketListeners();
    _messageController.addListener(_onMessageChanged);
  }

  @override
  void dispose() {
    _messageController.removeListener(_onMessageChanged);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onMessageChanged() {
    setState(() {}); // Rebuild to update send button state
  }

  Future<void> _loadChatData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load or create chat room
      final chatRoomData = await apiService.getOrCreateChatRoom(widget.concern['id']);
      _chatRoom = ChatRoom.fromJson(chatRoomData);
      
      // Load chat messages
      final messagesData = await apiService.getChatMessages(_chatRoom!.id);
      _messages = messagesData.map((msg) => ChatMessage.fromJson(msg)).toList();
      
      setState(() {
        _isLoading = false;
      });
      
      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load chat data: ${e.toString()}';
      });
    }
  }

  void _setupWebSocketListeners() {
    final websocketService = WebSocketService();
    
    // Listen for new messages
    if (_chatRoom != null) {
      websocketService.subscribeToChatRoom(_chatRoom!.id, (data) {
        if (mounted) {
          _handleWebSocketEvent(data);
        }
      });
    }
    
    // Listen for resolution updates
    websocketService.subscribeToResolutionUpdates((data) {
      if (mounted) {
        _handleResolutionUpdate(data);
      }
    });
  }

  void _handleWebSocketEvent(Map<String, dynamic> data) {
    final eventType = data['type'] as String?;
    
    switch (eventType) {
      case 'new_message':
        final messageData = data['data'] as Map<String, dynamic>?;
        if (messageData != null) {
          setState(() {
            _messages.add(ChatMessage.fromJson(messageData));
          });
          _scrollToBottom();
        }
        break;
      case 'chat_room_closed':
        setState(() {
          _chatRoom = _chatRoom?.copyWith(status: 'closed');
        });
        break;
      case 'chat_room_reopened':
        setState(() {
          _chatRoom = _chatRoom?.copyWith(status: 'active');
        });
        break;
    }
  }

  void _handleResolutionUpdate(Map<String, dynamic> data) {
    final eventType = data['type'] as String?;
    final concernData = data['concern'] as Map<String, dynamic>?;
    
    if (concernData != null && concernData['id'] == widget.concern['id']) {
      setState(() {
        // Update concern data
        widget.concern.clear();
        widget.concern.addAll(concernData);
      });
      
      // Show notification
      _showResolutionNotification(eventType);
      
      // Refresh chat data
      _loadChatData();
    }
  }

  void _showResolutionNotification(String? eventType) {
    String title;
    String message;
    Color color;
    
    switch (eventType) {
      case 'resolution_confirmed':
        title = 'Resolution Confirmed!';
        message = 'Your concern has been marked as resolved.';
        color = AppTheme.successLight;
        break;
      case 'resolution_disputed':
        title = 'Resolution Disputed';
        message = 'Your concern has been reopened for discussion.';
        color = AppTheme.warningLight;
        break;
      case 'chat_room_closed':
        title = 'Chat Closed';
        message = 'The chat room for this concern has been closed.';
        color = AppTheme.primaryLight;
        break;
      case 'chat_room_reopened':
        title = 'Chat Reopened';
        message = 'The chat room has been reopened for further discussion.';
        color = AppTheme.successLight;
        break;
      default:
        return;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              message,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) return;
    
    setState(() {
      _isSending = true;
    });

    try {
      final message = _messageController.text.trim();
      _messageController.clear();
      
      await apiService.sendChatMessage(
        _chatRoom!.id,
        message,
        messageType: 'text',
      );
      
      setState(() {
        _isSending = false;
      });
      
    } catch (e) {
      setState(() {
        _isSending = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: ${e.toString()}'),
          backgroundColor: AppTheme.emergencyLight,
        ),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  bool get _canSendMessage {
    return _chatRoom?.isActive == true && 
           widget.concern['status'] != 'student_confirmed' && 
           widget.concern['status'] != 'closed';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Concern status and resolution actions
          _buildConcernStatusSection(),
          
          // Chat messages area
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _error != null
                    ? _buildErrorState()
                    : _buildChatMessages(),
          ),
          
          // Resolution confirmation widget (if needed)
          if (widget.concern['status'] == 'staff_resolved')
            ResolutionConfirmationWidget(
              concern: widget.concern,
              onResolutionUpdated: () {
                widget.onResolutionUpdated?.call();
                _loadChatData();
              },
            ),
          
          // Chat input area
          _buildChatInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primaryLight,
      foregroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Concern Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (widget.concern['reference_number'] != null)
            Text(
              'Ref: ${widget.concern['reference_number']}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: _loadChatData,
        ),
      ],
    );
  }

  Widget _buildConcernStatusSection() {
    final status = widget.concern['status'] as String? ?? 'unknown';
    final statusColor = _getStatusColor(status);
    final statusLabel = _getStatusLabel(status);
    final statusIcon = _getStatusIcon(status);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: statusColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: $statusLabel',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (status == 'staff_resolved')
                  const Text(
                    'Please confirm or dispute the resolution',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading conversation...',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppTheme.emergencyLight,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to Load Chat',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Something went wrong while loading the conversation.',
              textAlign: TextAlign.center,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _loadChatData,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Retry'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryLight,
                    side: BorderSide(color: AppTheme.primaryLight),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Back'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryLight,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessages() {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a conversation about your concern',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isSystemMessage = message.isSystem || 
                           message.isResolutionConfirmation || 
                           message.isResolutionDispute ||
                           message.isChatClosure ||
                           message.isChatReopened;
    
    if (isSystemMessage) {
      return _buildSystemMessage(message);
    }
    
    return _buildUserMessage(message);
  }

  Widget _buildSystemMessage(ChatMessage message) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    
    if (message.isResolutionConfirmation) {
      backgroundColor = AppTheme.successLight.withValues(alpha: 0.1);
      textColor = AppTheme.successLight;
      icon = Icons.check_circle_rounded;
    } else if (message.isResolutionDispute) {
      backgroundColor = AppTheme.emergencyLight.withValues(alpha: 0.1);
      textColor = AppTheme.emergencyLight;
      icon = Icons.report_problem_rounded;
    } else if (message.isChatClosure) {
      backgroundColor = AppTheme.primaryLight.withValues(alpha: 0.1);
      textColor = AppTheme.primaryLight;
      icon = Icons.lock_rounded;
    } else if (message.isChatReopened) {
      backgroundColor = AppTheme.warningLight.withValues(alpha: 0.1);
      textColor = AppTheme.warningLight;
      icon = Icons.lock_open_rounded;
    } else {
      backgroundColor = Colors.grey[100]!;
      textColor = Colors.grey[700]!;
      icon = Icons.info_rounded;
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: textColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: textColor.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: textColor,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message.message,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessage(ChatMessage message) {
    final isMe = message.authorId == 1; // Assuming user ID 1 is current user
    final showAvatar = _shouldShowAvatar(message);
    final showTimestamp = _shouldShowTimestamp(message);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && showAvatar) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryLight.withValues(alpha: 0.1),
              child: Icon(
                Icons.person_rounded,
                size: 16,
                color: AppTheme.primaryLight,
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? AppTheme.primaryLight : Colors.grey[100],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.message,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),
                ),
                
                if (showTimestamp) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatMessageTime(message.createdAt),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        _buildMessageStatus(message),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          if (isMe && showAvatar) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryLight,
              child: const Icon(
                Icons.person_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment button
            Container(
              decoration: BoxDecoration(
                color: _canSendMessage ? Colors.grey[100] : Colors.grey[50],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _canSendMessage ? () {} : null,
                icon: Icon(
                  Icons.add_rounded,
                  color: _canSendMessage ? AppTheme.primaryLight : Colors.grey[400],
                  size: 24,
                ),
                padding: const EdgeInsets.all(12),
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Message input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _canSendMessage ? Colors.grey[200]! : Colors.grey[100]!,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  enabled: _canSendMessage,
                  maxLines: 5,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: _canSendMessage 
                        ? 'Message...' 
                        : _getChatDisabledMessage(),
                    hintStyle: TextStyle(
                      color: _canSendMessage ? Colors.grey[500] : Colors.grey[400],
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.3,
                  ),
                  onSubmitted: _canSendMessage ? (_) => _sendMessage() : null,
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Send button
            Container(
              decoration: BoxDecoration(
                color: _canSendMessage && _messageController.text.trim().isNotEmpty 
                    ? AppTheme.primaryLight 
                    : Colors.grey[300],
                shape: BoxShape.circle,
                boxShadow: _canSendMessage && _messageController.text.trim().isNotEmpty
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryLight.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: IconButton(
                onPressed: _canSendMessage && !_isSending && _messageController.text.trim().isNotEmpty 
                    ? _sendMessage 
                    : null,
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                padding: const EdgeInsets.all(12),
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getChatDisabledMessage() {
    final status = widget.concern['status'] as String? ?? 'unknown';
    
    switch (status) {
      case 'student_confirmed':
        return 'Chat closed - concern resolved';
      case 'closed':
        return 'Chat closed';
      case 'cancelled':
        return 'Chat disabled - concern cancelled';
      default:
        return 'Chat unavailable';
    }
  }

  bool _shouldShowAvatar(ChatMessage message) {
    final messageIndex = _messages.indexOf(message);
    if (messageIndex == 0) return true;
    
    final previousMessage = _messages[messageIndex - 1];
    final timeDiff = message.createdAt.difference(previousMessage.createdAt);
    
    return previousMessage.authorId != message.authorId || 
           timeDiff.inMinutes > 5;
  }

  bool _shouldShowTimestamp(ChatMessage message) {
    final messageIndex = _messages.indexOf(message);
    if (messageIndex == _messages.length - 1) return true;
    
    final nextMessage = _messages[messageIndex + 1];
    final timeDiff = nextMessage.createdAt.difference(message.createdAt);
    
    return nextMessage.authorId != message.authorId || 
           timeDiff.inMinutes > 5;
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (messageDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildMessageStatus(ChatMessage message) {
    if (message.isRead) {
      return Icon(
        Icons.done_all_rounded,
        size: 12,
        color: AppTheme.primaryLight,
      );
    } else if (message.isDelivered) {
      return Icon(
        Icons.done_all_rounded,
        size: 12,
        color: Colors.grey[400],
      );
    } else {
      return Icon(
        Icons.done_rounded,
        size: 12,
        color: Colors.grey[400],
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppTheme.primaryLight;
      case 'approved':
        return AppTheme.successLight;
      case 'in_progress':
        return AppTheme.warningLight;
      case 'staff_resolved':
        return const Color(0xFF3B82F6);
      case 'student_confirmed':
        return AppTheme.successLight;
      case 'disputed':
        return AppTheme.emergencyLight;
      case 'closed':
        return const Color(0xFF6B7280);
      case 'cancelled':
        return const Color(0xFF9CA3AF);
      default:
        return const Color(0xFF9CA3AF);
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'in_progress':
        return 'In Progress';
      case 'staff_resolved':
        return 'Staff Resolved';
      case 'student_confirmed':
        return 'Student Confirmed';
      case 'disputed':
        return 'Disputed';
      case 'closed':
        return 'Closed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule_rounded;
      case 'approved':
        return Icons.verified_rounded;
      case 'in_progress':
        return Icons.hourglass_empty_rounded;
      case 'staff_resolved':
        return Icons.engineering_rounded;
      case 'student_confirmed':
        return Icons.check_circle_rounded;
      case 'disputed':
        return Icons.report_problem_rounded;
      case 'closed':
        return Icons.lock_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}

// Extension to add copyWith method to ChatRoom
extension ChatRoomCopyWith on ChatRoom {
  ChatRoom copyWith({
    int? id,
    int? concernId,
    String? roomName,
    String? status,
    DateTime? lastActivityAt,
    Map<String, dynamic>? participants,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    Concern? concern,
    ChatMessage? latestMessage,
    int? unreadCount,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      concernId: concernId ?? this.concernId,
      roomName: roomName ?? this.roomName,
      status: status ?? this.status,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      participants: participants ?? this.participants,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      concern: concern ?? this.concern,
      latestMessage: latestMessage ?? this.latestMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
