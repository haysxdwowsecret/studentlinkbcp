import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';
import '../../../utils/responsive_design.dart';

class TypingPatternWidget extends StatefulWidget {
  final String text;
  final Function(String) onPatternCollected;
  final VoidCallback? onComplete;
  final bool isEnabled;

  const TypingPatternWidget({
    Key? key,
    required this.text,
    required this.onPatternCollected,
    this.onComplete,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  State<TypingPatternWidget> createState() => _TypingPatternWidgetState();
}

class _TypingPatternWidgetState extends State<TypingPatternWidget>
    with TickerProviderStateMixin {
  late TextEditingController _textController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  List<int> _keyPressTimes = [];
  List<int> _keyReleaseTimes = [];
  String _currentText = '';
  bool _isCollecting = false;
  int _requiredPatterns = 2;
  int _currentPattern = 0;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _currentText = widget.text;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _textController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startPatternCollection() {
    if (!widget.isEnabled) return;
    
    setState(() {
      _isCollecting = true;
      _keyPressTimes.clear();
      _keyReleaseTimes.clear();
      _textController.clear();
    });

    // Add haptic feedback
    HapticFeedback.mediumImpact();
  }

  void _onKeyPress(RawKeyEvent event) {
    if (!_isCollecting) return;
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _keyPressTimes.add(timestamp);
  }

  // Note: Key release tracking can be implemented for more advanced pattern analysis

  void _onTextChanged(String text) {
    if (!_isCollecting) return;
    
    // Check if user has typed the required text
    if (text == widget.text) {
      _completePatternCollection();
    }
  }

  void _completePatternCollection() {
    if (_keyPressTimes.length < 3 || _keyReleaseTimes.length < 3) {
      _showInsufficientDataMessage();
      return;
    }

    // Generate typing pattern
    final typingPattern = _generateTypingPattern();
    
    setState(() {
      _isCollecting = false;
      _currentPattern++;
    });

    // Add haptic feedback
    HapticFeedback.heavyImpact();

    // Call the callback with the pattern
    widget.onPatternCollected(typingPattern);

    if (_currentPattern >= _requiredPatterns) {
      // All patterns collected
      widget.onComplete?.call();
    } else {
      // Reset for next pattern
      _resetForNextPattern();
    }
  }

  String _generateTypingPattern() {
    // Create a simplified typing pattern based on key press/release times
    final pattern = <String>[];
    
    for (int i = 0; i < _keyPressTimes.length && i < _keyReleaseTimes.length; i++) {
      final pressTime = _keyPressTimes[i];
      final releaseTime = _keyReleaseTimes[i];
      final duration = releaseTime - pressTime;
      
      // Convert to a simple pattern representation
      if (duration < 100) {
        pattern.add('f'); // fast
      } else if (duration < 300) {
        pattern.add('m'); // medium
      } else {
        pattern.add('s'); // slow
      }
    }
    
    return pattern.join('');
  }

  void _resetForNextPattern() {
    setState(() {
      _keyPressTimes.clear();
      _keyReleaseTimes.clear();
      _textController.clear();
    });
  }

  void _showInsufficientDataMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please type more carefully to capture your typing pattern'),
        backgroundColor: AppTheme.warningLight,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(
              ResponsiveDesign.getBorderRadius(16),
            ),
            border: Border.all(
              color: AppTheme.borderSubtleLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryLight.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _buildHeader(),
              
              SizedBox(height: 3.h),
              
              // Text to type
              _buildTextToType(),
              
              SizedBox(height: 3.h),
              
              // Input field
              _buildInputField(),
              
              SizedBox(height: 2.h),
              
              // Progress indicator
              _buildProgressIndicator(),
              
              SizedBox(height: 2.h),
              
              // Action button
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.keyboard_rounded,
          color: AppTheme.primaryLight,
          size: ResponsiveDesign.getIconSize(24),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Typing Pattern Authentication',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Type the text below to create your unique typing pattern',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextToType() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(
          ResponsiveDesign.getBorderRadius(12),
        ),
        border: Border.all(
          color: AppTheme.primaryLight.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        _currentText,
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          color: AppTheme.primaryLight,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildInputField() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: _onKeyPress,
      child: TextField(
        controller: _textController,
        onChanged: _onTextChanged,
        enabled: _isCollecting,
        maxLines: 1,
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          letterSpacing: 1.2,
        ),
        decoration: InputDecoration(
          hintText: _isCollecting ? 'Start typing...' : 'Tap "Start Typing" to begin',
          hintStyle: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondaryLight.withValues(alpha: 0.7),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveDesign.getBorderRadius(12),
            ),
            borderSide: BorderSide(
              color: _isCollecting 
                  ? AppTheme.primaryLight 
                  : AppTheme.borderSubtleLight,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveDesign.getBorderRadius(12),
            ),
            borderSide: BorderSide(
              color: _isCollecting 
                  ? AppTheme.primaryLight 
                  : AppTheme.borderSubtleLight,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveDesign.getBorderRadius(12),
            ),
            borderSide: BorderSide(
              color: AppTheme.primaryLight,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: _isCollecting 
              ? AppTheme.primaryLight.withValues(alpha: 0.05)
              : AppTheme.surfaceLight,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pattern Collection Progress',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$_currentPattern/$_requiredPatterns',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        LinearProgressIndicator(
          value: _currentPattern / _requiredPatterns,
          backgroundColor: AppTheme.borderSubtleLight,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isCollecting ? null : _startPatternCollection,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isCollecting 
              ? AppTheme.textSecondaryLight 
              : AppTheme.primaryLight,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveDesign.getButtonHeight() * 0.6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveDesign.getBorderRadius(12),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isCollecting ? Icons.timer_rounded : Icons.play_arrow_rounded,
              size: ResponsiveDesign.getIconSize(20),
            ),
            SizedBox(width: 2.w),
            Text(
              _isCollecting 
                  ? 'Typing in progress...' 
                  : _currentPattern == 0 
                      ? 'Start Typing Pattern' 
                      : 'Continue Pattern Collection',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
