import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class ModernStep3ContactInfoWidget extends StatefulWidget {
  final String? schoolEmail;
  final Function(String? personalEmail, String? contactNumber) onDataChanged;

  const ModernStep3ContactInfoWidget({
    Key? key,
    required this.schoolEmail,
    required this.onDataChanged,
  }) : super(key: key);

  @override
  State<ModernStep3ContactInfoWidget> createState() => _ModernStep3ContactInfoWidgetState();
}

class _ModernStep3ContactInfoWidgetState extends State<ModernStep3ContactInfoWidget> {
  final _personalEmailController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _personalEmailFocusNode = FocusNode();
  final _contactNumberFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _personalEmailController.addListener(_onDataChanged);
    _contactNumberController.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _personalEmailController.dispose();
    _contactNumberController.dispose();
    _personalEmailFocusNode.dispose();
    _contactNumberFocusNode.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    widget.onDataChanged(
      _personalEmailController.text.trim().isEmpty ? null : _personalEmailController.text.trim(),
      _contactNumberController.text.trim().isEmpty ? null : _contactNumberController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Modern header with gradient
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
                AppTheme.secondaryLight.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
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
                    ),
                    child: const Icon(
                      Icons.contact_phone_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact Information',
                          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                            color: const Color(0xFF1A1A1A),
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Provide your contact details for communication and account recovery.',
                          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF6B7280),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // School Email (read-only) - if available
        if (widget.schoolEmail != null) ...[
          _buildModernReadOnlyField(
            label: 'School Email',
            value: widget.schoolEmail!,
            icon: Icons.school_rounded,
            color: const Color(0xFF10B981),
          ),
          
          const SizedBox(height: 20),
        ],
        
        // Personal Email
        _buildModernTextField(
          controller: _personalEmailController,
          focusNode: _personalEmailFocusNode,
          label: 'Personal Email',
          hint: 'Enter your personal email address',
          icon: Icons.email_rounded,
          keyboardType: TextInputType.emailAddress,
          isRequired: true,
        ),
        
        const SizedBox(height: 20),
        
        // Contact Number
        _buildModernTextField(
          controller: _contactNumberController,
          focusNode: _contactNumberFocusNode,
          label: 'Contact Number',
          hint: 'Enter your phone number',
          icon: Icons.phone_rounded,
          keyboardType: TextInputType.phone,
          isRequired: true,
        ),
        
        const SizedBox(height: 24),
        
        // Modern Information Cards
        _buildModernInfoCards(),
      ],
    );
  }


  Widget _buildModernReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 12,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: const Color(0xFF374151),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Auto-generated',
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    required bool isRequired,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 12,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: const Color(0xFF374151),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: const Color(0xFFDC2626),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFDC2626),
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            prefixIcon: Icon(
              icon,
              color: focusNode.hasFocus 
                  ? AppTheme.lightTheme.colorScheme.primary
                  : const Color(0xFF9CA3AF),
              size: 20,
            ),
          ),
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF1A1A1A),
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  if (keyboardType == TextInputType.emailAddress) {
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildModernInfoCards() {
    return Column(
      children: [
        // Email Information Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email Information',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF92400E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• School Email: Used for official communications\n'
                      '• Personal Email: Used for account recovery\n'
                      '• Both emails will be verified during registration',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF92400E),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Contact Number Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone_android_rounded,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Number',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF1E40AF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Include country code (e.g., +63 for Philippines)\n'
                      '• Used for SMS notifications and account recovery\n'
                      '• Must be a valid, active phone number',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF1E40AF),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}