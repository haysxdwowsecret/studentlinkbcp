# StudentLink Backend - Local Development Guide

## Overview

This guide covers setting up and running the StudentLink Backend API locally for development.

## Prerequisites

### Required Software
- PHP 8.1 or higher
- Composer
- MySQL 8.0 or higher
- Redis (optional, for caching)
- Node.js 16+ (for frontend assets)

### PHP Extensions
- PDO MySQL
- BCMath
- Ctype
- Fileinfo
- JSON
- Mbstring
- OpenSSL
- PCRE
- Tokenizer
- XML

## Installation

### 1. Clone and Setup
```bash
cd studentlink_backend
composer install
```

### 2. Environment Configuration
```bash
cp env.example .env
```

Edit `.env` file with your local database settings:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=studentlink
DB_USERNAME=your_username
DB_PASSWORD=your_password

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379
```

### 3. Generate Application Key
```bash
php artisan key:generate
```

### 4. Database Setup
```bash
# Create database
mysql -u root -p
CREATE DATABASE studentlink;
exit

# Run migrations
php artisan migrate

# Seed the database
php artisan db:seed
```

### 5. Create Test Users (Optional)
```bash
php database/scripts/create_users.php
```

## Running the Application

### Start the Development Server
```bash
php artisan serve
```

The API will be available at: `http://localhost:8000`

### API Endpoints
- Base URL: `http://localhost:8000/api`
- Authentication: JWT tokens
- Documentation: Available in `docs/api-specification.yaml`

## Development Commands

### Database Operations
```bash
# Run migrations
php artisan migrate

# Rollback migrations
php artisan migrate:rollback

# Seed database
php artisan db:seed

# Fresh migration with seeding
php artisan migrate:fresh --seed
```

### Cache Management
```bash
# Clear all caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Optimize for production
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### Testing
```bash
# Run tests
php artisan test

# Run specific test
php artisan test --filter=AuthTest
```

## Project Structure

```
studentlink_backend/
├── app/
│   ├── Http/Controllers/     # API Controllers
│   ├── Models/              # Eloquent Models
│   ├── Services/            # Business Logic
│   └── ...
├── database/
│   ├── migrations/          # Database migrations
│   ├── seeders/            # Database seeders
│   └── scripts/            # Utility scripts
├── routes/
│   └── api.php             # API routes
└── ...
```

## API Authentication

The API uses JWT authentication. Include the token in the Authorization header:
```
Authorization: Bearer your_jwt_token_here
```

## Troubleshooting

### Common Issues

1. **Database Connection Error**
   - Check MySQL is running
   - Verify database credentials in `.env`
   - Ensure database exists

2. **Permission Errors**
   - Set proper permissions on `storage/` and `bootstrap/cache/`
   - Run: `chmod -R 775 storage bootstrap/cache`

3. **Composer Issues**
   - Update Composer: `composer self-update`
   - Clear Composer cache: `composer clear-cache`

## Development Tips

- Use `php artisan tinker` for interactive PHP shell
- Check logs in `storage/logs/laravel.log`
- Use `php artisan route:list` to see all routes
- Enable debug mode in `.env` for development: `APP_DEBUG=true`
