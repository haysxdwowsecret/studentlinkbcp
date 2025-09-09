import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/api_service.dart';
import './widgets/concern_description_widget.dart';
import './widgets/concern_metadata_widget.dart';
import './widgets/message_thread_widget.dart';
import './widgets/reply_input_widget.dart';
import './widgets/status_timeline_widget.dart';

class ConcernDetails extends StatefulWidget {
  const ConcernDetails({Key? key}) : super(key: key);

  @override
  State<ConcernDetails> createState() => _ConcernDetailsState();
}

class _ConcernDetailsState extends State<ConcernDetails> {
  final ScrollController _scrollController = ScrollController();
  bool _showQuickReply = false;
  bool _isLoading = true;
  String? _errorMessage;

  // Real data loaded from API
  Map<String, dynamic>? concernData;
  List<Map<String, dynamic>> messageThread = [];
  List<Map<String, dynamic>> statusHistory = [];

  @override
  void initState() {
    super.initState();
    _loadConcernDetails();
  }

  Future<void> _loadConcernDetails() async {
    try {
      // Get concern ID from route arguments
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic> && args['id'] != null) {
        final concernId = args['id'] as int;
        
        // Load concern details from API
        final concern = await apiService.getConcern(concernId);
        
        setState(() {
          concernData = concern;
          messageThread = concern['messages'] ?? [];
          statusHistory = concern['history'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Invalid concern ID';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load concern details: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          AppBar(
            title: Text('Concern Details'),
            backgroundColor: AppTheme.primaryLight,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Expanded(
            child: _buildBody(),
          ),
          if (concernData != null)
            ReplyInputWidget(
              onSendMessage: _sendMessage,
              onAttachFile: _attachFile,
              onAIAssist: _showAIAssist,
            ),
        ],
      ),
      floatingActionButton: _showQuickReply ? _buildQuickReplyFAB() : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            SizedBox(height: 16),
            Text(
              'Error Loading Concern',
              style: AppTheme.lightTheme.textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: AppTheme.lightTheme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadConcernDetails,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (concernData == null) {
      return Center(
        child: Text('No concern data available'),
      );
    }

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          ConcernMetadataWidget(concernData: concernData!),
          ConcernDescriptionWidget(concernData: concernData!),
          StatusTimelineWidget(statusHistory: statusHistory),
          MessageThreadWidget(messages: messageThread),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildQuickReplyFAB() {
    return FloatingActionButton.extended(
      onPressed: _scrollToBottom,
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      foregroundColor: Colors.white,
      icon: CustomIconWidget(
        iconName: 'keyboard_arrow_down',
        color: Colors.white,
        size: 5.w,
      ),
      label: Text(
        'New Reply',
        style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _showQuickReply = false);
  }



  Future<void> _sendMessage(String message) async {
    if (concernData == null) return;
    
    try {
      // Send message via API
      await apiService.addConcernMessage(
        concernData!['id'],
        message,
      );
      
      // Reload concern details to get updated messages
      await _loadConcernDetails();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Message sent successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _attachFile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 1.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Attach File',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachOption('camera', 'Camera', () {
                  Navigator.pop(context);
                  _openCamera();
                }),
                _buildAttachOption('photo_library', 'Gallery', () {
                  Navigator.pop(context);
                  _openGallery();
                }),
                _buildAttachOption('description', 'Document', () {
                  Navigator.pop(context);
                  _openDocuments();
                }),
              ],
            ),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachOption(String icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 8.w,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _showAIAssist() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: 60.h,
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 1.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'psychology',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 7.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  'AI Reply Assistant',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Expanded(
              child: ListView(
                children: [
                  _buildAISuggestion(
                    'Thank you for the update',
                    'Thank you for looking into this issue. I appreciate your quick response and will try the suggested solution.',
                  ),
                  _buildAISuggestion(
                    'Request for status update',
                    'Could you please provide an update on the current status of my concern? I would like to know if there are any additional steps I need to take.',
                  ),
                  _buildAISuggestion(
                    'Provide additional information',
                    'I have some additional information that might help resolve this issue. Please let me know if you need me to provide any specific details.',
                  ),
                  _buildAISuggestion(
                    'Express urgency',
                    'This issue is quite urgent for me as it affects my academic activities. I would greatly appreciate if this could be prioritized.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAISuggestion(String title, String content) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color:
            AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            content,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              height: 1.4,
            ),
          ),
          SizedBox(height: 1.h),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _sendMessage(content);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Use This',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openCamera() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening camera...')),
    );
  }

  void _openGallery() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening gallery...')),
    );
  }

  void _openDocuments() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening document picker...')),
    );
  }

}
