import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/form_state.dart';
import 'form_validation_service.dart';

/// Service responsible for managing form state, auto-save, and persistence
class FormStateService extends ChangeNotifier {
  static const String _draftKey = 'concern_form_draft';
  static const Duration _debounceDelay = Duration(milliseconds: 500);

  ConcernFormState _state = const ConcernFormState();
  Timer? _autoSaveTimer;
  Timer? _debounceTimer;

  ConcernFormState get state => _state;

  /// Updates a specific field in the form state
  void updateField(String fieldName, dynamic value) {
    print('FormStateService: Updating field "$fieldName" with value: "$value"');
    
    // Clear validation errors for this field first
    _clearFieldValidationError(fieldName);
    
    // Update the state with the new value
    var newState = _state.copyWith(isDirty: true);
    
    switch (fieldName) {
      case 'subject':
        newState = newState.copyWith(subject: value as String?);
        break;
      case 'department':
        newState = newState.copyWith(department: value as String?);
        break;
      case 'concernType':
        newState = newState.copyWith(concernType: value as String?);
        break;
      case 'priority':
        newState = newState.copyWith(priority: value as String);
        break;
      case 'isAnonymous':
        newState = newState.copyWith(isAnonymous: value as bool);
        break;
      case 'description':
        newState = newState.copyWith(description: value as String?);
        break;
      case 'attachments':
        newState = newState.copyWith(attachments: value as List<Map<String, dynamic>>);
        break;
    }

    _state = newState;
    print('FormStateService: Updated state - Subject: "${_state.subject}", Description: "${_state.description}"');
    
    // Trigger auto-save with debounce
    _scheduleAutoSave();
    
    // Validate field in real-time
    _validateField(fieldName, value);
    
    notifyListeners();
  }

  /// Updates multiple fields at once
  void updateFields(Map<String, dynamic> updates) {
    var newState = _state.copyWith(isDirty: true);
    
    for (final entry in updates.entries) {
      switch (entry.key) {
        case 'subject':
          newState = newState.copyWith(subject: entry.value as String?);
          break;
        case 'department':
          newState = newState.copyWith(department: entry.value as String?);
          break;
        case 'concernType':
          newState = newState.copyWith(concernType: entry.value as String?);
          break;
        case 'priority':
          newState = newState.copyWith(priority: entry.value as String);
          break;
        case 'isAnonymous':
          newState = newState.copyWith(isAnonymous: entry.value as bool);
          break;
        case 'description':
          newState = newState.copyWith(description: entry.value as String?);
          break;
        case 'attachments':
          newState = newState.copyWith(attachments: entry.value as List<Map<String, dynamic>>);
          break;
      }
    }

    _state = newState;
    
    // Clear validation errors for updated fields
    for (final fieldName in updates.keys) {
      _clearFieldValidationError(fieldName);
    }
    
    // Trigger auto-save
    _scheduleAutoSave();
    
    // Validate all updated fields
    for (final entry in updates.entries) {
      _validateField(entry.key, entry.value);
    }
    
    notifyListeners();
  }

  /// Sets the current step
  void setCurrentStep(int step) {
    if (step >= 1 && step <= _state.totalSteps) {
      _state = _state.copyWith(currentStep: step);
      notifyListeners();
    }
  }

  /// Moves to the next step
  void nextStep() {
    final nextStepNumber = _state.nextStep;
    if (nextStepNumber <= _state.totalSteps) {
      _state = _state.copyWith(currentStep: nextStepNumber);
      notifyListeners();
    }
  }

  /// Moves to the previous step
  void previousStep() {
    final previousStepNumber = _state.previousStep;
    if (previousStepNumber >= 1) {
      _state = _state.copyWith(currentStep: previousStepNumber);
      notifyListeners();
    }
  }

  /// Sets the submitting state
  void setSubmitting(bool isSubmitting) {
    _state = _state.copyWith(isSubmitting: isSubmitting);
    notifyListeners();
  }

