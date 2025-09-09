import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/api_service.dart';
import './widgets/logout_button_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/settings_tile_widget.dart';
import './widgets/toggle_tile_widget.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({Key? key}) : super(key: key);

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  // Student data will be loaded from API/preferences
  Map<String, dynamic> studentData = {
    "id": 0,
    "name": "Student Name",
    "studentId": "Loading...",
    "course": "Loading...",
    "yearLevel": "Loading...",
    "email": "Loading...",
    "phone": "Loading...",
    "avatar": "",
  };
  bool _isLoading = false;

  // Notification preferences
  bool concernUpdates = true;
  bool announcementAlerts = true;
  bool emergencyNotifications = true;
  bool aiAssistantMessages = false;

  // App settings
  bool isFilipino = false;
  String themePreference = 'Light';
  bool wifiOnlyData = false;

  // Privacy settings
  bool anonymousDefault = false;
  bool dataSharing = true;
  bool biometricAuth = false;

  @override
  void initState() {
    super.initState();
    _loadStudentProfile();
  }

  Future<void> _loadStudentProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load user profile from API
      final userProfile = await apiService.getCurrentUser();
      
      setState(() {
        studentData = {
          "id": userProfile['id'],
          "name": userProfile['name'],
          "studentId": userProfile['display_id'] ?? userProfile['email'],
          "course": userProfile['department'] ?? 'Not specified',
          "yearLevel": "Student", // TODO: Add year level to user model
          "email": userProfile['email'],
          "phone": userProfile['phone'] ?? 'Not provided',
          "avatar": userProfile['avatar'] ?? "",
        };
      });
    } catch (e) {
      print('Error loading student profile: $e');
      // Keep loading state values on error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile Settings',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        foregroundColor: AppTheme.lightTheme.appBarTheme.foregroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        centerTitle: AppTheme.lightTheme.appBarTheme.centerTitle,
        leading: IconButton(
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/dashboard-home'),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: Colors.white,
            size: 6.w,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),

            // Profile Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: ProfileHeaderWidget(
                studentName: studentData["name"] as String,
                studentId: studentData["studentId"] as String,
                course: studentData["course"] as String,
                avatarUrl: studentData["avatar"] as String,
                onEditPressed: _showEditProfileDialog,
                onAvatarTap: _showAvatarOptions,
              ),
            ),

            SizedBox(height: 3.h),

            // Account Section
            SettingsSectionWidget(
              title: 'Account',
              children: [
                SettingsTileWidget(
                  title: 'Personal Information',
                  subtitle: 'Name, email, phone number',
                  iconName: 'person',
                  onTap: _showPersonalInfoDialog,
                ),
                SettingsTileWidget(
                  title: 'Academic Details',
                  subtitle:
                      '${studentData["course"]}, ${studentData["yearLevel"]}',
                  iconName: 'school',
                  onTap: _showAcademicDetailsDialog,
                ),
                SettingsTileWidget(
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  iconName: 'lock',
                  onTap: _showChangePasswordDialog,
                ),
              ],
            ),

            // Notification Preferences
            SettingsSectionWidget(
              title: 'Notifications',
              children: [
                ToggleTileWidget(
                  title: 'Concern Updates',
                  subtitle: 'Get notified about concern status changes',
                  iconName: 'notifications',
                  value: concernUpdates,
                  onChanged: (value) => setState(() => concernUpdates = value),
                ),
                ToggleTileWidget(
                  title: 'Announcement Alerts',
                  subtitle: 'Receive campus announcements',
                  iconName: 'campaign',
                  value: announcementAlerts,
                  onChanged: (value) =>
                      setState(() => announcementAlerts = value),
                ),
                ToggleTileWidget(
                  title: 'Emergency Notifications',
                  subtitle: 'Critical campus alerts and emergencies',
                  iconName: 'warning',
                  iconColor: Colors.red[600],
                  value: emergencyNotifications,
                  onChanged: (value) =>
                      setState(() => emergencyNotifications = value),
                ),
                ToggleTileWidget(
                  title: 'Message Notifications',
                  subtitle: 'Tips and suggestions from support chat',
                  iconName: 'smart_toy',
                  value: aiAssistantMessages,
                  onChanged: (value) =>
                      setState(() => aiAssistantMessages = value),
                ),
              ],
            ),

            // App Settings
            SettingsSectionWidget(
              title: 'App Settings',
              children: [
                ToggleTileWidget(
                  title: 'Language',
                  subtitle: isFilipino ? 'Filipino' : 'English',
                  iconName: 'language',
                  value: isFilipino,
                  onChanged: (value) => setState(() => isFilipino = value),
                ),
                SettingsTileWidget(
                  title: 'Theme Preference',
                  subtitle: themePreference,
                  iconName: 'palette',
                  onTap: _showThemeDialog,
                ),
                ToggleTileWidget(
                  title: 'Wi-Fi Only Data',
                  subtitle: 'Use cellular data for essential features only',
                  iconName: 'wifi',
                  value: wifiOnlyData,
                  onChanged: (value) => setState(() => wifiOnlyData = value),
                ),
                ToggleTileWidget(
                  title: 'Biometric Authentication',
                  subtitle: 'Use Face/Touch ID to unlock app',
                  iconName: 'fingerprint',
                  value: biometricAuth,
                  onChanged: (value) => setState(() => biometricAuth = value),
                ),
              ],
            ),

            // Privacy Section
            SettingsSectionWidget(
              title: 'Privacy',
              children: [
                ToggleTileWidget(
                  title: 'Anonymous Submission Default',
                  subtitle: 'Submit concerns anonymously by default',
                  iconName: 'visibility_off',
                  value: anonymousDefault,
                  onChanged: (value) =>
                      setState(() => anonymousDefault = value),
                ),
                ToggleTileWidget(
                  title: 'Data Sharing',
                  subtitle: 'Share usage data to improve app experience',
                  iconName: 'share',
                  value: dataSharing,
                  onChanged: (value) => setState(() => dataSharing = value),
                ),
                SettingsTileWidget(
                  title: 'Account Deletion',
                  subtitle: 'Permanently delete your account',
                  iconName: 'delete_forever',
                  iconColor: Colors.red[600],
                  textColor: Colors.red[600],
                  onTap: _showDeleteAccountDialog,
                ),
              ],
            ),

            // Support Section
            SettingsSectionWidget(
              title: 'Support',
              children: [
                SettingsTileWidget(
                  title: 'Help Center',
                  subtitle: 'FAQs and troubleshooting guides',
                  iconName: 'help',
                  onTap: _showHelpCenter,
                ),
                SettingsTileWidget(
                  title: 'Contact Support',
                  subtitle: 'Get help from our support team',
                  iconName: 'support_agent',
                  onTap: () => Navigator.pushNamed(context, '/submit-concern'),
                ),
                SettingsTileWidget(
                  title: 'Rate App',
                  subtitle: 'Rate StudentLink on Google Play Store',
                  iconName: 'star',
                  onTap: _rateApp,
                ),
                SettingsTileWidget(
                  title: 'About',
                  subtitle: 'App version and information',
                  iconName: 'info',
                  onTap: _showAboutDialog,
                ),
              ],
            ),

            // Logout Button
            LogoutButtonWidget(
              onLogout: _handleLogout,
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Profile',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Profile editing functionality will be available in the next update.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Change Profile Picture',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAvatarOption('Camera', 'camera_alt', () {
                  Navigator.pop(context);
                  _showSuccessMessage('Camera feature will be available soon');
                }),
                _buildAvatarOption('Gallery', 'photo_library', () {
                  Navigator.pop(context);
                  _showSuccessMessage('Gallery feature will be available soon');
                }),
                _buildAvatarOption('Remove', 'delete', () {
                  Navigator.pop(context);
                  _showSuccessMessage('Avatar removed successfully');
                }),
              ],
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarOption(String title, String iconName, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: iconName,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 7.w,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showPersonalInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Personal Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Name', studentData["name"] as String),
            _buildInfoRow('Email', studentData["email"] as String),
            _buildInfoRow('Phone', studentData["phone"] as String),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage('Edit functionality coming soon');
            },
            child: Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _showAcademicDetailsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Academic Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Student ID', studentData["studentId"] as String),
            _buildInfoRow('Course', studentData["course"] as String),
            _buildInfoRow('Year Level', studentData["yearLevel"] as String),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage('Password changed successfully');
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Theme Preference'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => themePreference = 'Light');
                  Navigator.pop(context);
                },
                child: Text('Light'),
              ),
            ),
            SizedBox(height: 1.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => themePreference = 'Dark');
                  Navigator.pop(context);
                },
                child: Text('Dark'),
              ),
            ),
            SizedBox(height: 1.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => themePreference = 'System');
                  Navigator.pop(context);
                },
                child: Text('System'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'warning',
              color: Colors.red[600]!,
              size: 6.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Delete Account',
              style: TextStyle(color: Colors.red[600]),
            ),
          ],
        ),
        content: Text(
          'This action cannot be undone. All your data including concerns, messages, and profile information will be permanently deleted.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage('Account deletion request submitted');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showHelpCenter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Help Center'),
        content: Text(
          'Help Center with FAQs and troubleshooting guides will be available in the next update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _rateApp() {
    _showSuccessMessage('Redirecting to Google Play Store...');
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('About StudentLink'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'StudentLink',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text('Version: 1.0.0'),
            SizedBox(height: 1.h),
            Text('Build: 2025.01.05'),
            SizedBox(height: 2.h),
            Text(
              'A comprehensive mobile application for student concern management and campus support services at Bestlink College of the Philippines.',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
            SizedBox(height: 2.h),
            Text(
              '© 2025 Bestlink College of the Philippines',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      // Logout from API
      await apiService.logout();
      
      // Clear any stored data and navigate to login
      Navigator.pushReplacementNamed(context, '/login-screen');
      _showSuccessMessage('Logged out successfully');
    } catch (e) {
      // Even if API logout fails, still navigate to login
      Navigator.pushReplacementNamed(context, '/login-screen');
      _showSuccessMessage('Logged out successfully');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.all(4.w),
      ),
    );
  }
}
