import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LoginFormWidget extends StatefulWidget {
  final Function(String email, String password) onLogin;
  final bool isLoading;

  const LoginFormWidget({
    Key? key,
    required this.onLogin,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    final email = _emailController.text.trim();
    final isValid = email.isNotEmpty &&
        _passwordController.text.trim().isNotEmpty &&
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onLogin(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email Field
          ModernInputWidget(
            label: 'Email Address',
            hint: 'Enter your email address',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !widget.isLoading,
            prefixIcon: Icon(
              Icons.email_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            validator: _validateEmail,
            onSubmitted: (_) => FocusScope.of(context).nextFocus(),
          ),
          SizedBox(height: 3.h),

          // Password Field
          ModernInputWidget(
            label: 'Password',
            hint: 'Enter your password',
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            textInputAction: TextInputAction.done,
            enabled: !widget.isLoading,
            prefixIcon: Icon(
              Icons.lock_outline,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            suffixIcon: IconButton(
              onPressed: widget.isLoading
                  ? null
                  : () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            validator: _validatePassword,
            onSubmitted: (_) => _isFormValid ? _handleLogin() : null,
          ),
          SizedBox(height: 2.h),

          // Forgot Password Link
          Align(
            alignment: Alignment.centerRight,
            child: ModernButtonWidget(
              text: 'Forgot Password?',
              type: ModernButtonType.text,
              onPressed: widget.isLoading
                  ? null
                  : () {
                      Navigator.pushNamed(context, '/forgot-password');
                    },
            ),
          ),
          SizedBox(height: 4.h),

          // Login Button
          ModernButtonWidget(
            text: 'Login',
            type: ModernButtonType.primary,
            size: ModernButtonSize.large,
            isFullWidth: true,
            isLoading: widget.isLoading,
            textColor: Colors.white,
            onPressed: (_isFormValid && !widget.isLoading) ? _handleLogin : null,
          ),
        ],
      ),
    );
  }
}
