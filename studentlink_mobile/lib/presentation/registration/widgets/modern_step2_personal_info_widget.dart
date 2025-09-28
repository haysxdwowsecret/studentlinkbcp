import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/modern_dropdown_widget.dart';

/// Modern step 2 widget for personal information
class ModernStep2PersonalInfoWidget extends StatefulWidget {
  final Function(String? firstName, String? middleName, String? lastName, String? suffix, String? course, String? yearLevel, DateTime? birthday, String? civilStatus) onDataChanged;

  const ModernStep2PersonalInfoWidget({
    Key? key,
    required this.onDataChanged,
  }) : super(key: key);

  @override
  State<ModernStep2PersonalInfoWidget> createState() => _ModernStep2PersonalInfoWidgetState();
}

class _ModernStep2PersonalInfoWidgetState extends State<ModernStep2PersonalInfoWidget> {
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _suffixController = TextEditingController();
  
  String? _selectedProgram;
  String? _selectedYearLevel;
  DateTime? _selectedBirthday;
  String? _selectedCivilStatus;
  
  final List<String> _programs = [
    'BSAIS',
    'BSBA-FM',
    'BSBA-HRM',
    'BSBA-MM',
    'BSCpE',
    'BSCrim',
    'BSEntrep',
    'BSHM',
    'BSIT',
    'BSOA',
    'BSPsych',
    'BSTM',
    'BLIS',
    'BPED',
    'BEED',
    'BSED-English',
    'BSED-Filipino',
    'BSED-Math',
    'BSED-Science',
    'BSED-Social Studies',
    'BSED-Values',
    'BTLED',
  ];
  
  final List<String> _yearLevels = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
  ];
  
  final List<String> _civilStatuses = [
    'Single',
    'Married',
    'Widowed',
    'Divorced',
    'Separated',
  ];

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_onDataChanged);
    _middleNameController.addListener(_onDataChanged);
    _lastNameController.addListener(_onDataChanged);
    _suffixController.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _suffixController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    widget.onDataChanged(
      _firstNameController.text.trim().isEmpty ? null : _firstNameController.text.trim(),
      _middleNameController.text.trim().isEmpty ? null : _middleNameController.text.trim(),
      _lastNameController.text.trim().isEmpty ? null : _lastNameController.text.trim(),
      _suffixController.text.trim().isEmpty ? null : _suffixController.text.trim(),
      _selectedProgram,
      _selectedYearLevel,
      _selectedBirthday,
      _selectedCivilStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Modern header
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
                      Icons.person_rounded,
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
                          'Personal Information',
                          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                            color: const Color(0xFF1A1A1A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tell us about yourself',
                          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF6B7280),
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
        
        // Description
        Text(
          'Please provide your personal information as it appears on your official documents.',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
        
        const SizedBox(height: 24),
          
        // Form fields
        _buildModernTextField(
          controller: _firstNameController,
          label: 'First Name',
          hint: 'Enter your first name',
          icon: Icons.person_rounded,
          isRequired: true,
        ),
        
        const SizedBox(height: 16),
        
        _buildModernTextField(
          controller: _middleNameController,
          label: 'Middle Name',
          hint: 'Enter your middle name (optional)',
          icon: Icons.person_outline_rounded,
          isRequired: false,
        ),
        
        const SizedBox(height: 16),
        
        _buildModernTextField(
          controller: _lastNameController,
          label: 'Last Name',
          hint: 'Enter your last name',
          icon: Icons.person_rounded,
          isRequired: true,
        ),
        
        const SizedBox(height: 16),
        
        _buildModernTextField(
          controller: _suffixController,
          label: 'Suffix',
          hint: 'Jr., Sr., III, etc. (optional)',
          icon: Icons.title_rounded,
          isRequired: false,
        ),
        
        const SizedBox(height: 16),
        
        _buildModernProgramDropdown(),
        
        const SizedBox(height: 16),
        
        _buildModernYearLevelDropdown(),
        
        const SizedBox(height: 16),
        
        _buildModernBirthdayField(),
        
        const SizedBox(height: 16),
        
        _buildModernCivilStatusDropdown(),
        
        const SizedBox(height: 24),
          
        // Information note
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDBEAFE)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: const Color(0xFF3B82F6),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Important Notes',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E40AF),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Use your legal name as it appears on official documents\n'
                      '• Middle name is optional but recommended\n'
                      '• Suffix (Jr., Sr., III, etc.) is optional\n'
                      '• Program and year level are required for enrollment\n'
                      '• This information will be used for official records',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF1E40AF),
                        height: 1.4,
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

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isRequired,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
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
        
        const SizedBox(height: 8),
        
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
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
              borderSide: const BorderSide(color: Color(0xFFFECACA)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF1A1A1A),
          ),
          textCapitalization: TextCapitalization.words,
          validator: isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildModernProgramDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.school_rounded,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Program',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            Text(
              ' *',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        ModernDropdownWidget<String>(
          value: _selectedProgram,
          onChanged: (String? newValue) {
            setState(() {
              _selectedProgram = newValue;
              _onDataChanged();
            });
          },
          hint: 'Select your program',
          prefixIcon: Icon(
            Icons.school_outlined,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          items: _programs.map((String program) {
            return DropdownMenuItem<String>(
              value: program,
              child: Text(
                program,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildModernYearLevelDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.grade_rounded,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Year Level',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            Text(
              ' *',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        ModernDropdownWidget<String>(
          value: _selectedYearLevel,
          onChanged: (String? newValue) {
            setState(() {
              _selectedYearLevel = newValue;
              _onDataChanged();
            });
          },
          hint: 'Select your year level',
          prefixIcon: Icon(
            Icons.grade_outlined,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          items: _yearLevels.map((String yearLevel) {
            return DropdownMenuItem<String>(
              value: yearLevel,
              child: Text(
                yearLevel,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildModernBirthdayField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.cake_rounded,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Birthday',
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
        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _selectedBirthday ?? DateTime(2000),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: AppTheme.lightTheme.colorScheme,
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null && picked != _selectedBirthday) {
              setState(() {
                _selectedBirthday = picked;
                _onDataChanged();
              });
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedBirthday != null
                        ? '${_selectedBirthday!.day}/${_selectedBirthday!.month}/${_selectedBirthday!.year}'
                        : 'Select your birthday',
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: _selectedBirthday != null
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today_rounded,
                  color: const Color(0xFF6B7280),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernCivilStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.family_restroom_rounded,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Civil Status',
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
        DropdownButtonFormField<String>(
          value: _selectedCivilStatus,
          onChanged: (String? newValue) {
            setState(() {
              _selectedCivilStatus = newValue;
              _onDataChanged();
            });
          },
          decoration: InputDecoration(
            hintText: 'Select your civil status',
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            prefixIcon: Icon(
              Icons.family_restroom_rounded,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          items: _civilStatuses.map((String civilStatus) {
            return DropdownMenuItem<String>(
              value: civilStatus.toLowerCase(),
              child: Text(
                civilStatus,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
