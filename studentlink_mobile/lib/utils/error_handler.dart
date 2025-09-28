import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum ErrorType {
  network,
  authentication,
  validation,
  server,
  unknown,
}

class AppError {
  final String message;
  final ErrorType type;
  final int? statusCode;
  final Map<String, dynamic>? details;

  AppError({
    required this.message,
    required this.type,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => message;
}

class ErrorHandler {
  static AppError parseError(dynamic error) {
    if (error is AppError) {
      return error;
    }

    final errorString = error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('socketexception') || 
        errorString.contains('no internet connection') ||
        errorString.contains('network')) {
      return AppError(
        message: 'No internet connection. Please check your network and try again.',
        type: ErrorType.network,
      );
    }

    // Authentication errors
    if (errorString.contains('authentication') || 
        errorString.contains('unauthorized') ||
        errorString.contains('token') ||
        errorString.contains('401')) {
      return AppError(
        message: 'Your session has expired. Please login again.',
        type: ErrorType.authentication,
        statusCode: 401,
      );
    }

    // Validation errors
    if (errorString.contains('validation') || 
        errorString.contains('422') ||
        errorString.contains('invalid')) {
      return AppError(
        message: 'Please check your input and try again.',
        type: ErrorType.validation,
        statusCode: 422,
      );
    }

    // Server errors
    if (errorString.contains('500') || 
        errorString.contains('server error') ||
        errorString.contains('internal server')) {
      return AppError(
        message: 'Server error. Please try again later.',
        type: ErrorType.server,
        statusCode: 500,
      );
    }

    // Default error
    return AppError(
      message: error.toString().replaceAll('Exception: ', ''),
      type: ErrorType.unknown,
    );
  }

  static void showError(BuildContext context, dynamic error) {
    final appError = parseError(error);
    
    // Show toast for non-critical errors
    if (appError.type != ErrorType.authentication) {
      Fluttertoast.showToast(
        msg: appError.message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } else {
      // Show dialog for authentication errors
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Session Expired'),
          content: Text(appError.message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to login screen
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              },
              child: const Text('Login'),
            ),
          ],
        ),
      );
    }
  }

  static void showSuccess(BuildContext context, String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  static void showInfo(BuildContext context, String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
    );
  }
}
