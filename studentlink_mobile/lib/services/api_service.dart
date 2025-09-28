import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../utils/error_handler.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;
  final String _baseUrl = AppConfig.baseApiUrl;

  // Initialize and load saved auth token
  Future<void> initialize() async {
    print('🔄 Initializing API service...');
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    if (_authToken != null) {
      print('🔑 Loaded existing auth token: ${_authToken!.substring(0, 20)}...');
    } else {
      print('⚠️ No existing auth token found');
    }
  }

  // Save auth token to storage
  Future<void> _saveAuthToken(String token) async {
    print('💾 Saving auth token to storage...');
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    print('✅ Auth token saved to storage');
  }

  // Remove auth token from storage
  Future<void> _removeAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Get headers with auth token
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-App-Version': AppConfig.appVersion,
      'X-Platform': 'mobile',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  // Generic HTTP request method
  Future<Map<String, dynamic>> _request(
    String endpoint,
    String method, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final finalUri = queryParams != null
          ? uri.replace(queryParameters: queryParams)
          : uri;

      print('🔍 API Request: $method $finalUri');
      print('🔑 Auth Token: ${_authToken?.substring(0, 20)}...');
      print('📋 Headers: $_headers');

      late http.Response response;

      // Add timeout to all requests
      final timeout = Duration(seconds: 30);
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(finalUri, headers: _headers).timeout(timeout);
          break;
        case 'POST':
          response = await http.post(
            finalUri,
            headers: _headers,
            body: body != null ? json.encode(body) : null,
          ).timeout(timeout);
          break;
        case 'PUT':
          response = await http.put(
            finalUri,
            headers: _headers,
            body: body != null ? json.encode(body) : null,
          ).timeout(timeout);
          break;
        case 'DELETE':
          response = await http.delete(finalUri, headers: _headers).timeout(timeout);
          break;
        case 'PATCH':
          response = await http.patch(
            finalUri,
            headers: _headers,
            body: body != null ? json.encode(body) : null,
          ).timeout(timeout);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      print('📊 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');
      
      final responseData = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ API Success: ${response.statusCode}');
        return responseData;
      } else {
        print('❌ API Error: ${response.statusCode} - ${response.body}');
        // Handle 401 unauthorized - token expired
        if (response.statusCode == 401) {
          await _removeAuthToken();
          throw AppError(
            message: 'Authentication expired. Please login again.',
            type: ErrorType.authentication,
            statusCode: 401,
          );
        }

        throw AppError(
          message: responseData['message'] ?? 'Request failed with status: ${response.statusCode}',
          type: ErrorType.server,
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException catch (e) {
      print('⏰ Timeout Error: Request timed out - $e');
      throw AppError(
        message: 'Request timed out. Please check your connection and try again.',
        type: ErrorType.network,
      );
    } on SocketException catch (e) {
      print('🌐 Network Error: No internet connection - $e');
      throw AppError(
        message: 'No internet connection. Please check your network and try again.',
        type: ErrorType.network,
      );
    } catch (e) {
      print('💥 API Exception: $e');
      if (e is AppError) {
        rethrow;
      }
      // Handle connection abort errors
      if (e.toString().contains('Software caused connection abort')) {
        throw AppError(
          message: 'Connection failed. Please check if the server is running and try again.',
          type: ErrorType.network,
        );
      }
      throw AppError(
        message: 'Request failed: $e',
        type: ErrorType.unknown,
      );
    }
  }

  // Authentication endpoints
  Future<Map<String, dynamic>> login(String email, String password) async {
    print('🔐 Attempting login for: $email');
    final response = await _request('/auth/login', 'POST', body: {
        'email': email,
        'password': password,
      });

    if (response['success'] == true && response['data']['token'] != null) {
      final token = response['data']['token'];
      print('🔑 Login successful, saving token: ${token.substring(0, 20)}...');
      await _saveAuthToken(token);
      print('💾 Token saved successfully');
      return response['data'];
    } else {
      print('❌ Login failed: ${response['message']}');
      throw AppError(
        message: response['message'] ?? 'Login failed',
        type: ErrorType.authentication,
      );
    }
  }

  Future<void> logout() async {
    try {
      await _request('/auth/logout', 'POST');
    } finally {
      await _removeAuthToken();
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _request('/auth/me', 'GET');
    return response['data'];
  }

  Future<void> requestPasswordReset(String email) async {
    await _request('/auth/forgot-password', 'POST', body: {
      'email': email,
    });
  }

  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _request('/auth/reset-password', 'POST', body: {
      'email': email,
      'token': token,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }

  // Student Registration endpoints
  Future<Map<String, dynamic>> generateStudentId() async {
    final response = await _request('/registration/generate-id', 'POST');
    return response['data'];
  }

  Future<void> validateRegistrationData(Map<String, dynamic> data) async {
    await _request('/registration/validate', 'POST', body: data);
  }

  Future<Map<String, dynamic>> createStudentAccount(Map<String, dynamic> data) async {
    final response = await _request('/registration/create', 'POST', body: data);
    
    // Auto-login after successful registration
    if (response['success'] && response['data']['user_id'] != null) {
      // Login with the school email (not personal email)
      final schoolEmail = '${data['student_id']}@bcp.edu.ph';
      final loginResponse = await _request('/auth/login', 'POST', body: {
        'email': schoolEmail,
        'password': data['password'],
      });
      
      if (loginResponse['success'] && loginResponse['data']['token'] != null) {
        await _saveAuthToken(loginResponse['data']['token']);
        print('Auto-login successful for: $schoolEmail');
      } else {
        print('Auto-login failed: ${loginResponse['message']}');
      }
    }
    
    return response['data'];
  }

  Future<Map<String, dynamic>> getRegistrationStatus(String studentId) async {
    final response = await _request('/registration/status/$studentId', 'GET');
    return response['data'];
  }

  // OTP Verification endpoints
  Future<Map<String, dynamic>> sendEmailOtp(String email) async {
    final response = await _request('/registration/send-email-otp', 'POST', body: {
      'email': email,
    });
    return response;
  }

  Future<Map<String, dynamic>> sendPhoneOtp(String phone) async {
    final response = await _request('/registration/send-phone-otp', 'POST', body: {
      'phone_number': phone,
    });
    return response;
  }

  Future<Map<String, dynamic>> verifyOtps(String email, String emailOtp, String phone, String phoneOtp) async {
    final response = await _request('/registration/verify-otps', 'POST', body: {
      'email': email,
      'email_otp': emailOtp,
      'phone_number': phone,
      'phone_otp': phoneOtp,
    });
    return response;
  }

  // Profile Management endpoints
  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> data) async {
    final response = await _request('/profile/update', 'PUT', body: data);
    return response['data'];
  }

  Future<void> sendVerificationCode(String method) async {
    await _request('/profile/send-verification-code', 'POST', body: {
      'method': method, // 'email' or 'sms'
    });
  }

  Future<void> verifyCode(String code, String method) async {
    await _request('/profile/verify-code', 'POST', body: {
      'code': code,
      'method': method,
    });
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    await _request('/profile/change-password', 'POST', body: {
      'current_password': currentPassword,
      'new_password': newPassword,
      'new_password_confirmation': newPassword,
    });
  }

  Future<void> sendPasswordResetCode(String method, String target) async {
    await _request('/auth/forgot-password', 'POST', body: {
      'method': method, // 'email' or 'sms'
      'target': target, // email address or phone number
    });
  }

  Future<void> verifyPasswordResetCode(String code) async {
    await _request('/auth/verify-reset-code', 'POST', body: {
      'code': code,
    });
  }

  Future<void> resetPasswordWithCode(String code, String newPassword) async {
    await _request('/auth/reset-password', 'POST', body: {
      'code': code,
      'new_password': newPassword,
      'new_password_confirmation': newPassword,
    });
  }

  // Announcements endpoints
  Future<List<Map<String, dynamic>>> getAnnouncements({
    String? type,
    String? priority,
    String? status,
    int? page,
    int? perPage,
  }) async {
    final queryParams = <String, String>{};
    if (type != null) queryParams['type'] = type;
    if (priority != null) queryParams['priority'] = priority;
      if (status != null) queryParams['status'] = status;
    if (page != null) queryParams['page'] = page.toString();
    if (perPage != null) queryParams['per_page'] = perPage.toString();

    final response = await _request(
      '/announcements',
      'GET',
      queryParams: queryParams,
    );

    // Handle different response formats
    final data = response['data'];
    if (data is List) {
      return data.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        } else if (item is Map) {
          return Map<String, dynamic>.from(item);
        } else {
          print('⚠️ Unexpected announcement item type: ${item.runtimeType}');
          return <String, dynamic>{};
        }
      }).toList();
    } else {
      print('⚠️ Unexpected announcements response format: ${data.runtimeType}');
      return [];
    }
  }

  Future<Map<String, dynamic>> getAnnouncement(int id) async {
    final response = await _request('/announcements/$id', 'GET');
    return response['data'];
  }

  Future<void> bookmarkAnnouncement(int id) async {
    await _request('/announcements/$id/bookmark', 'POST');
  }

  Future<void> removeAnnouncementBookmark(int id) async {
    await _request('/announcements/$id/bookmark', 'DELETE');
  }

  // Concerns endpoints
  Future<List<Map<String, dynamic>>> getConcerns({
    String? status,
    int? departmentId,
    String? priority,
    String? type,
    int? page,
    int? perPage,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (departmentId != null) queryParams['department_id'] = departmentId.toString();
    if (priority != null) queryParams['priority'] = priority;
      if (type != null) queryParams['type'] = type;
    if (page != null) queryParams['page'] = page.toString();
    if (perPage != null) queryParams['per_page'] = perPage.toString();

    final response = await _request(
      '/concerns',
      'GET',
      queryParams: queryParams,
    );

    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<Map<String, dynamic>> getConcern(int id) async {
    final response = await _request('/concerns/$id', 'GET');
    return response['data'];
  }

  Future<Map<String, dynamic>> createConcern({
    required String subject,
    required String description,
    required int departmentId,
    int? facilityId,
    required String type,
    required String priority,
    bool isAnonymous = false,
    List<String>? attachments,
  }) async {
    print('API Service: Creating concern with data:');
    print('  Subject: $subject');
    print('  Description: $description');
    print('  Department ID: $departmentId');
    print('  Type: $type');
    print('  Priority: $priority');
    print('  Anonymous: $isAnonymous');
    
    final response = await _request('/concerns', 'POST', body: {
      'subject': subject,
      'description': description,
      'department_id': departmentId,
      if (facilityId != null) 'facility_id': facilityId,
      'type': type,
      'priority': priority,
      'is_anonymous': isAnonymous,
      if (attachments != null) 'attachments': attachments,
    });

    print('API Service: Concern creation response: $response');
    return response['data'];
  }

  Future<Map<String, dynamic>> addConcernMessage(
    int concernId,
    String message, {
    List<String>? attachments,
  }) async {
    final response = await _request('/concerns/$concernId/messages', 'POST', body: {
      'message': message,
      if (attachments != null) 'attachments': attachments,
    });

    return response['data'];
  }

  Future<void> deleteConcern(int concernId) async {
    await _request('/concerns/$concernId', 'DELETE');
  }

  /// Student confirms resolution of a concern
  Future<Map<String, dynamic>> confirmResolution(int concernId, {String? notes}) async {
    final response = await _request('/concerns/$concernId/confirm-resolution', 'POST', body: {
      if (notes != null) 'notes': notes,
    });
    return response['data'];
  }

  /// Student disputes resolution of a concern
  Future<Map<String, dynamic>> disputeResolution(int concernId, String reason) async {
    final response = await _request('/concerns/$concernId/dispute-resolution', 'POST', body: {
      'reason': reason,
    });
    return response['data'];
  }

  // Departments endpoints
  Future<List<Map<String, dynamic>>> getDepartments() async {
    print('API Service: Getting departments from $_baseUrl/departments');
    final response = await _request('/departments', 'GET');
    print('API Service: Response received: ${response.toString()}');
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<Map<String, dynamic>> getDepartmentById(int departmentId) async {
    final response = await _request('/departments/$departmentId', 'GET');
    return response['data'];
  }


  // Emergency endpoints
  Future<List<Map<String, dynamic>>> getEmergencyContacts() async {
    final response = await _request('/emergency/contacts', 'GET');
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<List<Map<String, dynamic>>> getEmergencyProtocols() async {
    final response = await _request('/emergency/protocols', 'GET');
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  // AI Chat endpoints
  Future<Map<String, dynamic>> sendAiMessage(
    String message, {
    String? sessionId,
    String? context,
  }) async {
    final response = await _request('/ai/chat', 'POST', body: {
        'message': message,
      if (sessionId != null) 'session_id': sessionId,
        'context': context ?? 'general',
      });
      
    return response['data'];
  }

  Future<List<String>> getAiSuggestions(
    String context,
    String type, {
    String? existingText,
  }) async {
    final response = await _request('/ai/suggestions', 'POST', body: {
        'context': context,
        'type': type,
      if (existingText != null) 'existing_text': existingText,
    });

    return List<String>.from(response['data']['suggestions'] ?? []);
  }

  // Notifications endpoints
  Future<List<Map<String, dynamic>>> getNotifications({
    bool? unreadOnly,
    String? type,
    String? priority,
    int? page,
    int? perPage,
  }) async {
    final queryParams = <String, String>{};
    if (unreadOnly != null) queryParams['unread_only'] = unreadOnly.toString();
    if (type != null) queryParams['type'] = type;
    if (priority != null) queryParams['priority'] = priority;
    if (page != null) queryParams['page'] = page.toString();
    if (perPage != null) queryParams['per_page'] = perPage.toString();

    final response = await _request(
      '/notifications',
      'GET',
      queryParams: queryParams,
    );

    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<void> markNotificationsAsRead(List<int> notificationIds) async {
    await _request('/notifications/mark-read', 'POST', body: {
      'notification_ids': notificationIds,
    });
  }

  Future<void> markAllNotificationsAsRead() async {
    await _request('/notifications/mark-all-read', 'POST');
  }

  Future<void> storeFcmToken(String token, String deviceType, {String? deviceId}) async {
    await _request('/notifications/fcm-token', 'POST', body: {
        'token': token,
        'device_type': deviceType,
      if (deviceId != null) 'device_id': deviceId,
    });
  }

  // Analytics & Dashboard endpoints
  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _request('/analytics/dashboard', 'GET');
    final data = response['data'];
    
    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is Map) {
      return Map<String, dynamic>.from(data);
    } else {
      print('⚠️ Unexpected dashboard response format: ${data.runtimeType}');
      return <String, dynamic>{};
    }
  }

  Future<Map<String, dynamic>> getConcernStats({
    String? dateFrom,
    String? dateTo,
    int? departmentId,
    String? status,
  }) async {
    final queryParams = <String, String>{};
    if (dateFrom != null) queryParams['date_from'] = dateFrom;
    if (dateTo != null) queryParams['date_to'] = dateTo;
    if (departmentId != null) queryParams['department_id'] = departmentId.toString();
    if (status != null) queryParams['status'] = status;

    final response = await _request(
      '/analytics/concerns',
      'GET',
      queryParams: queryParams,
    );
    return response['data'];
  }

  // System health check
  Future<Map<String, dynamic>> checkHealth() async {
    final response = await _request('/health', 'GET');
    return response['data'];
  }

  // File upload helper
  Future<String> uploadFile(File file, String type) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload'),
      );

      request.headers.addAll(_headers);
      request.fields['type'] = type;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData['data']['url'];
      } else {
        throw AppError(
          message: responseData['message'] ?? 'Upload failed',
          type: ErrorType.server,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        message: 'File upload failed: $e',
        type: ErrorType.unknown,
      );
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => _authToken != null;

  // Get current auth token
  String? get authToken => _authToken;

  // Chat-related methods
  Future<List<Map<String, dynamic>>> getActiveChatRooms() async {
    final response = await _request('/chat/rooms', 'GET');
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<Map<String, dynamic>> getOrCreateChatRoom(int concernId) async {
    final response = await _request('/chat/rooms/$concernId/get-or-create', 'GET');
    return response['data'];
  }

  Future<Map<String, dynamic>> sendChatMessage(int chatRoomId, String message, {
    String messageType = 'text',
    int? replyToId,
    List<String>? attachments,
  }) async {
    final response = await _request('/chat/rooms/$chatRoomId/messages', 'POST', body: {
      'message': message,
      'message_type': messageType,
      'reply_to_id': replyToId,
      'attachments': attachments,
    });
    return response['data'];
  }

  Future<List<Map<String, dynamic>>> getChatMessages(int chatRoomId) async {
    final response = await _request('/chat/rooms/$chatRoomId/messages', 'GET');
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<void> markChatAsRead(int chatRoomId) async {
    await _request('/chat/rooms/$chatRoomId/mark-read', 'POST');
  }

  Future<void> closeChatRoom(int chatRoomId) async {
    await _request('/chat/rooms/$chatRoomId/close', 'POST');
  }
}

// Singleton instance for easy access
final apiService = ApiService();