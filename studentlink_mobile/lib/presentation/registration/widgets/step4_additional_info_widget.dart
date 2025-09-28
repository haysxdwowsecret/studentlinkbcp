import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';

class Step4AdditionalInfoWidget extends StatefulWidget {
  final Function(DateTime? birthday, String? civilStatus, String? password, String? passwordConfirmation) onDataChanged;

  const Step4AdditionalInfoWidget({
    Key? key,
    required this.onDataChanged,
  }) : super(key: key);

  @override
  State<Step4AdditionalInfoWidget> createState() => _Step4AdditionalInfoWidgetState();
}

class _Step4AdditionalInfoWidgetState extends State<Step4AdditionalInfoWidget> {
  DateTime? _selectedBirthday;
  String? _selectedCivilStatus;
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscurePasswordConfirmation = true;

  final List<String> _civilStatusOptions = [
    'single',
    'married',
    'widowed',
    'separated',
  ];

  final Map<String, String> _civilStatusLabels = {
    'single': 'Single',
    'married': 'Married',
    'widowed': 'Widowed',
    'separated': 'Separated',
  };

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
      _selectedBirthday,
      _selectedCivilStatus,
      _passwordController.text.trim().isEmpty ? null : _passwordController.text.trim(),
      _passwordConfirmationController.text.trim().isEmpty ? null : _passwordConfirmationController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Additional Information & Password',
          style: TextStyle(
            fontSize: 5.5.w,
            fontWeight: FontWeight.bold,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        
        SizedBox(height: 1.5.h),
        
        Text(
          'Complete your profile with additional information and create a secure password for your account.',
          style: TextStyle(
            fontSize: 3.8.w,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
        
        SizedBox(height: 3.h),
          
        // Birthday
        _buildBirthdayField(),
        
        SizedBox(height: 1.5.h),
        
        // Civil Status
        _buildCivilStatusField(),
        
        SizedBox(height: 1.5.h),
        
        // Password
        _buildPasswordField(),
        
        SizedBox(height: 1.5.h),
        
        // Password Confirmation
        _buildPasswordConfirmationField(),
        
        SizedBox(height: 1.5.h),
        
        // Password requirements
        _buildPasswordRequirements(),
        
        SizedBox(height: 1.5.h),
          
        // Information note
        Container(
          padding: EdgeInsets.all(2.5.w),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.security,
                color: Colors.blue.shade600,
                size: 3.5.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Security',
                      style: TextStyle(
                        fontSize: 3.w,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '• Your password is encrypted and stored securely\n'
                      '• Use a strong password to protect your account\n'
                      '• You can change your password later in settings\n'
                      '• Keep your login credentials confidential',
                      style: TextStyle(
                        fontSize: 3.2.w,
                        color: Colors.blue.shade700,
                        height: 1.3,
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

  Widget _buildBirthdayField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.cake,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Birthday',
              style: TextStyle(
                fontSize: 3.5.w,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                fontSize: 3.5.w,
                color: Colors.red,
              ),
            ),
          ],
        ),
        
        SizedBox(height: 1.h),
        
        InkWell(
          onTap: _selectBirthday,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedBirthday != null
                        ? '${_selectedBirthday!.day}/${_selectedBirthday!.month}/${_selectedBirthday!.year}'
                        : 'Select your birthday',
                    style: TextStyle(
                      fontSize: 3.w,
                      color: _selectedBirthday != null ? Colors.grey.shade800 : Colors.grey.shade500,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: Colors.grey.shade600,
                  size: 4.w,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCivilStatusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.person_outline,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Civil Status',
              style: TextStyle(
                fontSize: 3.5.w,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                fontSize: 3.5.w,
                color: Colors.red,
              ),
            ),
          ],
        ),
        
        SizedBox(height: 1.h),
        
        InkWell(
          onTap: _selectCivilStatus,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedCivilStatus != null
                        ? _civilStatusLabels[_selectedCivilStatus]!
                        : 'Select your civil status',
                    style: TextStyle(
                      fontSize: 3.w,
                      color: _selectedCivilStatus != null ? Colors.grey.shade800 : Colors.grey.shade500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey.shade600,
                  size: 5.w,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lock,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Password',
              style: TextStyle(
                fontSize: 3.5.w,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                fontSize: 3.5.w,
                color: Colors.red,
              ),
            ),
          ],
        ),
        
        SizedBox(height: 1.h),
        
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'Create a strong password',
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 3.5.w,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 3.h,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey.shade600,
                size: 4.w,
              ),
            ),
          ),
          style: TextStyle(
            fontSize: 3.5.w,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordConfirmationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lock_outline,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Confirm Password',
              style: TextStyle(
                fontSize: 3.5.w,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                fontSize: 3.5.w,
                color: Colors.red,
              ),
            ),
          ],
        ),
        
        SizedBox(height: 1.h),
        
        TextFormField(
          controller: _passwordConfirmationController,
          obscureText: _obscurePasswordConfirmation,
          decoration: InputDecoration(
            hintText: 'Confirm your password',
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 3.5.w,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 3.h,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePasswordConfirmation = !_obscurePasswordConfirmation;
                });
              },
              icon: Icon(
                _obscurePasswordConfirmation ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey.shade600,
                size: 4.w,
              ),
            ),
          ),
          style: TextStyle(
            fontSize: 3.5.w,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    return Container(
      padding: EdgeInsets.all(2.5.w),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.amber.shade600,
                size: 3.5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Password Requirements',
                style: TextStyle(
                  fontSize: 3.w,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 1.5.h),
          
          _buildRequirementItem('At least 8 characters long', _passwordController.text.length >= 8),
          _buildRequirementItem('Contains uppercase letter', _passwordController.text.contains(RegExp(r'[A-Z]'))),
          _buildRequirementItem('Contains lowercase letter', _passwordController.text.contains(RegExp(r'[a-z]'))),
          _buildRequirementItem('Contains number', _passwordController.text.contains(RegExp(r'[0-9]'))),
          _buildRequirementItem('Passwords match', _passwordController.text == _passwordConfirmationController.text && _passwordController.text.isNotEmpty),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.8.h),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMet ? Colors.green.shade600 : Colors.grey.shade400,
            size: 3.5.w,
          ),
          SizedBox(width: 2.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 3.2.w,
              color: isMet ? Colors.green.shade700 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)), // At least 13 years old
    );
    
    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
        _onDataChanged();
      });
    }
  }

  void _selectCivilStatus() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Civil Status',
              style: TextStyle(
                fontSize: 5.w,
                fontWeight: FontWeight.bold,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
            
            SizedBox(height: 3.h),
            
            ..._civilStatusOptions.map((status) => ListTile(
              title: Text(
                _civilStatusLabels[status]!,
                style: TextStyle(fontSize: 4.w),
              ),
              onTap: () {
                setState(() {
                  _selectedCivilStatus = status;
                  _onDataChanged();
                });
                Navigator.pop(context);
              },
              trailing: _selectedCivilStatus == status
                  ? Icon(Icons.check, color: AppTheme.lightTheme.colorScheme.primary)
                  : null,
            )).toList(),
          ],
        ),
      ),
    );
  }
}
