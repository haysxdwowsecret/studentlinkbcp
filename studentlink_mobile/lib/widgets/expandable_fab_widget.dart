import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../theme/app_theme.dart';

/// Expandable FAB widget with multiple action options
class ExpandableFabWidget extends StatefulWidget {
  final List<FabAction> actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;
  final IconData? icon;
  final bool isOpen;
  final VoidCallback? onToggle;

  const ExpandableFabWidget({
    Key? key,
    required this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.icon,
    this.isOpen = false,
    this.onToggle,
  }) : super(key: key);

  @override
  State<ExpandableFabWidget> createState() => _ExpandableFabWidgetState();
}

class _ExpandableFabWidgetState extends State<ExpandableFabWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _isOpen = widget.isOpen;
    if (_isOpen) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
    widget.onToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.colorScheme.primary;
    final foregroundColor = widget.foregroundColor ?? Colors.white;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Action buttons
        ...widget.actions.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;
          
          return AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              final offset = (widget.actions.length - index) * 35.0; // Much tighter vertical spacing
              final translateY = _expandAnimation.value * offset;
              final opacity = _expandAnimation.value;
              
              return Transform.translate(
                offset: Offset(0, -translateY),
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 0.2.h), // Minimal margin for very tight vertical stack
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Action button (left side)
                        Material(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          elevation: 2,
                          child: InkWell(
                            onTap: _isOpen ? action.onPressed : null,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                              child: Text(
                                action.tooltip,
                                style: TextStyle(
                                  color: AppTheme.lightTheme.colorScheme.onSurface,
                                  fontSize: 3.8.w,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 0.8.w), // Minimal spacing between text and icon
                        // Icon button (right side)
                        Material(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                          elevation: 2,
                          child: InkWell(
                            onTap: _isOpen ? action.onPressed : null,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 10.w,
                              height: 10.w,
                              alignment: Alignment.center,
                              child: action.tooltip == 'Chat with BCP AI' 
                                ? Image.asset(
                                    'assets/images/bcpailogo.png',
                                    width: 6.w,
                                    height: 6.w,
                                  )
                                : Icon(
                                    action.icon,
                                    color: Colors.white,
                                    size: 6.w,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
        
        // Main FAB
        FloatingActionButton(
          heroTag: 'main_fab',
          onPressed: _toggle,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          tooltip: widget.tooltip ?? 'More options',
          mini: true, // Make FAB smaller
          child: AnimatedRotation(
            turns: _isOpen ? 0.125 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Icon(
              widget.icon ?? Icons.add,
              size: 6.w, // Icon size
            ),
          ),
        ),
      ],
    );
  }
}

/// Data class for FAB actions
class FabAction {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const FabAction({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
  });
}

/// Alternative implementation using SpeedDial (if flutter_speed_dial is preferred)
class SpeedDialFabWidget extends StatelessWidget {
  final List<FabAction> actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;
  final IconData? icon;

  const SpeedDialFabWidget({
    Key? key,
    required this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = this.backgroundColor ?? theme.colorScheme.primary;
    final foregroundColor = this.foregroundColor ?? Colors.white;

    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 6.w),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      activeBackgroundColor: backgroundColor.withValues(alpha: 0.8),
      activeForegroundColor: foregroundColor,
      visible: true,
      curve: Curves.bounceIn,
      children: actions.map((action) => SpeedDialChild(
        child: Icon(action.icon),
        backgroundColor: action.backgroundColor ?? backgroundColor,
        foregroundColor: action.foregroundColor ?? foregroundColor,
        label: action.tooltip,
        onTap: action.onPressed,
      )).toList(),
    );
  }
}

