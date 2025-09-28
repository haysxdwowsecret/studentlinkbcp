# StudentLink - Comprehensive Student Management System

StudentLink is a full-stack student management system consisting of three main components: a Laravel backend API, a Flutter mobile application, and a Next.js web portal. The system provides comprehensive features for student management, announcements, authentication, and more.

## 🏗️ System Architecture

```
StudentLink System
├── studentlink_backend/     # Laravel API Backend
├── studentlink_mobile/      # Flutter Mobile App
├── studentlink_web/         # Next.js Web Portal
└── n&n files/              # N8N Workflow Files
```

## 🚀 Quick Start

### Prerequisites

- **Backend**: PHP 8.1+, Composer, MySQL/PostgreSQL
- **Mobile**: Flutter 3.0+, Dart 3.0+
- **Web**: Node.js 18+, npm/yarn
- **Database**: MySQL 8.0+ or PostgreSQL 13+

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/haysxdwowsecret/studentlinkbcp.git
   cd studentlinkbcp
   ```

2. **Backend Setup**
   ```bash
   cd studentlink_backend
   composer install
   cp .env.example .env
   php artisan key:generate
   php artisan migrate
   php artisan serve
   ```

3. **Mobile App Setup**
   ```bash
   cd studentlink_mobile
   flutter pub get
   flutter run
   ```

4. **Web Portal Setup**
   ```bash
   cd studentlink_web
   npm install
   npm run dev
   ```

## 📱 Components Overview

### 🔧 Backend (Laravel API)
- **Location**: `studentlink_backend/`
- **Framework**: Laravel 10+
- **Features**:
  - RESTful API endpoints
  - JWT Authentication
  - Student management
  - Announcement system
  - File upload handling
  - Twilio SMS integration
  - Dialogflow chatbot integration
  - Biometric authentication support

### 📱 Mobile App (Flutter)
- **Location**: `studentlink_mobile/`
- **Framework**: Flutter 3.0+
- **Features**:
  - Cross-platform mobile app
  - Biometric authentication
  - Image announcements
  - Real-time notifications
  - Offline support
  - Performance monitoring
  - Optimized asset management

### 🌐 Web Portal (Next.js)
- **Location**: `studentlink_web/`
- **Framework**: Next.js 13+
- **Features**:
  - Modern web interface
  - Responsive design
  - Admin dashboard
  - Student management
  - Announcement creation
  - Image handling
  - Real-time updates

## 🔧 Configuration

### Environment Variables

Each component requires specific environment variables. Copy the respective `.env.example` files and configure:

- **Backend**: Database, JWT, Twilio, Firebase credentials
- **Mobile**: API endpoints, Firebase configuration
- **Web**: API endpoints, authentication settings

### Database Setup

1. Create a MySQL/PostgreSQL database
2. Update database credentials in backend `.env`
3. Run migrations: `php artisan migrate`
4. Seed initial data: `php artisan db:seed`

## 🚀 Deployment

### Production Deployment

1. **Backend**: Deploy to VPS with PHP 8.1+, configure web server
2. **Mobile**: Build APK/IPA for distribution
3. **Web**: Deploy to Vercel, Netlify, or similar platform

### Docker Support

Each component includes Docker configuration for containerized deployment.

## 📚 API Documentation

The backend API documentation is available at `/docs/api-specification.yaml` when running the backend server.

### Key Endpoints

- `POST /api/auth/login` - User authentication
- `GET /api/students` - Get students list
- `POST /api/announcements` - Create announcement
- `GET /api/announcements` - Get announcements
- `POST /api/upload` - File upload

## 🔐 Security Features

- JWT-based authentication
- Biometric authentication (mobile)
- Input validation and sanitization
- CORS configuration
- Rate limiting
- Secure file uploads

## 🤖 AI Integration

- **Dialogflow**: Chatbot for student queries
- **Training Data**: Custom training data for institutional responses
- **NLP**: Natural language processing for ticket classification

## 📊 Monitoring & Analytics

- Performance monitoring (mobile)
- Error tracking
- User analytics
- System health monitoring

## 🧪 Testing

```bash
# Backend tests
cd studentlink_backend
php artisan test

# Mobile tests
cd studentlink_mobile
flutter test

# Web tests
cd studentlink_web
npm test
```

## 📝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check the documentation in each component's README
- Review the API specification

## 🔄 Version History

- **v1.0.0**: Initial release with core functionality
- **v1.1.0**: Added biometric authentication
- **v1.2.0**: Enhanced announcement system
- **v1.3.0**: Performance optimizations

## 🏫 Institutional Features

- Multi-institution support
- Custom branding
- Role-based access control
- Bulk operations
- Data export/import
- Integration with existing systems

---

**StudentLink** - Empowering educational institutions with modern technology solutions.
