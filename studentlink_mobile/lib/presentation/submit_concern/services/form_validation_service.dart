
/// Service responsible for form validation logic
class FormValidationService {
  static const int _minSubjectLength = 5;
  static const int _maxSubjectLength = 100;
  static const int _minDescriptionLength = 10;
  static const int _maxDescriptionLength = 2000;
  static const int _maxAttachments = 5;
  static const int _maxAttachmentSizeMB = 10;

  /// Validates the entire form and returns validation errors
  static Map<String, String> validateForm({
    String? subject,
    String? department,
    String? concernType,
    String? description,
    List<Map<String, dynamic>>? attachments,
  }) {
    final errors = <String, String>{};

    // Validate subject
    final subjectError = _validateSubject(subject);
    if (subjectError != null) {
      errors['subject'] = subjectError;
    }

    // Validate department
    final departmentError = _validateDepartment(department);
    if (departmentError != null) {
      errors['department'] = departmentError;
    }

    // Validate concern type
    final concernTypeError = _validateConcernType(concernType);
    if (concernTypeError != null) {
      errors['concernType'] = concernTypeError;
    }

    // Validate description
    final descriptionError = _validateDescription(description);
    if (descriptionError != null) {
      errors['description'] = descriptionError;
    }

    // Validate attachments
    final attachmentError = _validateAttachments(attachments);
    if (attachmentError != null) {
      errors['attachments'] = attachmentError;
    }

    return errors;
  }

  /// Validates a specific field and returns error message if invalid
  static String? validateField(String fieldName, dynamic value) {
    switch (fieldName) {
      case 'subject':
        return _validateSubject(value as String?);
      case 'department':
        return _validateDepartment(value as String?);
      case 'concernType':
        return _validateConcernType(value as String?);
      case 'description':
        return _validateDescription(value as String?);
      case 'attachments':
        return _validateAttachments(value as List<Map<String, dynamic>>?);
      default:
        return null;
    }
  }

  /// Validates subject field
  static String? _validateSubject(String? subject) {
    if (subject == null || subject.trim().isEmpty) {
      return 'Subject is required';
    }

    // Sanitize the input before validation
    final sanitizedSubject = sanitizeText(subject);
    if (sanitizedSubject.length < _minSubjectLength) {
      return 'Subject must be at least $_minSubjectLength characters long';
    }

    if (sanitizedSubject.length > _maxSubjectLength) {
      return 'Subject must be no more than $_maxSubjectLength characters long';
    }

    // Check for profanity or inappropriate content (basic check)
    if (_containsInappropriateContent(sanitizedSubject)) {
      return 'Subject contains inappropriate content';
    }

    return null;
  }

  /// Validates department field
  static String? _validateDepartment(String? department) {
    if (department == null || department.trim().isEmpty) {
      return 'Please select your department';
    }

    // Check if department is in the valid list
    final validDepartments = _getValidDepartments();
    if (!validDepartments.contains(department)) {
      return 'Please select a valid department';
    }

    return null;
  }

  /// Validates concern type field
  static String? _validateConcernType(String? concernType) {
    if (concernType == null || concernType.trim().isEmpty) {
      return 'Please select a concern type';
    }

    final validTypes = _getValidConcernTypes();
    if (!validTypes.contains(concernType.toLowerCase())) {
      return 'Please select a valid concern type';
    }

    return null;
  }

  /// Validates description field
  static String? _validateDescription(String? description) {
    if (description == null || description.trim().isEmpty) {
      return 'Please describe your concern';
    }

    // Sanitize the input before validation
    final sanitizedDescription = sanitizeText(description);
    if (sanitizedDescription.length < _minDescriptionLength) {
      return 'Description must be at least $_minDescriptionLength characters long';
    }

    if (sanitizedDescription.length > _maxDescriptionLength) {
      return 'Description must be no more than $_maxDescriptionLength characters long';
    }

    // Check for profanity or inappropriate content
    if (_containsInappropriateContent(sanitizedDescription)) {
      return 'Description contains inappropriate content';
    }

    // Check for minimum word count
    final wordCount = sanitizedDescription.split(RegExp(r'\s+')).length;
    if (wordCount < 5) {
      return 'Description must contain at least 5 words';
    }

    return null;
  }

