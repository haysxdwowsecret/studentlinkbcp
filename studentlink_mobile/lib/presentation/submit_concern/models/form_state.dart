import 'package:flutter/foundation.dart';

/// Represents the current state of the concern submission form
@immutable
class ConcernFormState {
  final String? subject;
  final String? department;
  final String? concernType;
  final String priority;
  final bool isAnonymous;
  final String? description;
  final List<Map<String, dynamic>> attachments;
  final Map<String, String> validationErrors;
  final bool isDirty;
  final bool isSubmitting;
  final bool isAutoSaving;
  final DateTime? lastSaved;
  final int currentStep;
  final int totalSteps;

  const ConcernFormState({
    this.subject,
    this.department,
    this.concernType,
    this.priority = 'Medium',
    this.isAnonymous = false,
    this.description,
    this.attachments = const [],
    this.validationErrors = const {},
    this.isDirty = false,
    this.isSubmitting = false,
    this.isAutoSaving = false,
    this.lastSaved,
    this.currentStep = 1,
    this.totalSteps = 6,
  });

  /// Creates a copy of this state with the given fields replaced
  ConcernFormState copyWith({
    String? subject,
    String? department,
    String? concernType,
    String? priority,
    bool? isAnonymous,
    String? description,
    List<Map<String, dynamic>>? attachments,
    Map<String, String>? validationErrors,
    bool? isDirty,
    bool? isSubmitting,
    bool? isAutoSaving,
    DateTime? lastSaved,
    int? currentStep,
    int? totalSteps,
    bool clearValidationErrors = false,
  }) {
    return ConcernFormState(
      subject: subject ?? this.subject,
      department: department ?? this.department,
      concernType: concernType ?? this.concernType,
      priority: priority ?? this.priority,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      description: description ?? this.description,
      attachments: attachments ?? this.attachments,
      validationErrors: clearValidationErrors 
          ? {} 
          : (validationErrors ?? this.validationErrors),
      isDirty: isDirty ?? this.isDirty,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isAutoSaving: isAutoSaving ?? this.isAutoSaving,
      lastSaved: lastSaved ?? this.lastSaved,
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
    );
  }

  /// Calculates the completion percentage of the form
  double get completionPercentage {
    int completedFields = 0;
    int totalRequiredFields = 4; // subject, department, concernType, description
    
    if (subject?.isNotEmpty == true) completedFields++;
    if (department?.isNotEmpty == true) completedFields++;
    if (concernType?.isNotEmpty == true) completedFields++;
    if (description?.isNotEmpty == true) completedFields++;
    
    return completedFields / totalRequiredFields;
  }

  /// Checks if the form is valid for submission
  bool get isValid {
    return subject?.isNotEmpty == true &&
           department?.isNotEmpty == true &&
           concernType?.isNotEmpty == true &&
           description?.isNotEmpty == true &&
           validationErrors.isEmpty;
  }

  /// Checks if the current step is valid
  bool isStepValid(int step) {
    switch (step) {
      case 1: // Subject
        return subject?.isNotEmpty == true;
      case 2: // Department
        return department?.isNotEmpty == true;
      case 3: // Concern Type
        return concernType?.isNotEmpty == true;
      case 4: // Priority (always valid as it has a default)
        return true;
      case 5: // Anonymous (always valid as it has a default)
        return true;
      case 6: // Description
        return description?.isNotEmpty == true;
      default:
        return false;
    }
  }

  /// Gets the next step number
  int get nextStep {
    for (int i = currentStep + 1; i <= totalSteps; i++) {
      if (!isStepValid(i)) {
        return i;
      }
    }
    return totalSteps;
  }

  /// Gets the previous step number
  int get previousStep {
    return currentStep > 1 ? currentStep - 1 : 1;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConcernFormState &&
        other.subject == subject &&
        other.department == department &&
        other.concernType == concernType &&
        other.priority == priority &&
        other.isAnonymous == isAnonymous &&
        other.description == description &&
        listEquals(other.attachments, attachments) &&
        mapEquals(other.validationErrors, validationErrors) &&
        other.isDirty == isDirty &&
        other.isSubmitting == isSubmitting &&
        other.isAutoSaving == isAutoSaving &&
        other.lastSaved == lastSaved &&
        other.currentStep == currentStep &&
        other.totalSteps == totalSteps;
  }

  @override
  int get hashCode {
    return Object.hash(
      subject,
      department,
      concernType,
      priority,
      isAnonymous,
      description,
      Object.hashAll(attachments),
      Object.hashAll(validationErrors.entries),
      isDirty,
      isSubmitting,
      isAutoSaving,
      lastSaved,
      currentStep,
      totalSteps,
    );
  }

  @override
  String toString() {
    return 'ConcernFormState('
        'subject: $subject, '
        'department: $department, '
        'concernType: $concernType, '
        'priority: $priority, '
        'isAnonymous: $isAnonymous, '
        'description: $description, '
        'attachments: ${attachments.length}, '
        'validationErrors: ${validationErrors.length}, '
        'isDirty: $isDirty, '
        'isSubmitting: $isSubmitting, '
        'isAutoSaving: $isAutoSaving, '
        'lastSaved: $lastSaved, '
        'currentStep: $currentStep, '
        'totalSteps: $totalSteps'
        ')';
  }
}
