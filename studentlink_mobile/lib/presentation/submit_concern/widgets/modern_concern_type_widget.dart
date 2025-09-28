import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';
import '../services/form_validation_service.dart';

class ModernConcernTypeWidget extends StatefulWidget {
  final String? selectedType;
  final Function(String?) onChanged;
  final String? errorText;
  final bool enabled;

  const ModernConcernTypeWidget({
    Key? key,
    required this.selectedType,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<ModernConcernTypeWidget> createState() => _ModernConcernTypeWidgetState();
}

class _ModernConcernTypeWidgetState extends State<ModernConcernTypeWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  String? _hoveredType;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final concernTypes = [
      'Academic',
      'Administrative',
      'Technical',
      'Financial',
      'Facility',
      'Other',
    ];

    final fieldRules = FormValidationService.getFieldRules('concernType');
    final helpText = fieldRules['helpText'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with icon
        Row(
          children: [
            Icon(
              Icons.category_rounded,
              color: widget.errorText != null 
                  ? AppTheme.emergencyLight 
                  : AppTheme.primaryLight,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Concern Type *',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: widget.errorText != null 
                    ? AppTheme.emergencyLight 
                    : const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Help text
        if (helpText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
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
          ),
        
        // Concern type chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: concernTypes.map((type) {
            return _buildConcernTypeChip(type);
          }).toList(),
        ),
        
        // Error message
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Row(
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
        ],
      ],
    );
  }

  Widget _buildConcernTypeChip(String type) {
    final isSelected = widget.selectedType == type.toLowerCase();
    final isHovered = _hoveredType == type;
    final isDisabled = !widget.enabled;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isHovered ? _scaleAnimation.value : 1.0,
          child: GestureDetector(
            onTap: isDisabled ? null : () {
              HapticFeedback.lightImpact();
              _animationController.forward().then((_) {
                _animationController.reverse();
              });
              widget.onChanged(type.toLowerCase());
            },
            onTapDown: isDisabled ? null : (_) {
              setState(() {
                _hoveredType = type;
              });
            },
            onTapUp: isDisabled ? null : (_) {
              setState(() {
                _hoveredType = null;
              });
            },
            onTapCancel: isDisabled ? null : () {
              setState(() {
                _hoveredType = null;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDisabled
                    ? const Color(0xFFF3F4F6)
                    : isSelected 
                        ? AppTheme.primaryLight 
                        : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDisabled
                      ? const Color(0xFFE5E7EB)
                      : isSelected 
                          ? AppTheme.primaryLight 
                          : const Color(0xFFE5E7EB),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected && !isDisabled ? [
                  BoxShadow(
                    color: AppTheme.primaryLight.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : isHovered && !isDisabled ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ] : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Selection indicator
                  if (isSelected && !isDisabled)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: AppTheme.primaryLight,
                        size: 14,
                      ),
                    )
                  else
                    Icon(
                      _getTypeIcon(type),
                      color: isDisabled
                          ? const Color(0xFF9CA3AF)
                          : isSelected 
                              ? Colors.white 
                              : AppTheme.primaryLight,
                      size: 16,
                    ),
                  
                  const SizedBox(width: 8),
                  
                  Text(
                    type,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: isDisabled
                          ? const Color(0xFF9CA3AF)
                          : isSelected 
                              ? Colors.white 
                              : const Color(0xFF1A1A1A),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'academic':
        return Icons.school_rounded;
      case 'administrative':
        return Icons.admin_panel_settings_rounded;
      case 'technical':
        return Icons.build_rounded;
      case 'financial':
        return Icons.account_balance_wallet_rounded;
      case 'facility':
        return Icons.location_on_rounded;
      case 'other':
        return Icons.help_outline_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