  /// Validates attachments
  static String? _validateAttachments(List<Map<String, dynamic>>? attachments) {
    if (attachments == null) return null;

    if (attachments.length > _maxAttachments) {
      return 'Maximum $_maxAttachments attachments allowed';
    }

    for (final attachment in attachments) {
      final fileName = attachment['name'] as String?;
      final fileSize = attachment['size'] as int?;

      if (fileName == null || fileName.isEmpty) {
        return 'Invalid file name';
      }

      if (fileSize != null && fileSize > _maxAttachmentSizeMB * 1024 * 1024) {
        return 'File "${fileName}" is too large. Maximum size is ${_maxAttachmentSizeMB}MB';
      }

      // Check file extension
      final extension = fileName.split('.').last.toLowerCase();
      final allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'txt'];
      if (!allowedExtensions.contains(extension)) {
        return 'File "${fileName}" has an unsupported format';
      }
    }

    return null;
  }

  /// Checks if text contains inappropriate content
  static bool _containsInappropriateContent(String text) {
    // Basic profanity filter - in production, use a proper content moderation service
    final inappropriateWords = [
      'spam', 'scam', 'fake', 'fraud', 'hate', 'abuse', 'harassment',
      // Add more as needed
    ];

    final lowerText = text.toLowerCase();
    return inappropriateWords.any((word) => lowerText.contains(word));
  }

  /// Gets list of valid departments
  static List<String> _getValidDepartments() {
    return [
      'BS in Accounting Information System',
      'BSBA major in Financial Management',
      'BSBA major in Human Resource Management',
      'BSBA major in Marketing Management',
      'BS in Computer Engineering',
      'BS in Information Technology',
      'BS in Criminology',
      'BS in Psychology',
      'BS in Entrepreneurship',
      'BS in Office Administration',
      'BS in Hospitality Management',
      'BS in Tourism Management',
      'Bachelor of Library and Information Science',
      'Bachelor of Physical Education',
      'Bachelor of Elementary Education',
      'Bachelor of Secondary Education - English',
      'Bachelor of Secondary Education - Filipino',
      'Bachelor of Secondary Education - Mathematics',
      'Bachelor of Secondary Education - Science',
      'Bachelor of Secondary Education - Social Studies',
      'Bachelor of Secondary Education - Values Education',
      'Bachelor of Technology and Livelihood Education',
    ];
  }

  /// Gets list of valid concern types
  static List<String> _getValidConcernTypes() {
    return [
      'academic',
      'administrative',
      'technical',
      'financial',
      'facility',
      'other',
    ];
  }

  /// Gets validation rules for a specific field
  static Map<String, dynamic> getFieldRules(String fieldName) {
    switch (fieldName) {
      case 'subject':
        return {
          'required': true,
          'minLength': _minSubjectLength,
          'maxLength': _maxSubjectLength,
          'helpText': 'Brief summary of your concern',
        };
      case 'department':
        return {
          'required': true,
          'helpText': 'Select the department most relevant to your concern',
        };
      case 'concernType':
        return {
          'required': true,
          'helpText': 'Choose the category that best describes your concern',
        };
      case 'description':
        return {
          'required': true,
          'minLength': _minDescriptionLength,
          'maxLength': _maxDescriptionLength,
          'minWords': 5,
          'helpText': 'Provide detailed information about your concern',
        };
      case 'attachments':
        return {
          'required': false,
          'maxCount': _maxAttachments,
          'maxSizeMB': _maxAttachmentSizeMB,
          'allowedTypes': ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'txt'],
          'helpText': 'Add supporting documents or images',
        };
      default:
        return {};
    }
  }

  /// Sanitizes input text
  static String sanitizeText(String text) {
    return text
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ') // Replace multiple spaces with single space
        .replaceAll(RegExp(r'[<>]'), ''); // Remove potential HTML tags
  }

  /// Formats validation error for display
  static String formatError(String fieldName, String error) {
    return error; // Can be enhanced with field-specific formatting
  }
}
