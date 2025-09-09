# StudentLink Mobile - Flutter Application

![Flutter](https://img.shields.io/badge/Flutter-3.6.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green.svg)

A comprehensive Flutter mobile application for Bestlink College students to manage concerns, access emergency help, and interact with AI-powered assistance. This app is part of the StudentLink ecosystem and integrates seamlessly with the Laravel backend API.

## 🏗️ Architecture Overview

### System Integration
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Flutter Mobile │    │  Laravel Backend │    │  Next.js Web    │
│   (Students)    │◄──►│   (Core API)     │◄──►│ (Faculty/Staff) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Key Features
- **🔐 JWT Authentication** - Secure login with Laravel backend
- **📋 Concern Management** - Submit, track, and manage student concerns
- **🤖 AI Chat Assistant** - GPT-powered conversational interface
- **🔔 Push Notifications** - Real-time updates via Firebase FCM
- **🚨 Emergency Help** - Quick access to emergency contacts
- **📢 Announcements** - Campus-wide announcements and notifications
- **🎤 Voice Input** - Speech-to-text functionality for accessibility
- **📱 Cross-Platform** - Android and iOS support

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.6.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code
- Android SDK (for Android development)
- Xcode (for iOS development)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd studentlink_mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   Create a `.env` file or use build configurations:
   ```bash
   # For development
   flutter run --dart-define=API_BASE_URL=http://localhost:8000/api
   
   # For production
   flutter run --dart-define=API_BASE_URL=https://api.studentlink.bestlink.edu.ph/api
   ```

4. **Configure Firebase (for push notifications)**
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`

5. **Run the application**
   ```bash
   # Development
   flutter run --debug
   
   # Release
   flutter run --release
   
   # Specific flavor
   flutter run --flavor development
   ```

## 📱 Build Configurations

### Development Build
```bash
flutter run --debug --dart-define=API_BASE_URL=http://10.0.2.2:8000/api --dart-define=DEBUG_MODE=true
```

### Staging Build
```bash
flutter run --release --dart-define=API_BASE_URL=https://staging-api.studentlink.bestlink.edu.ph/api
```

### Production Build
```bash
flutter build apk --release --dart-define=API_BASE_URL=https://api.studentlink.bestlink.edu.ph/api
flutter build ios --release --dart-define=API_BASE_URL=https://api.studentlink.bestlink.edu.ph/api
```

## 🔧 Configuration

### Environment Variables

The app supports the following environment variables:

```dart
// API Configuration
API_BASE_URL=http://localhost:8000/api
OPENAI_API_KEY=your_openai_key

// Feature Flags
ENABLE_AI_FEATURES=true
ENABLE_VOICE_INPUT=true
ENABLE_PUSH_NOTIFICATIONS=true
ENABLE_OFFLINE_MODE=false

// Debug Configuration
DEBUG_MODE=false
ENABLE_API_LOGGING=false
```

### Build Flavors

- **development**: Development environment with debug features
- **staging**: Staging environment for testing
- **production**: Production environment

### Firebase Configuration

For push notifications, add your Firebase configuration files:

**Android**: `android/app/google-services.json`
```json
{
  "project_info": {
    "project_number": "your_project_number",
    "project_id": "your_project_id"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "your_app_id",
        "android_client_info": {
          "package_name": "com.bestlink.studentlink"
        }
      }
    }
  ]
}
```

**iOS**: `ios/Runner/GoogleService-Info.plist`

## 📚 API Integration

### Backend Connection

The app connects to the Laravel backend API with the following endpoints:

#### Authentication
- `POST /auth/login` - User login
- `POST /auth/logout` - User logout  
- `GET /auth/me` - Get current user
- `POST /auth/refresh` - Refresh JWT token

#### Concerns
- `GET /concerns` - List user concerns
- `POST /concerns` - Create new concern
- `GET /concerns/{id}` - Get concern details
- `POST /concerns/{id}/messages` - Add message

#### Announcements
- `GET /announcements` - List announcements
- `POST /announcements/{id}/bookmark` - Bookmark announcement

#### AI Features
- `POST /ai/chat` - Chat with AI assistant
- `POST /ai/suggestions` - Get AI suggestions
- `POST /ai/transcribe` - Transcribe audio

#### Emergency Help
- `GET /emergency/contacts` - Get emergency contacts
- `GET /emergency/protocols` - Get emergency protocols

### Usage Example

```dart
import 'package:studentlink_mobile/services/api_service.dart';

// Login
final apiService = ApiService();
final loginResult = await apiService.login('student@bestlink.edu.ph', 'password');

// Get concerns
final concerns = await apiService.getConcerns(status: 'pending');

// Submit concern
final newConcern = await apiService.createConcern({
  'subject': 'Late enrollment fee payment',
  'description': 'I need an extension for my enrollment fee payment.',
  'department_id': 1,
  'type': 'administrative',
  'priority': 'medium',
});

