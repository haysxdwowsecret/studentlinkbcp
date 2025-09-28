import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../services/hugging_face_service.dart';
import '../../theme/app_theme.dart';
import './widgets/modern_chat_input_widget.dart';
import './widgets/modern_chat_message_widget.dart';
import './widgets/quick_suggestions_modal.dart';
import './widgets/typing_indicator_widget.dart';

/// AI Chat Assistant screen provides intelligent support for students through conversational interface
class AiChatAssistant extends StatefulWidget {
  const AiChatAssistant({Key? key}) : super(key: key);

  @override
  State<AiChatAssistant> createState() => _AiChatAssistantState();
}

class _AiChatAssistantState extends State<AiChatAssistant> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final HuggingFaceService _huggingFaceService = HuggingFaceService();

  List<ChatMessage> _messages = [];
  bool _isTyping = false;

  final List<String> _quickSuggestions = [
    'How to submit a concern?',
    'Academic calendar',
    'Contact information',
    'Library hours',
    'Enrollment process',
    'Grade inquiry',
    'Uniform policy',
    'Scholarship information'
  ];

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _initializeServices() {
    // AI service is now handled by the backend API
    // No local initialization needed
  }


  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text:
          'Hello! I\'m BCP AI Assistant, your intelligent support companion for Bestlink College. I can help you with questions about college procedures, academic requirements, and concern resolution. How can I assist you today?\n\nPowered by Hugging Face AI technology.',
      isUser: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(welcomeMessage);
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Use Hugging Face API for AI responses (FREE alternative)
      final aiResponse = await _huggingFaceService.getChatResponse(text);
      
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isTyping = false;
      });
      
      // Fallback to demo response if Hugging Face API fails
      await _handleDemoResponse(text);
    }
  }

  Future<void> _handleDemoResponse(String userMessage) async {
    // Simulate typing delay
    await Future.delayed(Duration(seconds: 1));
    
    String demoResponse = _getDemoResponse(userMessage);
    
    // Simulate streaming response
    String currentResponse = '';
    for (int i = 0; i < demoResponse.length; i++) {
      await Future.delayed(Duration(milliseconds: 30));
      currentResponse += demoResponse[i];
      
      setState(() {
        if (_messages.isNotEmpty && !_messages.last.isUser) {
          _messages[_messages.length - 1] = _messages.last.copyWith(text: currentResponse);
        } else {
          _messages.add(ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: currentResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ));
        }
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  String _getDemoResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('concern') || message.contains('problem') || message.contains('issue')) {
      return "I understand you have a concern. You can submit it through the 'Submit Concern' feature on the home screen. Make sure to provide details about the department, facility, and describe the issue clearly.";
    } else if (message.contains('grade') || message.contains('academic')) {
      return "For academic matters like grades, please contact the Registrar's Office or your academic advisor. You can also check your student portal for grade updates.";
    } else if (message.contains('library') || message.contains('book')) {
      return "The library is open Monday to Friday, 8:00 AM to 8:00 PM. For book availability or library services, you can visit the library or contact them directly.";
    } else if (message.contains('enrollment') || message.contains('registration')) {
      return "Enrollment periods are announced through official announcements. Check the announcements section for enrollment schedules and requirements.";
    } else if (message.contains('emergency') || message.contains('help')) {
      return "For emergencies, use the Emergency Help section in the app or call campus security at (02) 8765-4321. For immediate danger, call 911.";
    } else if (message.contains('hello') || message.contains('hi')) {
      return "Hello! I'm BCP AI Assistant, your intelligent support companion for Bestlink College. I can help you with questions about college procedures, academic requirements, and concern resolution. How can I assist you today?";
    } else {
      return "Thank you for your message. I'm BCP AI Assistant, here to help with college-related questions. You can ask about concerns, academic matters, library services, enrollment, or any other campus-related topics.";
    }
  }

  void _handleSuggestionTap(String suggestion) {
    _messageController.text = suggestion;
    _sendMessage(suggestion);
  }

  void _showQuickSuggestionsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => QuickSuggestionsModal(
        onSuggestionTap: _handleSuggestionTap,
      ),
    );
  }


  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuart,
        );
      }
    });
  }

  void _clearConversation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Conversation'),
        content: const Text(
            'Are you sure you want to clear the entire conversation? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _messages.clear();
              });
              _addWelcomeMessage();
              Navigator.pop(context);
            },
            child: Text(
              'Clear',
              style: TextStyle(color: AppTheme.emergencyLight),
            ),
          ),
        ],
      ),
    );
  }


  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Modern light background
      resizeToAvoidBottomInset: false,
      appBar: _buildModernAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _buildModernChatContent(),
          ),
          if (_messages.length <= 1) _buildModernQuickSuggestions(),
          _buildModernInputSection(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1A1A1A),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.lightTheme.colorScheme.primary,
                  AppTheme.secondaryLight,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/bcpailogo.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BCP AI Assistant',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w600,
                    fontSize: 16,
                ),
              ),
              Text(
                'Online • Ready to help',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6B7280),
                    fontSize: 12,
                  ),
                ),
              ],
              ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: IconButton(
          onPressed: _clearConversation,
            icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Clear conversation',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF3F4F6),
              foregroundColor: const Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernChatContent() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Modern divider
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
        controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _messages.length + (_isTyping ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _messages.length && _isTyping) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: TypingIndicatorWidget(),
                        );
                      }
                      return ModernChatMessageWidget(
                        message: _messages[index],
                        onMessageLongPress: _showMessageOptions,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
                  AppTheme.secondaryLight.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy_rounded,
              size: 40,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'How can I help you today?',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF1A1A1A),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything about college procedures,\nacademic requirements, or concern resolution.',
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernQuickSuggestions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick suggestions',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickSuggestions.take(4).map((suggestion) {
              return GestureDetector(
                onTap: () => _sendMessage(suggestion),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1,
                    ),
        boxShadow: [
          BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    suggestion,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF374151),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildModernInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: ModernChatInputWidget(
                    controller: _messageController,
                    focusNode: _focusNode,
                    onSendMessage: _sendMessage,
                    onShowQuickSuggestions: _showQuickSuggestionsModal,
                    isEnabled: !_isTyping,
      ),
    );
  }

  void _showMessageOptions(ChatMessage message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _buildModernMessageAction(
              'Copy Message',
              Icons.copy_rounded,
              () {
                Clipboard.setData(ClipboardData(text: message.text));
                Navigator.pop(context);
                _showInfo('Message copied to clipboard');
              },
            ),
            if (!message.isUser)
              _buildModernMessageAction(
                'Regenerate Response',
                Icons.refresh_rounded,
                () {
                  Navigator.pop(context);
                  _showInfo('Response regeneration coming soon');
                },
              ),
            _buildModernMessageAction(
              'Share Message',
              Icons.share_rounded,
              () {
                Navigator.pop(context);
                _showInfo('Message sharing coming soon');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernMessageAction(String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
        icon,
        color: AppTheme.lightTheme.colorScheme.primary,
            size: 20,
          ),
      ),
      title: Text(
        title,
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

// Support classes for chat functionality
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}