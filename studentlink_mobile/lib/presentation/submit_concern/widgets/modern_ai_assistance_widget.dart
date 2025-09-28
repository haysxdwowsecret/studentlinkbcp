import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';

class ModernAiAssistanceWidget extends StatefulWidget {
  final TextEditingController textController;
  final Function(String) onSuggestionApplied;

  const ModernAiAssistanceWidget({
    Key? key,
    required this.textController,
    required this.onSuggestionApplied,
  }) : super(key: key);

  @override
  State<ModernAiAssistanceWidget> createState() => _ModernAiAssistanceWidgetState();
}

class _ModernAiAssistanceWidgetState extends State<ModernAiAssistanceWidget> {
  bool _isExpanded = false;
  bool _isGenerating = false;
  String? _suggestion;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryLight.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: AppTheme.secondaryLight,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Writing Assistant',
                            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                          Text(
                            'Get help improving your concern description',
                            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      color: const Color(0xFF9CA3AF),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Expanded content
          if (_isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Generate suggestion button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isGenerating ? null : _generateSuggestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryLight,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: _isGenerating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(
                              Icons.auto_awesome_rounded,
                              size: 18,
                            ),
                      label: Text(
                        _isGenerating ? 'Generating...' : 'Improve My Text',
                        style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  // Suggestion display
                  if (_suggestion != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryLight.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.secondaryLight.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline_rounded,
                                color: AppTheme.secondaryLight,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'AI Suggestion',
                                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.secondaryLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _suggestion!,
                            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF374151),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    widget.onSuggestionApplied(_suggestion!);
                                    setState(() {
                                      _suggestion = null;
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: AppTheme.secondaryLight),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.check_rounded,
                                    color: AppTheme.secondaryLight,
                                    size: 16,
                                  ),
                                  label: Text(
                                    'Use This',
                                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                      color: AppTheme.secondaryLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  setState(() {
                                    _suggestion = null;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Color(0xFF9CA3AF),
                                  size: 16,
                                ),
                                label: Text(
                                  'Dismiss',
                                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF9CA3AF),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _generateSuggestion() async {
    setState(() {
      _isGenerating = true;
    });

    // Simulate AI processing
    await Future.delayed(const Duration(seconds: 2));

    final currentText = widget.textController.text;
    String suggestion;

    if (currentText.isEmpty) {
      suggestion = "I am writing to report a concern regarding [specific issue]. This matter has been affecting [who/what is affected] and I believe it requires attention from the appropriate department. I would appreciate your assistance in resolving this matter promptly.";
    } else {
      suggestion = "I am writing to report a concern regarding ${currentText.toLowerCase()}. This matter requires attention and I would appreciate your assistance in resolving it promptly. Please let me know if you need any additional information.";
    }

    setState(() {
      _suggestion = suggestion;
      _isGenerating = false;
    });
  }
}
