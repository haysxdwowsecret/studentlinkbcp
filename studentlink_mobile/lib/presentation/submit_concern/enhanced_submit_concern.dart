import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'services/form_state_service.dart';
import 'services/form_validation_service.dart';
import 'widgets/enhanced_progress_indicator.dart';
import 'widgets/enhanced_form_field.dart';
import 'widgets/modern_concern_type_widget.dart';
import 'widgets/modern_department_selection_widget.dart';
import 'widgets/modern_priority_selector_widget.dart';
import 'widgets/modern_ai_assistance_widget.dart';
import 'widgets/modern_attachment_widget.dart';

/// Enhanced submit concern screen with comprehensive form management
class EnhancedSubmitConcern extends StatefulWidget {
  const EnhancedSubmitConcern({Key? key}) : super(key: key);

  @override
  State<EnhancedSubmitConcern> createState() => _EnhancedSubmitConcernState();
}

class _EnhancedSubmitConcernState extends State<EnhancedSubmitConcern>
    with TickerProviderStateMixin {
  late FormStateService _formStateService;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _formStateService = FormStateService();
    _formStateService.addListener(_onFormStateChanged);
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
    
    _initializeForm();
    _slideController.forward();
  }

  @override
  void dispose() {
    _formStateService.removeListener(_onFormStateChanged);
    _formStateService.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initializeForm() async {
    // Load draft if available
    await _formStateService.loadDraft();
    
    // Set initial values from draft
    final state = _formStateService.state;
    if (state.subject != null) {
      _subjectController.text = state.subject!;
    }
    if (state.description != null) {
      _descriptionController.text = state.description!;
    }
  }

  void _onFormStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        resizeToAvoidBottomInset: false,
        appBar: _buildEnhancedAppBar(),
        body: SlideTransition(
          position: _slideAnimation,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Progress indicator
                _buildProgressSection(),
                
                // Form content
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header information
                        _buildHeaderSection(),
                        
                        const SizedBox(height: 24),
                        
                        // Form fields based on current step
                        _buildCurrentStepContent(),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                
                // Bottom action bar
                _buildBottomActionBar(),
              ],
            ),
          ),
        ),
    );
  }

  PreferredSizeWidget _buildEnhancedAppBar() {
    final state = _formStateService.state;
    
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Submit Concern',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          if (state.isAutoSaving)
            Text(
              'Saving draft...',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6B7280),
                fontSize: 12,
              ),
            ),
        ],
      ),
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1A1A1A),
      elevation: 0,
      leading: IconButton(
        onPressed: _handleBackPressed,
        icon: Icon(
          Icons.arrow_back_rounded,
          color: AppTheme.primaryLight,
          size: 24,
        ),
      ),
      actions: [
        // Draft indicator
        if (state.isDirty)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.warningLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.edit_rounded,
                  color: AppTheme.warningLight,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  'Draft',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.warningLight,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        
        // Cancel button
        TextButton(
          onPressed: _handleCancel,
          child: Text(
            'Cancel',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: const Color(0xFFE5E7EB),
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    final state = _formStateService.state;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: EnhancedProgressIndicator(
        currentStep: state.currentStep,
        totalSteps: state.totalSteps,
        completionPercentage: state.completionPercentage,
        showStepLabels: true,
        showPercentage: true,
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryLight.withValues(alpha: 0.1),
            AppTheme.secondaryLight.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryLight.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.support_agent_rounded,
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
                  'Bestlink College Support',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Submit your concern and we\'ll help you resolve it promptly.',
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
    );
  }

  Widget _buildCurrentStepContent() {
    final state = _formStateService.state;
    
    switch (state.currentStep) {
      case 1:
        return _buildSubjectStep();
      case 2:
        return _buildDepartmentStep();
      case 3:
        return _buildConcernTypeStep();
      case 4:
        return _buildPriorityStep();
      case 5:
        return _buildOptionsStep();
      case 6:
        return _buildDescriptionStep();
      default:
        return _buildSubjectStep();
    }
  }

  Widget _buildSubjectStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EnhancedFormField(
          fieldName: 'subject',
          label: 'Subject',
          hint: 'Brief summary of your concern',
          icon: Icons.title_rounded,
          controller: _subjectController,
          errorText: _formStateService.getFieldError('subject'),
          isRequired: true,
          maxLength: 100,
          showCharacterCount: true,
          onChanged: (value) {
            print('Subject field changed: "$value"');
            _formStateService.updateField('subject', value);
          },
        ),
      ],
    );
  }

  Widget _buildDepartmentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModernDepartmentSelectionWidget(
          selectedDepartment: _formStateService.state.department,
          onChanged: (value) => _formStateService.updateField('department', value),
          errorText: _formStateService.getFieldError('department'),
        ),
      ],
    );
  }

  Widget _buildConcernTypeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModernConcernTypeWidget(
          selectedType: _formStateService.state.concernType,
          onChanged: (value) => _formStateService.updateField('concernType', value),
          errorText: _formStateService.getFieldError('concernType'),
        ),
      ],
    );
  }

  Widget _buildPriorityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModernPrioritySelectorWidget(
          selectedPriority: _formStateService.state.priority,
          onChanged: (value) => _formStateService.updateField('priority', value),
        ),
      ],
    );
  }

  Widget _buildOptionsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAnonymousToggle(),
        const SizedBox(height: 24),
        _buildAttachmentsSection(),
      ],
    );
  }

  Widget _buildDescriptionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConcernDescriptionField(
          fieldName: 'description',
          controller: _descriptionController,
          errorText: _formStateService.getFieldError('description'),
          onChanged: (value) {
            print('Description field changed: "$value"');
            _formStateService.updateField('description', value);
          },
        ),
        const SizedBox(height: 16),
        ModernAiAssistanceWidget(
          textController: _descriptionController,
          onSuggestionApplied: (suggestion) {
            _descriptionController.text = suggestion;
            _formStateService.updateField('description', suggestion);
          },
        ),
      ],
    );
  }

  Widget _buildAnonymousToggle() {
    final state = _formStateService.state;
    
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: state.isAnonymous
                  ? AppTheme.primaryLight
                  : AppTheme.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.visibility_off_rounded,
              color: state.isAnonymous ? Colors.white : AppTheme.primaryLight,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Submit Anonymously',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your identity will be kept confidential',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: state.isAnonymous,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              _formStateService.updateField('isAnonymous', value);
            },
            activeColor: AppTheme.primaryLight,
            activeTrackColor: AppTheme.primaryLight.withValues(alpha: 0.3),
            inactiveThumbColor: const Color(0xFF9CA3AF),
            inactiveTrackColor: const Color(0xFFE5E7EB),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    final state = _formStateService.state;
    
    return ModernAttachmentWidget(
      attachments: state.attachments,
      onAttachmentAdded: (attachment) {
        final newAttachments = [...state.attachments, attachment];
        _formStateService.updateField('attachments', newAttachments);
      },
      onAttachmentRemoved: (index) {
        final newAttachments = List<Map<String, dynamic>>.from(state.attachments);
        newAttachments.removeAt(index);
        _formStateService.updateField('attachments', newAttachments);
      },
    );
  }

  Widget _buildBottomActionBar() {
    final state = _formStateService.state;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous button
          if (state.currentStep > 1)
            Expanded(
              child: OutlinedButton(
                onPressed: _handlePreviousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryLight,
                  side: BorderSide(color: AppTheme.primaryLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text('Previous'),
                  ],
                ),
              ),
            ),
          
          if (state.currentStep > 1) const SizedBox(width: 12),
          
          // Next/Submit button
          Expanded(
            flex: state.currentStep > 1 ? 1 : 2,
            child: ElevatedButton(
              onPressed: state.currentStep < state.totalSteps 
                  ? _handleNextStep 
                  : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryLight,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: state.isSubmitting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('Submitting...'),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (state.currentStep < state.totalSteps) ...[
                          Text('Next'),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ] else ...[
                          Icon(Icons.send_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text('Submit Concern'),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleBackPressed() {
    if (_formStateService.state.isDirty) {
      _showUnsavedChangesDialog();
    } else {
      Navigator.pop(context);
    }
  }

  void _handleCancel() {
    if (_formStateService.state.isDirty) {
      _showUnsavedChangesDialog();
    } else {
      Navigator.pop(context);
    }
  }

  void _handlePreviousStep() {
    HapticFeedback.lightImpact();
    _formStateService.previousStep();
    _scrollToTop();
  }

  void _handleNextStep() {
    final state = _formStateService.state;
    
    // Validate current step with additional checks
    bool isCurrentStepValid = true;
    
    switch (state.currentStep) {
      case 1: // Subject
        if (state.subject?.trim().isEmpty ?? true) {
          _formStateService.updateField('subject', '');
          isCurrentStepValid = false;
        }
        break;
      case 2: // Department
        if (state.department?.isEmpty ?? true) {
          _formStateService.updateField('department', '');
          isCurrentStepValid = false;
        }
        break;
      case 3: // Concern Type
        if (state.concernType?.isEmpty ?? true) {
          _formStateService.updateField('concernType', '');
          isCurrentStepValid = false;
        }
        break;
      case 6: // Description
        if (state.description?.trim().isEmpty ?? true) {
          _formStateService.updateField('description', '');
          isCurrentStepValid = false;
        }
        break;
    }
    
    if (!isCurrentStepValid) {
      _formStateService.validateFormAndReturn();
      _showValidationError();
      return;
    }
    
    HapticFeedback.lightImpact();
    _formStateService.nextStep();
    _scrollToTop();
  }

  void _handleSubmit() async {
    final state = _formStateService.state;
    
    // Debug: Print current form state
    print('=== FORM SUBMISSION DEBUG ===');
    print('Subject: "${state.subject}"');
    print('Description: "${state.description}"');
    print('Department: "${state.department}"');
    print('Concern Type: "${state.concernType}"');
    print('Priority: "${state.priority}"');
    print('Is Anonymous: ${state.isAnonymous}');
    print('Validation Errors: ${state.validationErrors}');
    print('=============================');
    
    // Validate entire form and check if valid
    if (!_formStateService.validateFormAndReturn()) {
      print('Form validation failed');
      _showValidationError();
      return;
    }
    
    // Additional validation checks
    if (state.subject?.trim().isEmpty ?? true) {
      _formStateService.updateField('subject', '');
      _showValidationError();
      return;
    }
    
    if (state.description?.trim().isEmpty ?? true) {
      _formStateService.updateField('description', '');
      _showValidationError();
      return;
    }
    
    if (state.department?.isEmpty ?? true) {
      _formStateService.updateField('department', '');
      _showValidationError();
      return;
    }
    
    if (state.concernType?.isEmpty ?? true) {
      _formStateService.updateField('concernType', '');
      _showValidationError();
      return;
    }
    
    _formStateService.setSubmitting(true);
    
    try {
      // Get department ID
      final departments = await apiService.getDepartments();
      final selectedDept = departments.firstWhere(
        (dept) => dept['name'] == state.department,
        orElse: () => {'id': 1, 'name': state.department ?? 'Unknown'},
      );
      
      // Submit concern with validated and sanitized data
      await apiService.createConcern(
        subject: FormValidationService.sanitizeText(state.subject!),
        description: FormValidationService.sanitizeText(state.description!),
        departmentId: selectedDept['id'],
        facilityId: null,
        type: state.concernType!,
        priority: state.priority.toLowerCase(),
        isAnonymous: state.isAnonymous,
        attachments: state.attachments
            .where((att) => att['url'] != null)
            .map((att) => att['url'] as String)
            .toList(),
      );
      
      // Clear draft
      _formStateService.resetForm();
      
      // Show success message
      _showSuccessMessage();
      
      // Navigate back
      Navigator.pushReplacementNamed(context, '/dashboard');
      
    } catch (e) {
      _showErrorMessage(e.toString());
    } finally {
      _formStateService.setSubmitting(false);
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unsaved Changes'),
        content: Text('You have unsaved changes. Do you want to save them as a draft?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Discard'),
          ),
          TextButton(
            onPressed: () async {
              await _formStateService.saveDraft();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Save Draft'),
          ),
        ],
      ),
    );
  }

  void _showValidationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please fill in all required fields'),
        backgroundColor: AppTheme.emergencyLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Concern submitted successfully!'),
        backgroundColor: AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showErrorMessage(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to submit concern: $error'),
        backgroundColor: AppTheme.emergencyLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
