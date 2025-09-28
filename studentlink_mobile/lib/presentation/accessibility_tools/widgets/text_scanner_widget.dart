import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../core/app_export.dart';
import '../../../services/ml_kit_service.dart';

class TextScannerWidget extends StatefulWidget {
  final VoidCallback onPermissionRequest;

  const TextScannerWidget({
    Key? key,
    required this.onPermissionRequest,
  }) : super(key: key);

  @override
  State<TextScannerWidget> createState() => _TextScannerWidgetState();
}

class _TextScannerWidgetState extends State<TextScannerWidget> {
  final MLKitService _mlKitService = MLKitService();
  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isProcessing = false;
  String _extractedText = '';
  File? _selectedImage;

  Future<void> _pickImageFromCamera() async {
    try {
      widget.onPermissionRequest();
      
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        await _extractTextFromImage(image.path);
      }
    } catch (e) {
      _showErrorDialog('Failed to capture image: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        await _extractTextFromImage(image.path);
      }
    } catch (e) {
      _showErrorDialog('Failed to pick image: $e');
    }
  }

  Future<void> _extractTextFromImage(String imagePath) async {
    setState(() {
      _isProcessing = true;
      _extractedText = '';
    });

    try {
      final result = await _mlKitService.extractTextFromImage(imagePath);
      
      setState(() {
        _extractedText = result;
        _isProcessing = false;
      });

      if (result.isEmpty) {
        _showInfoDialog('No text found in the image. Please try with a clearer image.');
      } else {
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorDialog('Failed to extract text: $e');
    }
  }

  void _copyToClipboard() {
    if (_extractedText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _extractedText));
      HapticFeedback.lightImpact();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 2.w),
              const Text('Text copied to clipboard'),
            ],
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _clearText() {
    setState(() {
      _extractedText = '';
      _selectedImage = null;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Information'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.text_fields,
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 24.sp,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Text Scanner',
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Extract text from images using your camera or gallery. Perfect for reading documents, signs, or any printed text.',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 4.h),

          // Image Selection Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _pickImageFromCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                    foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: 3.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _pickImageFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
                    foregroundColor: AppTheme.lightTheme.colorScheme.onSecondary,
                    padding: EdgeInsets.symmetric(vertical: 3.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 4.h),

          // Selected Image Preview
          if (_selectedImage != null) ...[
            Card(
              elevation: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Text(
                      'Selected Image',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 30.h,
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
            SizedBox(height: 2.h),
          ],

          // Processing Indicator
          if (_isProcessing) ...[
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(6.w),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Extracting text from image...',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 2.h),
          ],

          // Extracted Text
          if (_extractedText.isNotEmpty) ...[
            Card(
              elevation: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Extracted Text',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _copyToClipboard,
                              icon: const Icon(Icons.copy),
                              tooltip: 'Copy to clipboard',
                            ),
                            IconButton(
                              onPressed: _clearText,
                              icon: const Icon(Icons.clear),
                              tooltip: 'Clear text',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: SelectableText(
                      _extractedText,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ],

          // Tips
          Card(
            elevation: 1,
            color: AppTheme.lightTheme.colorScheme.primaryContainer,
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
                        size: 20.sp,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Tips for Better Results',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '• Ensure good lighting\n• Keep the text straight and clear\n• Avoid shadows and reflections\n• Hold the camera steady',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
