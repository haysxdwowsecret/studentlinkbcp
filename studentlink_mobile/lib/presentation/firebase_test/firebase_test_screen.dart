import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/firebase_config.dart';
import '../../services/firebase_service.dart';

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String _fcmToken = 'Not available';
  String _testResults = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Initialize Firebase
      await FirebaseConfig.initialize();
      
      // Initialize Firebase Service
      await _firebaseService.initialize();
      
      // Get FCM Token
      final token = _firebaseService.currentToken;
      if (token != null) {
        setState(() {
          _fcmToken = token;
        });
      }

      _addTestResult('✅ Firebase initialized successfully');
      _addTestResult('✅ FCM Token obtained: ${token?.substring(0, 20)}...');
    } catch (e) {
      _addTestResult('❌ Firebase initialization failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addTestResult(String result) {
    setState(() {
      _testResults += '$result\n';
    });
  }

  Future<void> _testPushNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Test FCM token refresh
      final newToken = await _firebaseService.refreshToken();
      if (newToken != null) {
        _addTestResult('✅ FCM Token refreshed successfully');
        setState(() {
          _fcmToken = newToken;
        });
      } else {
        _addTestResult('❌ FCM Token refresh failed');
      }

      // Test topic subscription
      await _firebaseService.subscribeToTopic('test_topic');
      _addTestResult('✅ Subscribed to test_topic');

      // Test topic unsubscription
      await _firebaseService.unsubscribeFromTopic('test_topic');
      _addTestResult('✅ Unsubscribed from test_topic');

      _addTestResult('✅ Push Notifications test completed');
    } catch (e) {
      _addTestResult('❌ Push Notifications test failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testFirebaseAnalytics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Test analytics event logging
      await FirebaseConfig.logEvent('firebase_test_started', parameters: {
        'test_type': 'analytics',
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      _addTestResult('✅ Analytics event logged: firebase_test_started');

      // Test user property setting
      await FirebaseConfig.setUserProperty('test_user', 'firebase_tester');
      _addTestResult('✅ User property set: test_user = firebase_tester');

      // Test user ID setting
      await FirebaseConfig.setUserId('test_user_123');
      _addTestResult('✅ User ID set: test_user_123');

      // Test more analytics events
      await FirebaseConfig.logEvent('button_clicked', parameters: {
        'button_name': 'test_analytics',
        'screen': 'firebase_test',
      });
      _addTestResult('✅ Analytics event logged: button_clicked');

      _addTestResult('✅ Firebase Analytics test completed');
    } catch (e) {
      _addTestResult('❌ Firebase Analytics test failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testFirebaseMessaging() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Test FCM token
      final token = await FirebaseConfig.getFCMToken();
      if (token != null) {
        _addTestResult('✅ FCM Token retrieved: ${token.substring(0, 20)}...');
      } else {
        _addTestResult('❌ FCM Token retrieval failed');
      }

      // Test notification permissions
      final settings = await FirebaseConfig.requestPermissions();
      _addTestResult('✅ Notification permissions: ${settings.authorizationStatus}');

      _addTestResult('✅ Firebase Messaging test completed');
    } catch (e) {
      _addTestResult('❌ Firebase Messaging test failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runAllTests() async {
    setState(() {
      _testResults = '';
      _isLoading = true;
    });

    _addTestResult('🚀 Starting comprehensive Firebase tests...\n');

    // Test Firebase Messaging
    _addTestResult('📱 Testing Firebase Messaging...');
    await _testFirebaseMessaging();
    _addTestResult('');

    // Test Push Notifications
    _addTestResult('🔔 Testing Push Notifications...');
    await _testPushNotifications();
    _addTestResult('');

    // Test Firebase Analytics
    _addTestResult('📊 Testing Firebase Analytics...');
    await _testFirebaseAnalytics();
    _addTestResult('');

    _addTestResult('🎉 All Firebase tests completed!');
    setState(() {
      _isLoading = false;
    });
  }

  void _clearResults() {
    setState(() {
      _testResults = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Firebase Test Center',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.blue[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Firebase Integration Status',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Project: studentlinkbcp0',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    'FCM Token: ${_fcmToken.substring(0, 30)}...',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // Test Buttons
            Text(
              'Firebase Tests',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 2.h),

            // Test Buttons Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 3.w,
              childAspectRatio: 1.5,
              children: [
                _buildTestButton(
                  'Push Notifications',
                  Icons.notifications,
                  Colors.orange,
                  _testPushNotifications,
                ),
                _buildTestButton(
                  'Analytics',
                  Icons.analytics,
                  Colors.green,
                  _testFirebaseAnalytics,
                ),
                _buildTestButton(
                  'Messaging',
                  Icons.message,
                  Colors.purple,
                  _testFirebaseMessaging,
                ),
                _buildTestButton(
                  'Run All Tests',
                  Icons.play_arrow,
                  Colors.blue,
                  _runAllTests,
                ),
              ],
            ),

            SizedBox(height: 4.h),

            // Results Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Test Results',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                TextButton.icon(
                  onPressed: _clearResults,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Results Container
            Container(
              width: double.infinity,
              height: 40.h,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _testResults.isEmpty ? 'No test results yet. Run a test to see results here.' : _testResults,
                  style: GoogleFonts.robotoMono(
                    fontSize: 12.sp,
                    color: _testResults.isEmpty ? Colors.grey[500] : Colors.green[300],
                    height: 1.4,
                  ),
                ),
              ),
            ),

            SizedBox(height: 4.h),

            // Loading Indicator
            if (_isLoading)
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    SizedBox(height: 2.h),
                    Text(
                      'Running tests...',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _isLoading ? Colors.grey[300] : color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 8.w,
              color: Colors.white,
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

