import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class Step2PersonalInfoWidget extends StatefulWidget {
  final Function(String? firstName, String? middleName, String? lastName, String? suffix, String? course, String? yearLevel) onDataChanged;

  const Step2PersonalInfoWidget({
    Key? key,
    required this.onDataChanged,
  }) : super(key: key);

  @override
  State<Step2PersonalInfoWidget> createState() => _Step2PersonalInfoWidgetState();
}

class _Step2PersonalInfoWidgetState extends State<Step2PersonalInfoWidget> {
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _suffixController = TextEditingController();
  
  String? _selectedProgram;
  String? _selectedYearLevel;
  
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 4.5.w,
            fontWeight: FontWeight.bold,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        
        SizedBox(height: 1.5.h),
        
        Text(
          'Please provide your personal information as it appears on your official documents.',
          style: TextStyle(
            fontSize: 3.2.w,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
        
        SizedBox(height: 1.5.h),
          
          // Form fields
          _buildTextField(
            controller: _firstNameController,
            label: 'First Name',
            hint: 'Enter your first name',
            icon: Icons.person,
            isRequired: true,
          ),
          
        SizedBox(height: 1.5.h),
        
        _buildTextField(
          controller: _middleNameController,
          label: 'Middle Name',
          hint: 'Enter your middle name (optional)',
          icon: Icons.person_outline,
          isRequired: false,
        ),
        
        SizedBox(height: 1.5.h),
        
        _buildTextField(
          controller: _lastNameController,
          label: 'Last Name',
          hint: 'Enter your last name',
          icon: Icons.person,
          isRequired: true,
        ),
        
        SizedBox(height: 1.5.h),
        
        _buildTextField(
          controller: _suffixController,
          label: 'Suffix',
          hint: 'Jr., Sr., III, etc. (optional)',
          icon: Icons.title,
          isRequired: false,
        ),
        
        SizedBox(height: 1.5.h),
        
        _buildProgramDropdown(),
        
        SizedBox(height: 1.5.h),
        
        _buildYearLevelDropdown(),
        
        SizedBox(height: 1.5.h),
          
          // Information note
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade600,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Important Notes',
                        style: TextStyle(
                          fontSize: 3.w,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        '• Use your legal name as it appears on official documents\n'
                        '• Middle name is optional but recommended\n'
                        '• Suffix (Jr., Sr., III, etc.) is optional\n'
                        '• Program and year level are required for enrollment\n'
                        '• This information will be used for official records',
                        style: TextStyle(
                          fontSize: 3.w,
                          color: Colors.blue.shade700,
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

  Widget _buildTextField({
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
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 3.5.w,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 3.w,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        
        SizedBox(height: 1.h),
        
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 3.h,
            ),
          ),
          style: TextStyle(
            fontSize: 3.5.w,
            color: Colors.grey.shade800,
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

  Widget _buildProgramDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.school,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Program',
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
                style: TextStyle(
                  fontSize: 3.w,
                  color: Colors.grey.shade800,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildYearLevelDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.grade,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Year Level',
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
                style: TextStyle(
                  fontSize: 3.w,
                  color: Colors.grey.shade800,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
