import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/api_service.dart';
import '../my_concerns/my_concerns.dart';
import '../announcements/announcements.dart';
import '../profile_settings/profile_settings.dart';
import './widgets/announcements_feed.dart';
import './widgets/dashboard_header.dart';
import './widgets/emergency_help_card.dart';
import './widgets/quick_actions_card.dart';
import './widgets/recent_concerns_card.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({Key? key}) : super(key: key);

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  int _currentIndex = 0;

  // Data will be loaded from API
  List<Map<String, dynamic>> _recentConcerns = [];
  List<Map<String, dynamic>> _announcements = [];
  Map<String, dynamic>? _currentUser;
  int _notificationCount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load dashboard statistics and user data from API
      final dashboardData = await apiService.getDashboardStats();
      final currentUser = await apiService.getCurrentUser();
      final notifications = await apiService.getNotifications(unreadOnly: true);
      
      setState(() {
        _recentConcerns = dashboardData['recentConcerns'] ?? [];
        _announcements = dashboardData['recentAnnouncements'] ?? [];
        _currentUser = currentUser;
        _notificationCount = notifications.length;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      // Keep empty state on error
      setState(() {
        _recentConcerns = [];
        _announcements = [];
        _currentUser = null;
        _notificationCount = 0;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // All data now loaded from backend API

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: _currentIndex == 0 ? _buildHomeContent() : _buildOtherTabContent(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHomeContent() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: DashboardHeader(
              studentName: _currentUser?['name'] ?? 'Student',
              notificationCount: _notificationCount,
              onNotificationTap: _handleNotificationTap,
              userAvatar: _currentUser?['avatar'],
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 2.h),
          ),
          SliverToBoxAdapter(
            child: QuickActionsCard(
              onSubmitConcern: _handleSubmitConcern,
            ),
          ),
          SliverToBoxAdapter(
            child: EmergencyHelpCard(),
          ),
          SliverToBoxAdapter(
            child: RecentConcernsCard(
              recentConcerns: _recentConcerns,
              onConcernTap: _handleConcernTap,
              onConcernLongPress: _handleConcernLongPress,
            ),
          ),
          SliverToBoxAdapter(
            child: AnnouncementsFeed(
              announcements: _announcements,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 10.h),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherTabContent() {
    switch (_currentIndex) {
      case 1:
        return MyConcerns();
      case 2:
        return Announcements();
      case 3:
        return ProfileSettings();
      default:
        return Container();
    }
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      selectedItemColor: AppTheme.lightTheme.colorScheme.primary,
      unselectedItemColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
      elevation: 8,
      items: [
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'home',
            color: _currentIndex == 0
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'assignment',
            color: _currentIndex == 1
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          label: 'My Concerns',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'campaign',
            color: _currentIndex == 2
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          label: 'Announcements',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'person',
            color: _currentIndex == 3
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _handleOpenBCPAI,
      backgroundColor: AppTheme.secondaryLight,
      foregroundColor: Colors.white,
      elevation: 8,
      icon: CustomIconWidget(
        iconName: 'smart_toy',
        color: Colors.white,
        size: 24,
      ),
      label: Text(
        'BCP AI',
        style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    // Reload dashboard data from API
    await _loadDashboardData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dashboard refreshed successfully'),
        backgroundColor: AppTheme.successLight,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleNotificationTap() {
    if (_notificationCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have $_notificationCount new notification${_notificationCount > 1 ? 's' : ''}'),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No new notifications'),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleSubmitConcern() {
    Navigator.pushNamed(context, '/submit-concern');
  }

  void _handleOpenBCPAI() {
    Navigator.pushNamed(context, '/ai-chat-assistant');
  }

  void _handleConcernTap(Map<String, dynamic> concern) {
    Navigator.pushNamed(
      context,
      '/concern-details',
      arguments: concern,
    );
  }

  void _handleConcernLongPress(Map<String, dynamic> concern) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
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
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              concern['title'] as String? ?? 'Concern Options',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            _buildContextMenuItem(
              'View Details',
              'visibility',
              () {
                Navigator.pop(context);
                _handleConcernTap(concern);
              },
            ),
            _buildContextMenuItem(
              'Add Reply',
              'reply',
              () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reply feature coming soon'),
                    backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  ),
                );
              },
            ),
            _buildContextMenuItem(
              'Share Status',
              'share',
              () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Status shared successfully'),
                    backgroundColor: AppTheme.successLight,
                  ),
                );
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildContextMenuItem(
      String title, String iconName, VoidCallback onTap) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        color: AppTheme.lightTheme.colorScheme.primary,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