  /// Validates the entire form
  void validateForm() {
    final errors = FormValidationService.validateForm(
      subject: _state.subject,
      department: _state.department,
      concernType: _state.concernType,
      description: _state.description,
      attachments: _state.attachments,
    );

    _state = _state.copyWith(validationErrors: errors);
    notifyListeners();
  }
  
  /// Validates the entire form and returns true if valid
  bool validateFormAndReturn() {
    validateForm();
    return isValid;
  }

  /// Clears all validation errors
  void clearValidationErrors() {
    _state = _state.copyWith(validationErrors: {}, clearValidationErrors: true);
    notifyListeners();
  }

  /// Resets the form to initial state
  void resetForm() {
    _state = const ConcernFormState();
    _cancelTimers();
    _clearDraft();
    notifyListeners();
  }

  /// Loads draft from local storage
  Future<void> loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftJson = prefs.getString(_draftKey);
      
      if (draftJson != null) {
        final draftData = json.decode(draftJson) as Map<String, dynamic>;
        _state = _state.copyWith(
          subject: draftData['subject'] as String?,
          department: draftData['department'] as String?,
          concernType: draftData['concernType'] as String?,
          priority: draftData['priority'] as String? ?? 'Medium',
          isAnonymous: draftData['isAnonymous'] as bool? ?? false,
          description: draftData['description'] as String?,
          attachments: List<Map<String, dynamic>>.from(
            (draftData['attachments'] as List?) ?? []
          ),
          isDirty: false,
          lastSaved: draftData['lastSaved'] != null 
              ? DateTime.parse(draftData['lastSaved'] as String)
              : null,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading draft: $e');
    }
  }

  /// Saves draft to local storage
  Future<void> saveDraft() async {
    if (!_state.isDirty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final draftData = {
        'subject': _state.subject,
        'department': _state.department,
        'concernType': _state.concernType,
        'priority': _state.priority,
        'isAnonymous': _state.isAnonymous,
        'description': _state.description,
        'attachments': _state.attachments,
        'lastSaved': DateTime.now().toIso8601String(),
      };

      await prefs.setString(_draftKey, json.encode(draftData));
      
      _state = _state.copyWith(
        isDirty: false,
        lastSaved: DateTime.now(),
        isAutoSaving: false,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving draft: $e');
    }
  }

  /// Clears the draft from local storage
  Future<void> _clearDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey);
    } catch (e) {
      debugPrint('Error clearing draft: $e');
    }
  }

  /// Schedules auto-save with debounce
  void _scheduleAutoSave() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      if (_state.isDirty) {
        _state = _state.copyWith(isAutoSaving: true);
        notifyListeners();
        saveDraft();
      }
    });
  }

  /// Cancels all timers
  void _cancelTimers() {
    _autoSaveTimer?.cancel();
    _debounceTimer?.cancel();
  }

  /// Validates a specific field
  void _validateField(String fieldName, dynamic value) {
    final error = FormValidationService.validateField(fieldName, value);
    if (error != null) {
      final newErrors = Map<String, String>.from(_state.validationErrors);
      newErrors[fieldName] = error;
      _state = _state.copyWith(validationErrors: newErrors);
    }
  }

  /// Clears validation error for a specific field
  void _clearFieldValidationError(String fieldName) {
    if (_state.validationErrors.containsKey(fieldName)) {
      final newErrors = Map<String, String>.from(_state.validationErrors);
      newErrors.remove(fieldName);
      _state = _state.copyWith(validationErrors: newErrors);
    }
  }

  /// Gets validation error for a specific field
  String? getFieldError(String fieldName) {
    return _state.validationErrors[fieldName];
  }

  /// Checks if a field has validation error
  bool hasFieldError(String fieldName) {
    return _state.validationErrors.containsKey(fieldName);
  }

  /// Gets the completion percentage
  double get completionPercentage => _state.completionPercentage;

  /// Checks if the form is valid
  bool get isValid => _state.isValid;

  /// Checks if the current step is valid
  bool isStepValid(int step) => _state.isStepValid(step);

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}
