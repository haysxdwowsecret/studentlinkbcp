import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import 'terms_of_service_widget.dart';
import 'privacy_policy_widget.dart';

class ModernStep5AccountCreationWidget extends StatefulWidget {
  final Function(String? password, String? passwordConfirmation) onDataChanged;
  final Function(bool agreeToTerms, bool agreeToPrivacy)? onTermsChanged;

  const ModernStep5AccountCreationWidget({
    Key? key,
    required this.onDataChanged,
    this.onTermsChanged,
  }) : super(key: key);

  @override
  State<ModernStep5AccountCreationWidget> createState() => _ModernStep5AccountCreationWidgetState();
}

class _ModernStep5AccountCreationWidgetState extends State<ModernStep5AccountCreationWidget> {
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  bool _agreeToTerms = false;
  bool _agreeToPrivacy = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onDataChanged);
    _passwordConfirmationController.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    widget.onDataChanged(
      _passwordController.text.trim().isEmpty ? null : _passwordController.text.trim(),
      _passwordConfirmationController.text.trim().isEmpty ? null : _passwordConfirmationController.text.trim(),
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
                      Icons.account_circle_rounded,
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
                          'Create Your Account',
                          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                            color: const Color(0xFF1A1A1A),
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Review your information and agree to the terms to complete your registration.',
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
        
        // Password fields
        _buildModernPasswordField(
          controller: _passwordController,
          label: 'Password',
          hint: 'Enter your password',
          icon: Icons.lock_rounded,
          isVisible: _isPasswordVisible,
          onToggleVisibility: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        
        const SizedBox(height: 20),
        
        _buildModernPasswordField(
          controller: _passwordConfirmationController,
          label: 'Confirm Password',
          hint: 'Re-enter your password',
          icon: Icons.lock_reset_rounded,
          isVisible: _isConfirmPasswordVisible,
          onToggleVisibility: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
        ),
        
        const SizedBox(height: 24),
          
        // Account summary
        _buildModernAccountSummary(),
        
        const SizedBox(height: 20),
        
        // Terms and conditions
        _buildModernTermsSection(),
        
        const SizedBox(height: 20),
          
        // Information note
        _buildModernInfoCard(),
        
        const SizedBox(height: 16),
        
        // Validation message
        if (!_agreeToTerms || !_agreeToPrivacy)
          _buildModernValidationMessage(),
      ],
    );
  }


  Widget _buildModernAccountSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_circle_rounded,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Account Summary',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF1E40AF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Text(
            'Your account will be created with the following information:',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF1E40AF),
            ),
          ),
          
          const SizedBox(height: 20),
                
          _buildModernSummaryItem('Student ID', 'Auto-generated unique ID'),
          _buildModernSummaryItem('School Email', 'Auto-generated school email'),
          _buildModernSummaryItem('Personal Information', 'Name, birthday, civil status'),
          _buildModernSummaryItem('Contact Information', 'Personal email and phone number'),
          _buildModernSummaryItem('Account Security', 'Secure password protection'),
        ],
      ),
    );
  }

  Widget _buildModernSummaryItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF10B981),
              size: 12,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF1E40AF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTermsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Terms & Conditions',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF1A1A1A),
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 20),
                
          // Terms agreement
          _buildModernCheckboxTile(
            value: _agreeToTerms,
            onChanged: (value) {
              setState(() {
                _agreeToTerms = value ?? false;
              });
              widget.onTermsChanged?.call(_agreeToTerms, _agreeToPrivacy);
            },
            title: 'I agree to the ',
            linkText: 'Terms of Service',
            onLinkTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TermsOfServiceWidget(),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Privacy agreement
          _buildModernCheckboxTile(
            value: _agreeToPrivacy,
            onChanged: (value) {
              setState(() {
                _agreeToPrivacy = value ?? false;
              });
              widget.onTermsChanged?.call(_agreeToTerms, _agreeToPrivacy);
            },
            title: 'I agree to the ',
            linkText: 'Privacy Policy',
            onLinkTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyWidget(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModernCheckboxTile({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String title,
    required String linkText,
    required VoidCallback onLinkTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.lightTheme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6B7280),
              ),
              children: [
                TextSpan(text: title),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: onLinkTap,
                    child: Text(
                      linkText,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.2),
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
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: Color(0xFF10B981),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready to Create Account',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF065F46),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Once you create your account, you will be automatically logged in and can start using the StudentLink app immediately.',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF065F46),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernValidationMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFF59E0B),
              size: 12,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Please agree to the Terms of Service and Privacy Policy to continue.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.lightTheme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
            Text(
              ' *',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: AppTheme.emergencyLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
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
              borderSide: BorderSide(color: AppTheme.emergencyLight),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.emergencyLight, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                color: const Color(0xFF6B7280),
              ),
              onPressed: onToggleVisibility,
            ),
          ),
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF1A1A1A),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Password is required';
            }
            if (value.length < 8) {
              return 'Password must be at least 8 characters';
            }
            if (label == 'Confirm Password' && value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }
}