import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/api_service.dart';
import './widgets/ai_assistance_widget.dart';
import './widgets/attachment_widget.dart';
import './widgets/concern_type_widget.dart';
import './widgets/department_selection_widget.dart';
import './widgets/facility_selection_widget.dart';
import './widgets/priority_selector_widget.dart';

class SubmitConcern extends StatefulWidget {
  const SubmitConcern({Key? key}) : super(key: key);

  @override
  State<SubmitConcern> createState() => _SubmitConcernState();
}

class _SubmitConcernState extends State<SubmitConcern> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _concernController = TextEditingController();
  final _subjectController = TextEditingController();

  String? _selectedDepartment;
  String? _selectedFacility;
  String? _selectedConcernType;
  String _selectedPriority = 'Medium';
  bool _isAnonymous = false;
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _attachments = [];

  // Form validation errors
  String? _departmentError;
  String? _facilityError;
  String? _concernTypeError;
  String? _subjectError;
  String? _concernError;

  @override
  void dispose() {
    _scrollController.dispose();
    _concernController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    setState(() {
      _departmentError =
          _selectedDepartment == null ? 'Please select your department' : null;
      _facilityError =
          _selectedFacility == null ? 'Please select a facility' : null;
      _concernTypeError =
          _selectedConcernType == null ? 'Please select a concern type' : null;
      _subjectError = _subjectController.text.trim().isEmpty
          ? 'Please enter a subject'
          : null;
      _concernError = _concernController.text.trim().isEmpty
          ? 'Please describe your concern'
          : null;
    });

    return _departmentError == null &&
        _facilityError == null &&
        _concernTypeError == null &&
        _subjectError == null &&
        _concernError == null;
  }

  Future<void> _submitConcern() async {
    if (!_validateForm()) {
      // Scroll to first error
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get department ID from selected department name
      final departments = await apiService.getDepartments();
      final selectedDept = departments.firstWhere(
        (dept) => dept['name'] == _selectedDepartment,
        orElse: () => departments.first,
      );
      
      // Submit concern via API
      final concernData = await apiService.createConcern(
        subject: _subjectController.text.trim(),
        description: _concernController.text.trim(),
        departmentId: selectedDept['id'],
        facilityId: null, // TODO: Map facility selection to ID
        type: _selectedConcernType ?? 'general',
        priority: _selectedPriority.toLowerCase(),
        isAnonymous: _isAnonymous,
        attachments: _attachments.map((att) => att['url'] as String).toList(),
      );

      // Navigate to concern details
      Navigator.pushReplacementNamed(
        context,
        '/concern-details',
        arguments: concernData,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit concern. Please try again.'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _onAiSuggestionApplied(String suggestion) {
    setState(() {
      _concernController.text = suggestion;
    });
  }

  void _onAttachmentAdded(Map<String, dynamic> attachment) {
    setState(() {
      _attachments.add(attachment);
    });
  }

  void _onAttachmentRemoved(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Submit Concern',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        foregroundColor: AppTheme.lightTheme.appBarTheme.foregroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.appBarTheme.foregroundColor!,
            size: 24,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Information
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'info',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 24,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bestlink College Support',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Submit your concern and we\'ll help you resolve it promptly.',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.primary
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Subject Field
                    Text(
                      'Subject *',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      controller: _subjectController,
                      decoration: InputDecoration(
                        hintText: 'Brief summary of your concern',
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: CustomIconWidget(
                            iconName: 'title',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        errorText: _subjectError,
                      ),
                      onChanged: (value) {
                        if (_subjectError != null) {
                          setState(() {
                            _subjectError = null;
                          });
                        }
                      },
                    ),

                    SizedBox(height: 3.h),

                    // Department Selection
                    DepartmentSelectionWidget(
                      selectedDepartment: _selectedDepartment,
                      onChanged: (value) {
                        setState(() {
                          _selectedDepartment = value;
                          _departmentError = null;
                        });
                      },
                      errorText: _departmentError,
                    ),

                    SizedBox(height: 3.h),

                    // Facility Selection
                    FacilitySelectionWidget(
                      selectedFacility: _selectedFacility,
                      onChanged: (value) {
                        setState(() {
                          _selectedFacility = value;
                          _facilityError = null;
                        });
                      },
                      errorText: _facilityError,
                    ),

                    SizedBox(height: 3.h),

                    // Concern Type Selection
                    ConcernTypeWidget(
                      selectedType: _selectedConcernType,
                      onChanged: (value) {
                        setState(() {
                          _selectedConcernType = value;
                          _concernTypeError = null;
                        });
                      },
                      errorText: _concernTypeError,
                    ),

                    SizedBox(height: 3.h),

                    // Priority Selection
                    PrioritySelectorWidget(
                      selectedPriority: _selectedPriority,
                      onChanged: (value) {
                        setState(() {
                          _selectedPriority = value;
                        });
                      },
                    ),

                    SizedBox(height: 3.h),

                    // Anonymous Toggle
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'visibility_off',
                            color: _isAnonymous
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                            size: 24,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Submit Anonymously',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Your identity will be kept confidential',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isAnonymous,
                            onChanged: (value) {
                              setState(() {
                                _isAnonymous = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Concern Description
                    Text(
                      'Describe Your Concern *',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      controller: _concernController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText:
                            'Please provide detailed information about your concern...',
                        alignLabelWithHint: true,
                        errorText: _concernError,
                      ),
                      onChanged: (value) {
                        if (_concernError != null) {
                          setState(() {
                            _concernError = null;
                          });
                        }
                      },
                    ),

                    // AI Assistance
                    AiAssistanceWidget(
                      textController: _concernController,
                      onSuggestionApplied: _onAiSuggestionApplied,
                    ),

                    SizedBox(height: 3.h),

                    // Attachments
                    AttachmentWidget(
                      attachments: _attachments,
                      onAttachmentAdded: _onAttachmentAdded,
                      onAttachmentRemoved: _onAttachmentRemoved,
                    ),

                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),

            // Submit Button
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitConcern,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 2,
                ),
                child: _isSubmitting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'Submitting...',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'send',
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'Submit Concern',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
