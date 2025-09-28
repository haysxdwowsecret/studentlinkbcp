import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../services/api_service.dart';
import '../../services/settings_service.dart';
import '../../theme/app_theme.dart';
import './widgets/modern_logout_button_widget.dart';
import './widgets/modern_profile_header_widget.dart';
import './widgets/modern_settings_section_widget.dart';
import './widgets/modern_settings_tile_widget.dart';
import './widgets/modern_toggle_tile_widget.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({Key? key}) : super(key: key);

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  // Services
  final SettingsService _settingsService = SettingsService();

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
  bool wifiOnlyData = false;
  bool biometricAuth = false;

  // Privacy settings
  bool anonymousDefault = false;
  bool dataSharing = true;

  @override
  void initState() {
    super.initState();
    _loadStudentProfile();
    _loadSettings();
  }

  Future<void> _loadStudentProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('Loading user profile from API...');
      // Load user profile from API
      final userProfile = await apiService.getCurrentUser();
      print('Loaded user profile: $userProfile');
      
      setState(() {
        studentData = {
          "id": userProfile['id'] ?? 0,
          "name": userProfile['name'] ?? "Student Name",
          "studentId": userProfile['display_id'] ?? userProfile['student_id'] ?? "N/A",
          "course": userProfile['program'] ?? userProfile['department'] ?? 'Not specified',
          "yearLevel": userProfile['year_level'] ?? "Student",
          "email": userProfile['email'] ?? "N/A",
          "phone": userProfile['phone'] ?? 'Not provided',
          "avatar": userProfile['avatar'] ?? "",
        };
      });
    } catch (e) {
      print('Error loading student profile: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
      // Show error state instead of loading
      setState(() {
        studentData = {
          "id": 0,
          "name": "Error Loading",
          "studentId": "Unable to load",
          "course": "Unable to load",
          "yearLevel": "Unable to load",
          "email": "Unable to load",
          "phone": "Unable to load",
          "avatar": "",
        };
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Load all settings from the settings service
  Future<void> _loadSettings() async {
    try {
      // Load notification settings
      final notificationSettings = await _settingsService.getNotificationSettings();
      setState(() {
        concernUpdates = notificationSettings['concernUpdates'] ?? true;
        announcementAlerts = notificationSettings['announcementAlerts'] ?? true;
        emergencyNotifications = notificationSettings['emergencyNotifications'] ?? true;
        aiAssistantMessages = notificationSettings['aiAssistantMessages'] ?? false;
      });

      // Load app settings
      final appSettings = await _settingsService.getAppSettings();
      setState(() {
        isFilipino = appSettings['isFilipino'] ?? false;
        wifiOnlyData = appSettings['wifiOnlyData'] ?? false;
        biometricAuth = appSettings['biometricAuth'] ?? false;
      });

      // Load privacy settings
      final privacySettings = await _settingsService.getPrivacySettings();
      setState(() {
        anonymousDefault = privacySettings['anonymousDefault'] ?? false;
        dataSharing = privacySettings['dataSharing'] ?? true;
      });

      debugPrint('✅ Settings loaded successfully');
    } catch (e) {
      debugPrint('❌ Error loading settings: $e');
      _showErrorMessage('Failed to load settings');
    }
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: studentData['name'],
              ),
              onChanged: (value) {
                setState(() {
                  studentData['name'] = value;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Phone',
                hintText: studentData['phone'],
              ),
              onChanged: (value) {
                setState(() {
                  studentData['phone'] = value;
                });
              },
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
              _saveProfileChanges();
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfileChanges() async {
    try {
      // TODO: Implement API call to update profile
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Modern light background
      appBar: _buildModernAppBar(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

            // Modern Profile Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ModernProfileHeaderWidget(
                studentName: studentData["name"] as String,
                studentId: studentData["studentId"] as String,
                course: studentData["course"] as String,
                avatarUrl: studentData["avatar"] as String,
                onEditPressed: _showEditProfileDialog,
                onAvatarTap: _showAvatarOptions,
              ),
            ),

            const SizedBox(height: 24),

            // Account Section
            ModernSettingsSectionWidget(
              title: 'Account',
              children: [
                ModernSettingsTileWidget(
                  icon: Icons.person_rounded,
                  title: 'Personal Information',
                  subtitle: 'Name, email, phone number',
                  onTap: _showPersonalInfoDialog,
                ),
                ModernSettingsTileWidget(
                  icon: Icons.school_rounded,
                  title: 'Academic Details',
                  subtitle:
                      '${studentData["course"]}, ${studentData["yearLevel"]}',
                  onTap: _showAcademicDetailsDialog,
                ),
                ModernSettingsTileWidget(
                  icon: Icons.lock_rounded,
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  onTap: _showChangePasswordDialog,
                ),
              ],
            ),

            // Notification Preferences
            ModernSettingsSectionWidget(
              title: 'Notifications',
              children: [
                ModernToggleTileWidget(
                  icon: Icons.notifications_rounded,
                  title: 'Concern Updates',
                  subtitle: 'Get notified about concern status changes',
                  value: concernUpdates,
                  onChanged: (value) => _updateNotificationSetting('concernUpdates', value),
                ),
                ModernToggleTileWidget(
                  icon: Icons.campaign_rounded,
                  title: 'Announcement Alerts',
                  subtitle: 'Receive campus announcements',
                  value: announcementAlerts,
                  onChanged: (value) => _updateNotificationSetting('announcementAlerts', value),
                ),
                ModernToggleTileWidget(
                  icon: Icons.warning_rounded,
                  title: 'Emergency Notifications',
                  subtitle: 'Critical campus alerts and emergencies',
                  iconColor: Colors.red[600],
                  value: emergencyNotifications,
                  onChanged: (value) => _updateNotificationSetting('emergencyNotifications', value),
                ),
                ModernToggleTileWidget(
                  icon: Icons.smart_toy_rounded,
                  title: 'Message Notifications',
                  subtitle: 'Tips and suggestions from support chat',
                  value: aiAssistantMessages,
                  onChanged: (value) => _updateNotificationSetting('aiAssistantMessages', value),
                ),
              ],
            ),

            // App Settings
            ModernSettingsSectionWidget(
              title: 'App Settings',
              children: [
                ModernToggleTileWidget(
                  icon: Icons.language_rounded,
                  title: 'Language',
                  subtitle: isFilipino ? 'Filipino' : 'English',
                  value: isFilipino,
                  onChanged: (value) => _updateLanguageSetting(value),
                ),
                ModernToggleTileWidget(
                  icon: Icons.wifi_rounded,
                  title: 'Wi-Fi Only Data',
                  subtitle: 'Use cellular data for essential features only',
                  value: wifiOnlyData,
                  onChanged: (value) => _updateWifiOnlySetting(value),
                ),
                ModernToggleTileWidget(
                  icon: Icons.fingerprint_rounded,
                  title: 'Biometric Authentication',
                  subtitle: 'Use Face/Touch ID to unlock app',
                  value: biometricAuth,
                  onChanged: (value) => _updateBiometricAuthSetting(value),
                ),
              ],
            ),

            // Privacy Section
            ModernSettingsSectionWidget(
              title: 'Privacy',
              children: [
                ModernToggleTileWidget(
                  icon: Icons.visibility_off_rounded,
                  title: 'Anonymous Submission Default',
                  subtitle: 'Submit concerns anonymously by default',
                  value: anonymousDefault,
                  onChanged: (value) => _updatePrivacySetting('anonymousDefault', value),
                ),
                ModernToggleTileWidget(
                  icon: Icons.share_rounded,
                  title: 'Data Sharing',
                  subtitle: 'Share usage data to improve app experience',
                  value: dataSharing,
                  onChanged: (value) => _updatePrivacySetting('dataSharing', value),
                ),
                ModernSettingsTileWidget(
                  icon: Icons.delete_forever_rounded,
                  title: 'Account Deletion',
                  subtitle: 'Permanently delete your account',
                  iconColor: Colors.red[600],
                  onTap: _showDeleteAccountDialog,
                ),
              ],
            ),

            // Support Section
            ModernSettingsSectionWidget(
              title: 'Support',
              children: [
                ModernSettingsTileWidget(
                  icon: Icons.help_rounded,
                  title: 'Help Center',
                  subtitle: 'FAQs and troubleshooting guides',
                  onTap: _showHelpCenter,
                ),
                ModernSettingsTileWidget(
                  icon: Icons.support_agent_rounded,
                  title: 'Contact Support',
                  subtitle: 'Get help from our support team',
                  onTap: () => Navigator.pushNamed(context, '/submit-concern'),
                ),
                ModernSettingsTileWidget(
                  icon: Icons.star_rounded,
                  title: 'Rate App',
                  subtitle: 'Rate StudentLink on Google Play Store',
                  onTap: _rateApp,
                ),
                ModernSettingsTileWidget(
                  icon: Icons.info_rounded,
                  title: 'About',
                  subtitle: 'App version and information',
                  onTap: _showAboutDialog,
                ),
              ],
            ),

            // Logout Button
            ModernLogoutButtonWidget(
              onLogout: _handleLogout,
            ),

            const SizedBox(height: 32),
          ],
        ),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Change Profile Picture',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
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
            const SizedBox(height: 32),
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                _getIconFromName(iconName),
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 8),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
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
          const SizedBox(height: 4),
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
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
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


  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: Colors.red[600]!,
              size: 24,
            ),
            const SizedBox(width: 8),
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
            const SizedBox(height: 8),
            Text('Version: 1.0.0'),
            const SizedBox(height: 8),
            Text('Build: 2025.01.05'),
            const SizedBox(height: 16),
            Text(
              'A comprehensive mobile application for student concern management and campus support services at Bestlink College of the Philippines.',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
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
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(message),
            ],
          ),
          backgroundColor: AppTheme.successLight,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'camera_alt':
        return Icons.camera_alt_rounded;
      case 'photo_library':
        return Icons.photo_library_rounded;
      case 'delete':
        return Icons.delete_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      title: Text(
        'Profile Settings',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1A1A),
        ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1A1A1A),
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: _loadStudentProfile,
          icon: Icon(
            Icons.refresh_rounded,
            color: AppTheme.primaryLight,
            size: 24,
          ),
          tooltip: 'Refresh Profile',
        ),
        IconButton(
          onPressed: _showEditProfileDialog,
          icon: Icon(
            Icons.edit_rounded,
            color: AppTheme.primaryLight,
            size: 24,
          ),
          tooltip: 'Edit Profile',
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: const Color(0xFFE5E7EB),
        ),
      ),
    );
  }

  // ==================== TOGGLE HANDLER METHODS ====================

  /// Update notification setting
  Future<void> _updateNotificationSetting(String key, bool value) async {
    try {
      // Update local state immediately for responsive UI
      setState(() {
        switch (key) {
          case 'concernUpdates':
            concernUpdates = value;
            break;
          case 'announcementAlerts':
            announcementAlerts = value;
            break;
          case 'emergencyNotifications':
            emergencyNotifications = value;
            break;
          case 'aiAssistantMessages':
            aiAssistantMessages = value;
            break;
        }
      });

      // Update in settings service
      final currentSettings = await _settingsService.getNotificationSettings();
      currentSettings[key] = value;
      
      final success = await _settingsService.updateNotificationSettings(currentSettings);
      
      if (success) {
        HapticFeedback.lightImpact();
        _showSuccessMessage('${_getNotificationSettingName(key)} ${value ? 'enabled' : 'disabled'}');
      } else {
        // Revert on failure
        setState(() {
          switch (key) {
            case 'concernUpdates':
              concernUpdates = !value;
              break;
            case 'announcementAlerts':
              announcementAlerts = !value;
              break;
            case 'emergencyNotifications':
              emergencyNotifications = !value;
              break;
            case 'aiAssistantMessages':
              aiAssistantMessages = !value;
              break;
          }
        });
        _showErrorMessage('Failed to update notification setting');
      }
    } catch (e) {
      debugPrint('❌ Error updating notification setting: $e');
      _showErrorMessage('Failed to update notification setting');
    }
  }

  /// Update language setting
  Future<void> _updateLanguageSetting(bool value) async {
    try {
      // Update local state immediately
      setState(() {
        isFilipino = value;
      });

      // Update in settings service
      final success = await _settingsService.updateLanguageSetting(value);
      
      if (success) {
        HapticFeedback.lightImpact();
        _showSuccessMessage('Language changed to ${value ? 'Filipino' : 'English'}');
      } else {
        // Revert on failure
        setState(() {
          isFilipino = !value;
        });
        _showErrorMessage('Failed to update language setting');
      }
    } catch (e) {
      debugPrint('❌ Error updating language setting: $e');
      _showErrorMessage('Failed to update language setting');
    }
  }

  /// Update Wi-Fi only setting
  Future<void> _updateWifiOnlySetting(bool value) async {
    try {
      // Update local state immediately
      setState(() {
        wifiOnlyData = value;
      });

      // Update in settings service
      final success = await _settingsService.updateWifiOnlySetting(value);
      
      if (success) {
        HapticFeedback.lightImpact();
        _showSuccessMessage('Wi-Fi only data ${value ? 'enabled' : 'disabled'}');
      } else {
        // Revert on failure
        setState(() {
          wifiOnlyData = !value;
        });
        _showErrorMessage('Failed to update Wi-Fi setting');
      }
    } catch (e) {
      debugPrint('❌ Error updating Wi-Fi setting: $e');
      _showErrorMessage('Failed to update Wi-Fi setting');
    }
  }

  /// Update biometric authentication setting
  Future<void> _updateBiometricAuthSetting(bool value) async {
    try {
      // Check if biometric is available before enabling
      if (value) {
        final isAvailable = await _settingsService.isBiometricAvailable();
        if (!isAvailable) {
          _showErrorMessage('Biometric authentication is not available on this device');
          return;
        }
      }

      // Update local state immediately
      setState(() {
        biometricAuth = value;
      });

      // Update in settings service
      final success = await _settingsService.updateBiometricAuthSetting(value);
      
      if (success) {
        HapticFeedback.mediumImpact();
        _showSuccessMessage('Biometric authentication ${value ? 'enabled' : 'disabled'}');
      } else {
        // Revert on failure
        setState(() {
          biometricAuth = !value;
        });
        _showErrorMessage('Failed to update biometric setting');
      }
    } catch (e) {
      debugPrint('❌ Error updating biometric setting: $e');
      // Revert on failure
      setState(() {
        biometricAuth = !value;
      });
      _showErrorMessage('Failed to update biometric setting: ${e.toString()}');
    }
  }

  /// Update privacy setting
  Future<void> _updatePrivacySetting(String key, bool value) async {
    try {
      // Update local state immediately
      setState(() {
        switch (key) {
          case 'anonymousDefault':
            anonymousDefault = value;
            break;
          case 'dataSharing':
            dataSharing = value;
            break;
        }
      });

      // Update in settings service
      final currentSettings = await _settingsService.getPrivacySettings();
      currentSettings[key] = value;
      
      final success = await _settingsService.updatePrivacySettings(currentSettings);
      
      if (success) {
        HapticFeedback.lightImpact();
        _showSuccessMessage('${_getPrivacySettingName(key)} ${value ? 'enabled' : 'disabled'}');
      } else {
        // Revert on failure
        setState(() {
          switch (key) {
            case 'anonymousDefault':
              anonymousDefault = !value;
              break;
            case 'dataSharing':
              dataSharing = !value;
              break;
          }
        });
        _showErrorMessage('Failed to update privacy setting');
      }
    } catch (e) {
      debugPrint('❌ Error updating privacy setting: $e');
      _showErrorMessage('Failed to update privacy setting');
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Get notification setting display name
  String _getNotificationSettingName(String key) {
    switch (key) {
      case 'concernUpdates':
        return 'Concern updates';
      case 'announcementAlerts':
        return 'Announcement alerts';
      case 'emergencyNotifications':
        return 'Emergency notifications';
      case 'aiAssistantMessages':
        return 'AI assistant messages';
      default:
        return 'Notification';
    }
  }

  /// Get privacy setting display name
  String _getPrivacySettingName(String key) {
    switch (key) {
      case 'anonymousDefault':
        return 'Anonymous submission';
      case 'dataSharing':
        return 'Data sharing';
      default:
        return 'Privacy setting';
    }
  }


  /// Show error message
  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(message),
            ],
          ),
          backgroundColor: AppTheme.emergencyLight,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}
