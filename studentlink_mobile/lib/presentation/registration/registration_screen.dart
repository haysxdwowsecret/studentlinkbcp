import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import 'widgets/modern_registration_progress_widget.dart';
import 'widgets/modern_step1_student_id_generation_widget.dart';
import 'widgets/modern_step2_personal_info_widget.dart';
import 'widgets/modern_step3_contact_info_widget.dart';
import 'widgets/modern_step4_otp_verification_widget.dart';
import 'widgets/modern_step5_account_creation_widget.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  int _currentStep = 1;
  bool _isLoading = false;
  String? _errorMessage;

  // Registration data
  String? _generatedStudentId;
  String? _generatedSchoolEmail;
  String? _firstName;
  String? _middleName;
  String? _lastName;
  String? _suffix;
  String? _course;
  String? _yearLevel;
  String? _personalEmail;
  String? _contactNumber;
  String? _emailOtp;
  String? _phoneOtp;
  DateTime? _birthday;
  String? _civilStatus;
  String? _password;
  String? _passwordConfirmation;
  bool _agreeToTerms = false;
  bool _agreeToPrivacy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Modern light background
      resizeToAvoidBottomInset: false,
      appBar: _buildModernAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Modern progress indicator
            ModernRegistrationProgressWidget(
              currentStep: _currentStep,
              totalSteps: 6,
            ),
            
            // Modern error message
            if (_errorMessage != null)
              _buildModernErrorMessage(),

            // Step content with modern styling
            Expanded(
              child: RepaintBoundary(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 200,
                    ),
                    child: _buildModernStepContent(),
                  ),
                ),
              ),
            ),

            // Modern navigation buttons
            _buildModernNavigationButtons(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1A1A1A),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      title: Text(
        'Student Registration',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          color: const Color(0xFF1A1A1A),
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_ios_rounded),
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFFF3F4F6),
          foregroundColor: const Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildModernErrorMessage() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        border: Border.all(color: const Color(0xFFFECACA)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: const Color(0xFFDC2626),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFDC2626),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _errorMessage = null),
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFFDC2626),
              size: 18,
            ),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFFECACA),
              padding: const EdgeInsets.all(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStepContent() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Modern divider
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: _buildStepContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return ModernStep1StudentIdGenerationWidget(
          onStudentIdGenerated: (studentId, schoolEmail) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _generatedStudentId = studentId;
                _generatedSchoolEmail = schoolEmail;
                _errorMessage = null;
              });
            });
          },
          onError: (error) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() => _errorMessage = error);
            });
          },
        );
      case 2:
        return ModernStep2PersonalInfoWidget(
          onDataChanged: (firstName, middleName, lastName, suffix, course, yearLevel, birthday, civilStatus) {
            setState(() {
              _firstName = firstName;
              _middleName = middleName;
              _lastName = lastName;
              _suffix = suffix;
              _course = course;
              _yearLevel = yearLevel;
              _birthday = birthday;
              _civilStatus = civilStatus;
              _errorMessage = null;
            });
          },
        );
      case 3:
        return ModernStep3ContactInfoWidget(
          schoolEmail: _generatedSchoolEmail,
          onDataChanged: (personalEmail, contactNumber) {
            setState(() {
              _personalEmail = personalEmail;
              _contactNumber = contactNumber;
              _errorMessage = null;
            });
          },
        );
      case 4:
        return ModernStep4OtpVerificationWidget(
          personalEmail: _personalEmail ?? '',
          contactNumber: _contactNumber ?? '',
          onDataChanged: (emailOtp, phoneOtp) {
            setState(() {
              _emailOtp = emailOtp;
              _phoneOtp = phoneOtp;
              _errorMessage = null;
            });
          },
          onError: (error) {
            setState(() => _errorMessage = error);
          },
        );
      case 5:
        return ModernStep5AccountCreationWidget(
          onDataChanged: (password, passwordConfirmation) {
            setState(() {
              _password = password;
              _passwordConfirmation = passwordConfirmation;
              _errorMessage = null;
            });
          },
          onTermsChanged: (agreeToTerms, agreeToPrivacy) {
            setState(() {
              _agreeToTerms = agreeToTerms;
              _agreeToPrivacy = agreeToPrivacy;
              _errorMessage = null;
            });
          },
        );
      case 6:
        return ModernStep5AccountCreationWidget(
          onDataChanged: (password, passwordConfirmation) {
            setState(() {
              _password = password;
              _passwordConfirmation = passwordConfirmation;
              _errorMessage = null;
            });
          },
          onTermsChanged: (agreeToTerms, agreeToPrivacy) {
            setState(() {
              _agreeToTerms = agreeToTerms;
              _agreeToPrivacy = agreeToPrivacy;
              _errorMessage = null;
            });
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildModernNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 1)
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Previous',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_currentStep > 1) const SizedBox(width: 12),
          Expanded(
            flex: _currentStep == 1 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _currentStep == 6 ? 'Create Account' : 'Continue',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
        _errorMessage = null;
      });
    }
  }

  void _nextStep() {
    if (_canProceedToNextStep()) {
      if (_currentStep < 6) {
        setState(() {
          _currentStep++;
          _errorMessage = null;
        });
      } else {
        _createAccount();
      }
    }
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 1:
        return _generatedStudentId != null && _generatedSchoolEmail != null;
      case 2:
        return _firstName != null && 
               _lastName != null && 
               _course != null && 
               _yearLevel != null &&
               _birthday != null &&
               _civilStatus != null;
      case 3:
        return _personalEmail != null && _contactNumber != null;
      case 4:
        return _emailOtp != null && _phoneOtp != null;
      case 5:
        return _password != null && 
               _passwordConfirmation != null &&
               _password == _passwordConfirmation &&
               _agreeToTerms && 
               _agreeToPrivacy;
      case 6:
        return true;
      default:
        return false;
    }
  }




  Future<void> _createAccount() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final registrationData = {
        'student_id': _generatedStudentId,
        'first_name': _firstName,
        'middle_name': _middleName,
        'last_name': _lastName,
        'suffix': _suffix,
        'course': _course,
        'year_level': _yearLevel,
        'personal_email': _personalEmail,
        'contact_number': _contactNumber,
        'email_otp': _emailOtp,
        'phone_otp': _phoneOtp,
        'birthday': _birthday!.toIso8601String().split('T')[0],
        'civil_status': _civilStatus,
        'password': _password,
        'password_confirmation': _passwordConfirmation,
      };

      final result = await apiService.createStudentAccount(registrationData);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created successfully! Welcome, ${result['name']}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate to main app
        Navigator.of(context).pushReplacementNamed('/dashboard-home');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e is AppError ? e.message : 'Failed to create account. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
