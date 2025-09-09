import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import './widgets/chat_input_widget.dart';
import './widgets/chat_message_widget.dart';
import './widgets/quick_suggestions_widget.dart';
import './widgets/quick_suggestions_modal.dart';
import './widgets/typing_indicator_widget.dart';
import './widgets/voice_input_widget.dart';

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

  List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isRecording = false;
  bool _isVoicePermissionGranted = false;

  // Voice recording
  final AudioRecorder _audioRecorder = AudioRecorder();

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
    _checkVoicePermission();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _initializeServices() {
    // AI service is now handled by the backend API
    // No local initialization needed
  }

  Future<void> _checkVoicePermission() async {
    final status = await Permission.microphone.status;
    setState(() {
      _isVoicePermissionGranted = status.isGranted;
    });
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text:
          'Hello! I\'m your support assistant for Bestlink College. I can help you with questions about college procedures, academic requirements, and concern resolution. How can I assist you today?\n\nNote: This is running in demo mode. For full AI functionality, an OpenAI API key is required.',
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
      // Send message to backend AI API
      final response = await apiService.sendAiMessage(text);
      
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: response['message'] ?? 'Sorry, I could not process your request.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isTyping = false;
      });
      
      // Fallback to demo response if API fails
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
      return "Hello! I'm your support assistant for Bestlink College. I can help you with questions about college procedures, academic requirements, and concern resolution. How can I assist you today?";
    } else {
      return "Thank you for your message. I'm here to help with college-related questions. You can ask about concerns, academic matters, library services, enrollment, or any other campus-related topics.";
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

  Future<void> _startVoiceInput() async {
    if (!_isVoicePermissionGranted) {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        _showError('Microphone permission is required for voice input');
        return;
      }
      setState(() {
        _isVoicePermissionGranted = true;
      });
    }

    try {
      if (await _audioRecorder.hasPermission()) {
        final isSupported =
            await _audioRecorder.isEncoderSupported(AudioEncoder.aacLc);
        if (!isSupported) {
          _showError('Audio encoder not supported on this device');
          return;
        }

        await _audioRecorder.start(const RecordConfig(),
            path: await _getAudioPath());

        setState(() {
          _isRecording = true;
        });

        HapticFeedback.lightImpact();
      }
    } catch (e) {
      _showError('Failed to start recording: ${e.toString()}');
    }
  }

  Future<void> _stopVoiceInput() async {
    try {
      final path = await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
      });

      HapticFeedback.lightImpact();

      if (path != null && path.isNotEmpty) {
        // In a real implementation, you would transcribe the audio using OpenAI's Whisper API
        // For now, we'll show a placeholder message
        _showInfo('Voice input received. Processing...');

        // Simulate transcription delay
        await Future.delayed(const Duration(seconds: 2));

        // Placeholder response - in real implementation, this would be the transcribed text
        const transcribedText =
            "I need help with submitting a concern about library facilities.";
        _messageController.text = transcribedText;
        _sendMessage(transcribedText);
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
      _showError('Failed to process voice input: ${e.toString()}');
    }
  }

  Future<String> _getAudioPath() async {
    final directory = await getTemporaryDirectory();
    return '${directory.path}/voice_input_${DateTime.now().millisecondsSinceEpoch}.m4a';
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.emergencyLight,
        behavior: SnackBarBehavior.floating,
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
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _buildChatContent(),
          ),
          if (_messages.length <= 1) _buildQuickSuggestions(),
          _buildInputSection(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 2,
      title: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: AppTheme.secondaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 4.w,
            ),
          ),
          SizedBox(width: 3.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Message',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Online • Ready to help',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _clearConversation,
          icon: const Icon(Icons.refresh),
          tooltip: 'Clear conversation',
        ),
        IconButton(
          onPressed: () {
            _showInfo('Message settings coming soon');
          },
          icon: const Icon(Icons.settings),
          tooltip: 'Settings',
        ),
      ],
    );
  }

  Widget _buildChatContent() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _messages.length + (_isTyping ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _messages.length && _isTyping) {
            return TypingIndicatorWidget();
          }

          final message = _messages[index];
          return ChatMessageWidget(
            message: message,
            onMessageLongPress: _handleMessageLongPress,
          );
        },
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    return Container(
      height: 8.h,
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: QuickSuggestionsWidget(
        suggestions: _quickSuggestions,
        onSuggestionTap: _handleSuggestionTap,
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.all(2.w),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isRecording) VoiceInputWidget(isRecording: _isRecording),
            Row(
              children: [
                Expanded(
                  child: ChatInputWidget(
                    controller: _messageController,
                    focusNode: _focusNode,
                    onSendMessage: _sendMessage,
                    onShowQuickSuggestions: _showQuickSuggestionsModal,
                    isEnabled: !_isTyping && !_isRecording,
                  ),
                ),
                SizedBox(width: 2.w),
                if (_isVoicePermissionGranted)
                  GestureDetector(
                    onTapDown: (_) => _startVoiceInput(),
                    onTapUp: (_) => _stopVoiceInput(),
                    onTapCancel: () => _stopVoiceInput(),
                    child: Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: _isRecording
                            ? AppTheme.emergencyLight
                            : AppTheme.lightTheme.colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording
                                    ? AppTheme.emergencyLight
                                    : AppTheme.lightTheme.colorScheme.primary)
                                .withValues(alpha: 0.3),
                            blurRadius: _isRecording ? 8 : 4,
                            spreadRadius: _isRecording ? 2 : 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 5.w,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              'Responses are based on general college information. For official matters, please contact the relevant department.',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontSize: 9.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleMessageLongPress(ChatMessage message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 4.h),
            _buildMessageAction(
              'Copy Message',
              Icons.copy,
              () {
                Clipboard.setData(ClipboardData(text: message.text));
                Navigator.pop(context);
                _showInfo('Message copied to clipboard');
              },
            ),
            if (!message.isUser)
              _buildMessageAction(
                'Regenerate Response',
                Icons.refresh,
                () {
                  Navigator.pop(context);
                  _showInfo('Response regeneration coming soon');
                },
              ),
            _buildMessageAction(
              'Share Message',
              Icons.share,
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

  Widget _buildMessageAction(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.lightTheme.colorScheme.primary,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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