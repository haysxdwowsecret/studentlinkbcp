import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/app_export.dart';
import '../../services/conditional_ml_service.dart';
import 'widgets/text_scanner_widget.dart';
import 'widgets/translation_widget.dart';
import 'widgets/accessibility_menu_widget.dart';

class AccessibilityToolsScreen extends StatefulWidget {
  const AccessibilityToolsScreen({Key? key}) : super(key: key);

  @override
  State<AccessibilityToolsScreen> createState() => _AccessibilityToolsScreenState();
}

class _AccessibilityToolsScreenState extends State<AccessibilityToolsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ConditionalMLService _mlService = ConditionalMLService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeMLService();
  }

  void _initializeMLService() async {
    try {
      // Initialize the conditional ML service
      await _mlService.loadMLKitFeatures();
      print('✅ Conditional ML Service initialized successfully');
    } catch (e) {
      print('❌ Error initializing ML Service: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      _showPermissionDialog('Camera permission is required to scan text from images.');
    }
  }


  void _showPermissionDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Accessibility Tools',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onBackground,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.lightTheme.colorScheme.onPrimary,
          labelColor: AppTheme.lightTheme.colorScheme.onPrimary,
          unselectedLabelColor: AppTheme.lightTheme.colorScheme.onPrimary.withOpacity(0.7),
          labelStyle: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.text_fields),
              text: 'Text Scanner',
            ),
            Tab(
              icon: Icon(Icons.translate),
              text: 'Translation',
            ),
            Tab(
              icon: Icon(Icons.accessibility),
              text: 'Tools',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TextScannerWidget(
            onPermissionRequest: _requestCameraPermission,
          ),
          const TranslationWidget(),
          const AccessibilityMenuWidget(),
        ],
      ),
    );
  }
}
