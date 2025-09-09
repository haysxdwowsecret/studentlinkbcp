import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AiAssistanceWidget extends StatefulWidget {
  final TextEditingController textController;
  final Function(String) onSuggestionApplied;

  const AiAssistanceWidget({
    Key? key,
    required this.textController,
    required this.onSuggestionApplied,
  }) : super(key: key);

  @override
  State<AiAssistanceWidget> createState() => _AiAssistanceWidgetState();
}

class _AiAssistanceWidgetState extends State<AiAssistanceWidget> {
  bool _isLoading = false;

  void _showAiBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAiBottomSheet(),
    );
  }

  Widget _buildAiBottomSheet() {
    final List<Map<String, dynamic>> suggestions = [
      {
        'title': 'Academic Concern',
        'template':
            'I am experiencing difficulties with my academic requirements. Specifically, I need assistance with [describe your specific concern]. This issue is affecting my academic progress and I would appreciate guidance on how to resolve it.',
        'icon': 'school',
      },
      {
        'title': 'Financial Issue',
        'template':
            'I am writing to address a financial concern regarding my student account. The issue involves [describe the financial matter]. I would like to request assistance in resolving this matter as it impacts my enrollment status.',
        'icon': 'account_balance_wallet',
      },
      {
        'title': 'Facility Problem',
        'template':
            'I would like to report a facility-related issue that requires attention. The problem is located at [specify location] and involves [describe the issue]. This affects the learning environment and needs prompt resolution.',
        'icon': 'build',
      },
      {
        'title': 'Technical Support',
        'template':
            'I am encountering technical difficulties with [specify system/service]. The issue prevents me from [describe what you cannot do]. I need technical assistance to resolve this problem and continue with my academic activities.',
        'icon': 'computer',
      },
    ];

    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'auto_awesome',
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'AI Writing Assistant',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose a template to get started:',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  ...suggestions
                      .map((suggestion) => _buildSuggestionCard(suggestion))
                      .toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(Map<String, dynamic> suggestion) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          widget.onSuggestionApplied(suggestion['template']);
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: CustomIconWidget(
                      iconName: suggestion['icon'],
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      suggestion['title'],
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'arrow_forward_ios',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                suggestion['template'],
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 1.h),
      child: ElevatedButton.icon(
        onPressed: _showAiBottomSheet,
        icon: _isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : CustomIconWidget(
                iconName: 'auto_awesome',
                color: Colors.white,
                size: 18,
              ),
        label: Text(
          _isLoading ? 'Generating...' : 'AI Writing Assistant',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }
}
