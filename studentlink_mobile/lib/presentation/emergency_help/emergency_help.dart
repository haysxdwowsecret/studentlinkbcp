import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_export.dart';
import '../../services/api_service.dart';
import './widgets/emergency_contact_card_widget.dart';
import './widgets/emergency_protocols_widget.dart';
import './widgets/location_info_widget.dart';

class EmergencyHelp extends StatefulWidget {
  const EmergencyHelp({Key? key}) : super(key: key);

  @override
  State<EmergencyHelp> createState() => _EmergencyHelpState();
}

class _EmergencyHelpState extends State<EmergencyHelp> {
  // Real data loaded from API
  List<Map<String, dynamic>> _emergencyServices = [];
  List<Map<String, dynamic>> _emergencyProtocols = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEmergencyData();
  }

  Future<void> _loadEmergencyData() async {
    try {
      // Load emergency contacts and protocols from API
      final contacts = await apiService.getEmergencyContacts();
      final protocols = await apiService.getEmergencyProtocols();
      
      setState(() {
        _emergencyServices = contacts;
        _emergencyProtocols = protocols;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load emergency data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            SizedBox(height: 16),
            Text(
              'Error Loading Emergency Data',
              style: AppTheme.lightTheme.textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: AppTheme.lightTheme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEmergencyData,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: CustomScrollView(
        slivers: [
          // Emergency Hotline Header
          SliverToBoxAdapter(
            child: _buildEmergencyHeader(),
          ),

          // Emergency Services
          SliverToBoxAdapter(
            child: _buildSectionHeader('Emergency Services'),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final service = _emergencyServices[index];
                return EmergencyContactCardWidget(
                  service: service,
                  onCallTap: () => _makeEmergencyCall(service['contact']),
                  onLocationTap: () => _showLocationDetails(service),
                );
              },
              childCount: _emergencyServices.length,
            ),
          ),

          // Emergency Protocols
          SliverToBoxAdapter(
            child: _buildSectionHeader('Emergency Protocols'),
          ),

          SliverToBoxAdapter(
            child: EmergencyProtocolsWidget(
              protocols: _emergencyProtocols,
            ),
          ),

          // Bottom spacing
          SliverToBoxAdapter(
            child: SizedBox(height: 8.h),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 2,
      leading: IconButton(
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: Colors.white,
          size: 24,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Emergency Help',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: EdgeInsets.only(right: 4.w),
          child: TextButton(
            onPressed: () => _makeEmergencyCall('911'),
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.emergencyLight,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            ),
            child: Text(
              '911',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyHeader() {
    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.emergencyLight,
            AppTheme.emergencyLight.withAlpha(204),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'emergency',
            color: Colors.white,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'Emergency Hotline',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 1.h),
          GestureDetector(
            onTap: () => _makeEmergencyCall('(02) 8000-0000'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withAlpha(77),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'call',
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    '(02) 8000-0000',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Available 24/7 for campus emergencies',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withAlpha(230),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 2.h),
      child: Text(
        title,
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    // Reload emergency data from API
    await _loadEmergencyData();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Emergency data refreshed'),
        backgroundColor: AppTheme.successLight,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _makeEmergencyCall(String phoneNumber) {
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'call',
              color: AppTheme.emergencyLight,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Emergency Call',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to call $phoneNumber?',
          style: AppTheme.lightTheme.textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _launchPhone(phoneNumber);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.emergencyLight,
              foregroundColor: Colors.white,
            ),
            child: Text('Call Now'),
          ),
        ],
      ),
    );
  }

  void _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorMessage('Could not launch phone dialer');
      }
    } catch (e) {
      _showErrorMessage('Error making call: $e');
    }
  }

  void _showLocationDetails(Map<String, dynamic> service) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => LocationInfoWidget(service: service),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.emergencyLight,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
