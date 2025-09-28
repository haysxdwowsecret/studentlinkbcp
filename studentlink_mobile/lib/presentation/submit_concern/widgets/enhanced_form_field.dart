import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';
import '../services/form_validation_service.dart';

/// Enhanced form field widget with validation, accessibility, and better UX
class EnhancedFormField extends StatefulWidget {
  final String fieldName;
  final String label;
  final String? hint;
  final String? helpText;
  final IconData? icon;
  final TextEditingController? controller;
  final String? initialValue;
  final String? errorText;
  final bool isRequired;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final bool enabled;
  final bool readOnly;
  final Widget? suffix;
  final Widget? prefix;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final bool showCharacterCount;
  final bool autoFocus;
  final TextCapitalization textCapitalization;

  const EnhancedFormField({
    Key? key,
    required this.fieldName,
    required this.label,
    this.hint,
    this.helpText,
    this.icon,
    this.controller,
    this.initialValue,
    this.errorText,
    this.isRequired = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.suffix,
    this.prefix,
    this.focusNode,
    this.validator,
    this.showCharacterCount = false,
    this.autoFocus = false,
    this.textCapitalization = TextCapitalization.sentences,
  }) : super(key: key);

  @override
  State<EnhancedFormField> createState() => _EnhancedFormFieldState();
}

class _EnhancedFormFieldState extends State<EnhancedFormField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    _hasError = widget.errorText != null;
  }

  @override
  void didUpdateWidget(EnhancedFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != oldWidget.errorText) {
      _hasError = widget.errorText != null;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fieldRules = FormValidationService.getFieldRules(widget.fieldName);
    final effectiveHelpText = widget.helpText ?? fieldRules['helpText'] as String?;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        _buildLabel(),
        
        const SizedBox(height: 8),
        
        // Input field
        _buildInputField(),
        
        // Help text and error message
        _buildHelpAndError(effectiveHelpText),
        
        // Character count
        if (widget.showCharacterCount && widget.maxLength != null)
          _buildCharacterCount(),
      ],
    );
  }

  Widget _buildLabel() {
    return Row(
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            color: _hasError 
                ? AppTheme.emergencyLight 
                : AppTheme.primaryLight,
            size: 20,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          widget.label + (widget.isRequired ? ' *' : ''),
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: _hasError 
                ? AppTheme.emergencyLight 
                : const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppTheme.primaryLight.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        keyboardType: widget.keyboardType ?? (widget.maxLines > 1 ? TextInputType.multiline : TextInputType.text),
        inputFormatters: widget.inputFormatters,
        onChanged: (value) {
          // Don't sanitize during typing to avoid disrupting user input
          // Sanitization will happen during validation/submission
          print('Text input changed: "${value}" (length: ${value.length})');
          widget.onChanged?.call(value);
        },
        onFieldSubmitted: widget.onSubmitted,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        autofocus: widget.autoFocus,
        textCapitalization: widget.textCapitalization,
        // Ensure proper text input behavior
        textInputAction: widget.maxLines > 1 ? TextInputAction.newline : TextInputAction.done,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF9CA3AF),
          ),
          filled: true,
          fillColor: widget.enabled 
              ? const Color(0xFFF9FAFB)
              : const Color(0xFFF3F4F6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _hasError 
                  ? AppTheme.emergencyLight 
                  : const Color(0xFFE5E7EB),
              width: _hasError ? 2 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _hasError 
                  ? AppTheme.emergencyLight 
                  : AppTheme.primaryLight,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.emergencyLight,
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.emergencyLight,
              width: 2,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: widget.prefix,
          suffixIcon: widget.suffix,
          counterText: widget.showCharacterCount ? null : '',
          errorText: widget.errorText,
        ),
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          color: widget.enabled 
              ? const Color(0xFF1A1A1A)
              : const Color(0xFF9CA3AF),
        ),
        validator: widget.validator,
      ),
    );
  }

  Widget _buildHelpAndError(String? helpText) {
    if (widget.errorText != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppTheme.emergencyLight,
              size: 16,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                widget.errorText!,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.emergencyLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (helpText != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: const Color(0xFF6B7280),
              size: 16,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                helpText,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCharacterCount() {
    final currentLength = _controller.text.length;
    final maxLength = widget.maxLength!;
    final isNearLimit = currentLength > (maxLength * 0.8);
    final isAtLimit = currentLength >= maxLength;
    
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          '$currentLength/$maxLength',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: isAtLimit 
                ? AppTheme.emergencyLight
                : isNearLimit 
                    ? AppTheme.warningLight
                    : const Color(0xFF9CA3AF),
            fontWeight: isAtLimit ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Specialized form field for concern description with enhanced features
class ConcernDescriptionField extends StatefulWidget {
  final String fieldName;
  final TextEditingController? controller;
  final String? initialValue;
  final String? errorText;
  final Function(String)? onChanged;
  final bool enabled;

  const ConcernDescriptionField({
    Key? key,
    required this.fieldName,
    this.controller,
    this.initialValue,
    this.errorText,
    this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<ConcernDescriptionField> createState() => _ConcernDescriptionFieldState();
}

class _ConcernDescriptionFieldState extends State<ConcernDescriptionField> {
  late TextEditingController _controller;
  int _wordCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _updateWordCount();
    _controller.addListener(_updateWordCount);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateWordCount);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _updateWordCount() {
    final text = _controller.text.trim();
    final words = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    print('Word count update: text="$text", words=$words, previous=$_wordCount');
    if (words != _wordCount) {
      setState(() {
        _wordCount = words;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return EnhancedFormField(
      fieldName: widget.fieldName,
      label: 'Describe Your Concern',
      hint: 'Please provide detailed information about your concern...',
      helpText: 'Include specific details, dates, and any relevant information',
      icon: Icons.description_rounded,
      controller: _controller,
      errorText: widget.errorText,
      isRequired: true,
      maxLines: 6,
      maxLength: 2000,
      showCharacterCount: true,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      suffix: _buildWordCountIndicator(),
    );
  }

  Widget _buildWordCountIndicator() {
    final isMinimumMet = _wordCount >= 5;
    final isOptimal = _wordCount >= 20;
    final wordsNeeded = 5 - _wordCount;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: isMinimumMet 
            ? (isOptimal ? AppTheme.successLight.withValues(alpha: 0.1) : AppTheme.warningLight.withValues(alpha: 0.1))
            : AppTheme.emergencyLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isMinimumMet 
            ? '$_wordCount words'
            : '$_wordCount words (need $wordsNeeded more)',
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: isMinimumMet 
              ? (isOptimal ? AppTheme.successLight : AppTheme.warningLight)
              : AppTheme.emergencyLight,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
