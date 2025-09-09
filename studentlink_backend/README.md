# StudentLink Backend API
## Complete Laravel Backend for StudentLink Ecosystem

![Laravel](https://img.shields.io/badge/Laravel-10.x-red.svg)
![PHP](https://img.shields.io/badge/PHP-8.1+-blue.svg)
![MySQL](https://img.shields.io/badge/MySQL-8.0+-orange.svg)
![Local Dev](https://img.shields.io/badge/Local-Development-blue.svg)

A secure, scalable RESTful backend API built with Laravel PHP framework and MySQL database to support the StudentLink ecosystem - connecting Flutter mobile app for students and Next.js web portal for faculty, staff, department heads, and administrators at Bestlink College of the Philippines.

## 🏗️ Architecture Overview

### System Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Flutter Mobile │    │  Laravel Backend │    │  Next.js Web    │
│   (Students)    │◄──►│   (Core API)     │◄──►│ (Faculty/Staff) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                               │
                    ┌──────────┼──────────┐
                    │          │          │
            ┌───────▼───┐ ┌────▼────┐ ┌───▼───────┐
            │   MySQL   │ │  Redis  │ │ OpenAI    │
            │ Database  │ │ Cache   │ │    API    │
            └───────────┘ └─────────┘ └───────────┘
```

### Core Features
- **🔐 JWT Authentication** - Secure token-based auth with role-based access control
- **👥 Multi-Role Management** - Admin, Department Head, Staff, Faculty, Student roles
- **📋 Concern Management** - Complete lifecycle with threaded conversations
- **📢 Announcements** - Targeted notifications with scheduling
- **🚨 Emergency Help** - Centralized emergency contacts and protocols
- **🤖 AI Integration** - OpenAI GPT-3.5 and Dialogflow chatbot support
- **🔔 Real-time Notifications** - Firebase Cloud Messaging integration
- **📊 Analytics & Reporting** - Comprehensive system analytics
- **📱 Cross-Platform Sync** - Real-time synchronization between mobile and web

## 🚀 Quick Start

### Prerequisites
-

### Installation

1. **Clone Repository**
```bash
git clone <repositor PHP 8.1+
- Composer
- Node.js 18+
- MySQL 8.0+
- Redis (optional, for caching)
- Composer (PHP dependency manager)y-url>
cd studentlink_backend
```

2. **Install Dependencies**
```bash
composer install
npm install
```

3. **Environment Setup**
```bash
cp .env.example .env
php artisan key:generate
```

4. **Configure Environment Variables**
```bash
# Database Configuration
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=studentlink
DB_USERNAME=root
DB_PASSWORD=

# JWT Configuration
JWT_SECRET=your_jwt_secret_here

# OpenAI Configuration
OPENAI_API_KEY=your_openai_api_key

# Firebase Configuration
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_PRIVATE_KEY="your_firebase_private_key"
FIREBASE_CLIENT_EMAIL=your_firebase_client_email

# Redis Configuration (Optional)
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

# Mail Configuration
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your_email@gmail.com
MAIL_PASSWORD=your_app_password
```

5. **Database Setup**
```bash
php artisan migrate
php artisan db:seed
```

6. **Start Development Server**
```bash
php artisan serve
```

### Local Development Setup

1. **Install Dependencies and Setup**
```bash
# Install PHP dependencies
composer install

# Copy environment file
cp env.example .env

# Generate application key
php artisan key:generate

# Run migrations
php artisan migrate

# Seed database
php artisan db:seed
```

2. **Start Development Server**
```bash
php artisan serve
```

## 📚 API Documentation

### Base URL
- **Development**: `http://localhost:8000/api`
- **Production**: `https://your-domain.com/api`

### Authentication
All protected endpoints require a Bearer token in the Authorization header:
```
Authorization: Bearer <jwt_token>
```

### Core Endpoints

#### Authentication
- `POST /auth/login` - User login
- `POST /auth/logout` - User logout
- `GET /auth/me` - Get current user
- `POST /auth/refresh` - Refresh JWT token

#### Concerns Management
- `GET /concerns` - List concerns (with filtering)
- `POST /concerns` - Create new concern
- `GET /concerns/{id}` - Get concern details
- `PUT /concerns/{id}` - Update concern
- `DELETE /concerns/{id}` - Delete concern
- `POST /concerns/{id}/messages` - Add message to concern
- `PATCH /concerns/{id}/status` - Update concern status
- `POST /concerns/{id}/assign` - Assign concern to user
- `GET /concerns/{id}/history` - Get concern history

#### Announcements
- `GET /announcements` - List announcements
- `POST /announcements` - Create announcement
- `GET /announcements/{id}` - Get announcement details
- `PUT /announcements/{id}` - Update announcement
- `DELETE /announcements/{id}` - Delete announcement
- `POST /announcements/{id}/bookmark` - Bookmark announcement

#### User Management
- `GET /users` - List users (admin only)
- `POST /users` - Create user (admin only)
- `GET /users/{id}` - Get user details
- `PUT /users/{id}` - Update user
- `DELETE /users/{id}` - Delete user (admin only)

#### Emergency Help
- `GET /emergency/contacts` - Get emergency contacts
- `GET /emergency/protocols` - Get emergency protocols
- `PUT /emergency/contacts/{id}` - Update emergency contact

#### AI Features
- `POST /ai/chat` - Chat with AI assistant
- `POST /ai/suggestions` - Get AI suggestions for messages
- `POST /ai/transcribe` - Transcribe audio to text

#### Analytics & Reports
- `GET /dashboard/stats` - Dashboard statistics
- `GET /reports/concerns` - Concerns report
- `GET /reports/departments` - Department reports
- `GET /reports/users` - User activity reports

#### Notifications
- `GET /notifications` - Get user notifications
- `POST /notifications/mark-read` - Mark notifications as read
- `POST /notifications/subscribe` - Subscribe to FCM notifications

## 🗄️ Database Schema

### Core Tables
- **users** - User accounts with roles and departments
- **concerns** - Student concerns with status tracking
- **concern_messages** - Threaded conversation messages
- **announcements** - System and department announcements
- **departments** - Academic and administrative departments
- **emergency_contacts** - Emergency help contacts
- **notifications** - User notifications
- **audit_logs** - System activity audit trail

### Key Relationships
- Users belong to departments and have roles
- Concerns are submitted by students and assigned to staff
- Messages belong to concerns and are authored by users
- Announcements target specific departments/courses
- Notifications are sent to users based on their roles

## 🔒 Security Features

- **JWT Authentication** with secure token management
- **Role-Based Access Control** (RBAC) at API level
- **Input Validation** using Laravel Form Requests
- **SQL Injection Protection** via Eloquent ORM
- **XSS Protection** with automatic output escaping
- **CSRF Protection** for web routes
- **Rate Limiting** on API endpoints
- **CORS Configuration** for trusted origins
- **Data Encryption** for sensitive information
- **Audit Logging** for all critical operations

## 🔧 Development

### Code Standards
- **PSR-12** coding standards
- **PHPUnit** testing framework
- **Laravel Pint** code formatting
- **PHPStan** static analysis

### Testing
```bash
# Run all tests
php artisan test

# Run specific test suite
php artisan test --testsuite=Feature

# Generate coverage report
php artisan test --coverage
```

### API Testing
Import the Postman collection from `/docs/postman/` for comprehensive API testing.

## 📈 Performance & Scalability

### Caching Strategy
- **Redis** for session and application caching
- **Database Query Caching** for frequently accessed data
- **API Response Caching** for static content

### Optimization
- **Database Indexing** on frequently queried columns
- **Eager Loading** to prevent N+1 queries
- **Connection Pooling** for database connections
- **Background Job Processing** with Laravel Queues

## 🚀 Deployment

### Production Deployment
For production deployment instructions, please refer to:
- `LOCAL_DEVELOPMENT.md` for local setup
- Contact the development team for production deployment guidelines

### Environment Configuration
- **SSL/TLS** certificate configuration
- **Environment variables** for production settings
- **Database** connection optimization
- **Logging** configuration for production monitoring

## 📊 Monitoring & Analytics

### Health Checks
- `GET /health` - Basic health check
- `GET /health/detailed` - Detailed system status

### Metrics
- API response times
- Database query performance
- Cache hit rates
- Error rates and patterns

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For technical support or questions:
- Email: support@studentlink.edu.ph
- Documentation: [API Docs](docs/api.md)
- Issues: [GitHub Issues](issues)

---

**Built with ❤️ for Bestlink College of the Philippines**
