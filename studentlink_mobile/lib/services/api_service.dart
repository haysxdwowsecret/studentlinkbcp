import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;
  final String _baseUrl = AppConfig.baseApiUrl;

  // Initialize and load saved auth token
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }

  // Save auth token to storage
  Future<void> _saveAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
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

      late http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(finalUri, headers: _headers);
          break;
        case 'POST':
          response = await http.post(
            finalUri,
            headers: _headers,
            body: body != null ? json.encode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            finalUri,
            headers: _headers,
            body: body != null ? json.encode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(finalUri, headers: _headers);
          break;
        case 'PATCH':
          response = await http.patch(
            finalUri,
            headers: _headers,
            body: body != null ? json.encode(body) : null,
          );
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      final responseData = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        // Handle 401 unauthorized - token expired
        if (response.statusCode == 401) {
          await _removeAuthToken();
          throw Exception('Authentication expired. Please login again.');
        }

        throw Exception(
          responseData['message'] ?? 'Request failed with status: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }

  // Authentication endpoints
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _request('/auth/login', 'POST', body: {
        'email': email,
        'password': password,
      });

    if (response['success'] && response['data']['token'] != null) {
      await _saveAuthToken(response['data']['token']);
    }

    return response['data'];
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

    return List<Map<String, dynamic>>.from(response['data'] ?? []);
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

  // Departments endpoints
  Future<List<Map<String, dynamic>>> getDepartments() async {
    final response = await _request('/departments', 'GET');
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
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
    return response['data'];
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
        throw Exception(responseData['message'] ?? 'Upload failed');
      }
    } catch (e) {
      throw Exception('File upload failed: $e');
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => _authToken != null;

  // Get current auth token
  String? get authToken => _authToken;
}

// Singleton instance for easy access
final apiService = ApiService();