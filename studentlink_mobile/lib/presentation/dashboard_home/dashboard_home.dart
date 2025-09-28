import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../services/api_service.dart';
import '../../services/websocket_service.dart';
import '../../config/firebase_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../theme/app_theme.dart';
import '../my_concerns/my_concerns.dart';
import '../announcements/new_announcements_screen.dart';
import '../profile_settings/profile_settings.dart';
import './widgets/modern_announcements_feed.dart';
import './widgets/modern_dashboard_header.dart';
import './widgets/modern_emergency_help_card.dart';
import './widgets/modern_quick_actions_card.dart';
import './widgets/modern_recent_concerns_card.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

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
    _setupWebSocket();
    _setupFirebaseIntegration();
  }

  void _setupWebSocket() {
    final websocketService = WebSocketService();
    
    // Connect to WebSocket
    websocketService.connect();
    
    // Subscribe to concern updates
    websocketService.subscribeToConcerns((data) {
      if (mounted) {
        setState(() {
          // Update recent concerns with new data
          final concernData = data['concern'] as Map<String, dynamic>?;
          if (concernData != null) {
            // Remove existing concern if it exists
            _recentConcerns.removeWhere((concern) => concern['id'] == concernData['id']);
            // Add updated concern at the beginning
            _recentConcerns.insert(0, concernData);
            // Keep only the most recent 5 concerns
            if (_recentConcerns.length > 5) {
              _recentConcerns = _recentConcerns.take(5).toList();
            }
          }
        });
      }
    });

    // Subscribe to resolution updates
    websocketService.subscribeToResolutionUpdates((data) {
      if (mounted) {
        final eventType = data['type'] as String?;
        final concernData = data['concern'] as Map<String, dynamic>?;
        
        if (concernData != null) {
          setState(() {
            // Update recent concerns with resolution changes
            _recentConcerns.removeWhere((concern) => concern['id'] == concernData['id']);
            _recentConcerns.insert(0, concernData);
            if (_recentConcerns.length > 5) {
              _recentConcerns = _recentConcerns.take(5).toList();
            }
          });

          // Show appropriate notification based on event type
          switch (eventType) {
            case 'resolution_confirmed':
              _showResolutionNotification('Resolution confirmed!', 'Your concern has been marked as resolved.');
              break;
            case 'resolution_disputed':
              _showResolutionNotification('Resolution disputed', 'Your concern has been reopened for discussion.');
              break;
            case 'chat_room_closed':
              _showResolutionNotification('Chat closed', 'The chat room for this concern has been closed.');
              break;
            case 'chat_room_reopened':
              _showResolutionNotification('Chat reopened', 'The chat room has been reopened for further discussion.');
              break;
          }
        }
      }
    });
  }

  void _setupFirebaseIntegration() async {
    try {
      // Log dashboard view event
      await FirebaseConfig.logEvent('dashboard_viewed', parameters: {
        'user_id': _currentUser?['id']?.toString() ?? 'unknown',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      // Set user properties for analytics
      if (_currentUser != null) {
        await FirebaseConfig.setUserId(_currentUser!['id']?.toString() ?? 'unknown');
        await FirebaseConfig.setUserProperty('user_type', 'student');
        await FirebaseConfig.setUserProperty('college', 'BCP');
      }

      // Setup push notification handling
      _setupPushNotifications();

      print('✅ Firebase integration setup complete');
    } catch (e) {
      print('❌ Firebase integration setup failed: $e');
    }
  }

  void _setupPushNotifications() {
    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 Received foreground message: ${message.notification?.title}');
      
      // Show in-app notification
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.notifications, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.notification?.title ?? 'New Notification',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (message.notification?.body != null)
                        Text(
                          message.notification!.body!,
                          style: TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.primaryLight,
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                // Handle notification tap
                _handleNotificationTap();
              },
            ),
          ),
        );
      }
    });

    // Listen for notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 App opened from notification: ${message.data}');
      _handleNotificationNavigation(message.data);
    });
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final String? type = data['type'];
    final String? concernId = data['concern_id'];
    final String? announcementId = data['announcement_id'];
    final String? chatRoomId = data['chat_room_id'];

    switch (type) {
      case 'concern_update':
        if (concernId != null) {
          Navigator.pushNamed(
            context,
            '/concern-details',
            arguments: {'id': int.parse(concernId)},
          );
        }
        break;
      case 'concern_message':
        if (concernId != null) {
          Navigator.pushNamed(
            context,
            '/concern-details',
            arguments: {'id': int.parse(concernId), 'openChat': true},
          );
        }
        break;
      case 'chat_message':
        if (chatRoomId != null) {
          // Navigate to chat room
          Navigator.pushNamed(
            context,
            '/chat-room',
            arguments: {'chatRoomId': int.parse(chatRoomId)},
          );
        } else if (concernId != null) {
          // Fallback to concern details
          Navigator.pushNamed(
            context,
            '/concern-details',
            arguments: {'id': int.parse(concernId), 'openChat': true},
          );
        }
        break;
      case 'announcement':
        if (announcementId != null) {
          // Navigate to announcement details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening announcement: $announcementId'),
              backgroundColor: AppTheme.primaryLight,
            ),
          );
        }
        break;
      case 'emergency':
        // Navigate to emergency help
        Navigator.pushNamed(context, '/emergency-help');
        break;
      default:
        // Refresh dashboard
        _loadDashboardData();
        break;
    }
  }

  void _showResolutionNotification(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              message,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  void dispose() {
    WebSocketService().disconnect();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('🔄 Loading dashboard data...');
      // Load dashboard statistics and user data from API
      final dashboardData = await apiService.getDashboardStats();
      final currentUser = await apiService.getCurrentUser();
      final notifications = await apiService.getNotifications(unreadOnly: true);
      
      print('📊 Dashboard data loaded:');
      print('  - Recent concerns: ${dashboardData['recentConcerns']?.length ?? 0}');
      print('  - Recent announcements: ${dashboardData['recentAnnouncements']?.length ?? 0}');
      
      setState(() {
        _recentConcerns = _convertToList(dashboardData['recentConcerns'] ?? []);
        _announcements = _convertToList(dashboardData['recentAnnouncements'] ?? []);
        _currentUser = currentUser;
        _notificationCount = notifications.length;
      });
      
      // Log Firebase analytics events
      await FirebaseConfig.logEvent('dashboard_data_loaded', parameters: {
        'concerns_count': _recentConcerns.length,
        'announcements_count': _announcements.length,
        'notifications_count': _notificationCount,
      });
      
      print('✅ Dashboard data updated successfully');
    } catch (e) {
      print('❌ Error loading dashboard data: $e');
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load dashboard: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
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

  // Helper method to convert dynamic list to List<Map<String, dynamic>>
  List<Map<String, dynamic>> _convertToList(dynamic data) {
    print('🔄 Converting data type: ${data.runtimeType}');
    
    if (data == null) {
      print('⚠️ Data is null, returning empty list');
      return [];
    }
    
    if (data is List) {
      print('✅ Data is List with ${data.length} items');
      return data.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        } else if (item is Map) {
          return Map<String, dynamic>.from(item);
        } else {
          print('⚠️ Unexpected item type in dashboard data: ${item.runtimeType}');
          return <String, dynamic>{};
        }
      }).toList();
    } else {
      print('⚠️ Data is not a List, it is: ${data.runtimeType}');
      return [];
    }
  }

  // All data now loaded from backend API

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Modern light background
      body: Stack(
        children: [
          _currentIndex == 0 ? _buildModernHomeContent() : _buildOtherTabContent(),
          if (_currentIndex == 0) _buildModernFloatingActionButton(),
        ],
      ),
      bottomNavigationBar: _buildModernBottomNavigationBar(),
      floatingActionButton: _buildSubmitConcernFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildModernHomeContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.primaryLight,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: RepaintBoundary(
              child: ModernDashboardHeader(
                studentName: _currentUser?['name'] ?? 'Student',
                notificationCount: _notificationCount,
                onNotificationTap: _handleNotificationTap,
                userAvatar: _currentUser?['avatar'],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: const SizedBox(height: 24),
          ),
          SliverToBoxAdapter(
            child: RepaintBoundary(
              child: ModernQuickActionsCard(
                onSubmitConcern: _handleSubmitConcern,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: RepaintBoundary(
              child: ModernEmergencyHelpCard(),
            ),
          ),
          SliverToBoxAdapter(
            child: RepaintBoundary(
              child: ModernRecentConcernsCard(
                recentConcerns: _recentConcerns,
                onConcernTap: _handleConcernTap,
                onConcernLongPress: _handleConcernLongPress,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: RepaintBoundary(
              child: ModernAnnouncementsFeed(
                announcements: _announcements,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: const SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherTabContent() {
    switch (_currentIndex) {
      case 1:
        return const MyConcerns();
      case 2:
        return NewAnnouncementsScreen();
      case 3:
        return ProfileSettings();
      default:
        return Container();
    }
  }

  Widget _buildModernBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: AppTheme.primaryLight,
        unselectedItemColor: const Color(0xFF9CA3AF),
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 11,
        ),
        iconSize: 22,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 0 ? Icons.home_rounded : Icons.home_outlined,
              size: 22,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 1 ? Icons.assignment_rounded : Icons.assignment_outlined,
              size: 22,
            ),
            label: 'Concerns',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 2 ? Icons.campaign_rounded : Icons.campaign_outlined,
              size: 22,
            ),
            label: 'Announcements',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 3 ? Icons.person_rounded : Icons.person_outline,
              size: 22,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }


  Widget _buildSubmitConcernFAB() {
    return FloatingActionButton(
      onPressed: () => Navigator.pushNamed(context, '/submit-concern'),
      backgroundColor: AppTheme.primaryLight,
      mini: true, // Makes the FAB smaller
      child: const Icon(
        Icons.add_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildModernFloatingActionButton() {
    return Positioned(
      bottom: 80, // Lower position, closer to navigation bar
      right: 20,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/ai-chat-assistant'),
        child: Container(
          width: 48, // Reduced from 56
          height: 48, // Reduced from 56
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.secondaryLight,
                AppTheme.secondaryLight.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24), // Adjusted for new size
            boxShadow: [
              BoxShadow(
                color: AppTheme.secondaryLight.withValues(alpha: 0.3),
                blurRadius: 12, // Reduced shadow
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 24,
          ),
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

  void _handleSubmitConcern() async {
    // Log Firebase analytics event
    await FirebaseConfig.logEvent('submit_concern_clicked', parameters: {
      'user_id': _currentUser?['id']?.toString() ?? 'unknown',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    
    Navigator.pushNamed(context, '/submit-concern');
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
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              concern['title'] as String? ?? 'Concern Options',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
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
            const SizedBox(height: 16),
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