// AI Chat
final response = await apiService.sendAiMessage('How do I submit a concern?');
```

## 🎨 UI/UX Design

### Design Philosophy
"Contemporary Educational Minimalism" with "Institutional Trust Palette"

### Color Scheme
- **Primary**: Deep Blue (#1E3A8A) - Trust & Authority
- **Secondary**: Emerald Green (#059669) - Growth & Success
- **Emergency**: Red (#DC2626) - Urgency & Alert
- **Success**: Green (#10B981) - Success States
- **Warning**: Amber (#F59E0B) - Warnings

### Typography
- **Font Family**: Google Fonts Inter
- **Responsive Scaling**: Disabled for consistency
- **Accessibility**: High contrast and readable fonts

## 📱 Platform-Specific Features

### Android
- **Material Design 3** compliance
- **Adaptive icons** with different shapes
- **Background sync** for notifications
- **File provider** for sharing files

### iOS
- **Cupertino design** elements where appropriate
- **iOS notifications** with rich content
- **App Transport Security** compliance
- **Background app refresh** support

## 🔒 Security Features

- **JWT Token Management** - Secure token storage and refresh
- **SSL Pinning** - Certificate pinning for API calls
- **Biometric Authentication** - Fingerprint/Face ID support
- **Data Encryption** - Local data encryption
- **Network Security** - HTTPS only communication

## 🧪 Testing

### Running Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/widget_test.dart

# Coverage report
flutter test --coverage
```

### Test Structure
```
test/
├── unit/
│   ├── services/
│   ├── models/
│   └── utils/
├── widget/
│   ├── screens/
│   └── components/
└── integration/
    ├── auth_flow_test.dart
    ├── concern_flow_test.dart
    └── ai_chat_test.dart
```

## 🚀 Deployment

### Android APK
```bash
# Build release APK
flutter build apk --release --dart-define=API_BASE_URL=https://api.studentlink.bestlink.edu.ph/api

# Build App Bundle for Play Store
flutter build appbundle --release --dart-define=API_BASE_URL=https://api.studentlink.bestlink.edu.ph/api
```

### iOS IPA
```bash
# Build for iOS
flutter build ios --release --dart-define=API_BASE_URL=https://api.studentlink.bestlink.edu.ph/api

# Archive for App Store
flutter build ipa --release --dart-define=API_BASE_URL=https://api.studentlink.bestlink.edu.ph/api
```

### CI/CD with GitHub Actions

Create `.github/workflows/build.yml`:

```yaml
name: Build and Deploy

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.6.0'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Run tests
      run: flutter test
    
    - name: Build APK
      run: flutter build apk --release --dart-define=API_BASE_URL=${{ secrets.API_BASE_URL }}
    
    - name: Upload artifacts
      uses: actions/upload-artifact@v3
      with:
        name: release-apk
        path: build/app/outputs/flutter-apk/app-release.apk
```

## 📊 Performance Optimization

### Image Optimization
- **Cached Network Images** - Automatic image caching
- **Image Compression** - Reduce image sizes
- **Lazy Loading** - Load images on demand

### Memory Management
- **State Management** - Efficient state handling
- **Widget Disposal** - Proper cleanup of resources
- **Memory Monitoring** - Track memory usage

### Battery Optimization
- **Background Tasks** - Minimize background processing
- **Network Efficiency** - Batch API calls
- **Location Services** - Use only when necessary

## 🔧 Development Tools

### Recommended VS Code Extensions
- Flutter
- Dart
- Flutter Widget Snippets
- Error Lens
- GitLens

### Debugging
```bash
# Debug with verbose logging
flutter run --debug --verbose

# Profile performance
flutter run --profile

# Inspect widget tree
flutter inspector
```

## 📈 Analytics & Monitoring

### Crash Reporting
- **Firebase Crashlytics** - Crash reporting and analysis
- **Custom Error Handling** - Graceful error recovery

### Performance Monitoring
- **Firebase Performance** - App performance insights
- **Custom Metrics** - Track specific app metrics

### User Analytics
- **Firebase Analytics** - User behavior tracking
- **Custom Events** - Track feature usage

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new features
4. Ensure all tests pass
5. Submit a pull request

### Code Style
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format` for code formatting
- Add documentation for public APIs

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For technical support or questions:
- Email: support@studentlink.edu.ph
- Documentation: [Flutter Docs](https://docs.flutter.dev/)
- Issues: [GitHub Issues](issues)

## 🎓 About Bestlink College

StudentLink Mobile is proudly built for **Bestlink College of the Philippines**, enhancing the educational experience through innovative technology solutions.

---

**Built with ❤️ using Flutter for Bestlink College of the Philippines**