# StudentLink Database Setup

## Overview
The StudentLink database has been consolidated into a single comprehensive setup file that addresses all previous issues and follows best practices.

## Files

### `database_setup_complete.php`
- **Purpose**: Complete database setup in one file
- **Features**: All tables, relationships, indexes, and seed data
- **Usage**: `php database_setup_complete.php`

### `database/migrations_backup/`
- **Purpose**: Backup of old migration files
- **Status**: Archived (no longer used)

## Database Structure

### Core Tables (16 total)
1. **departments** - Department information
2. **users** - User accounts (standardized name)
3. **facilities** - Campus facilities
4. **concerns** - Student concerns
5. **chat_rooms** - Real-time chat rooms for concerns
6. **concern_messages** - Concern communication (enhanced for chat)
7. **concern_feedback** - Concern feedback and ratings
8. **announcements** - System announcements
9. **announcement_bookmarks** - User bookmarks
10. **emergency_contacts** - Emergency contact info
11. **emergency_protocols** - Emergency procedures
12. **notifications** - System notifications
13. **fcm_tokens** - Mobile push notifications
14. **audit_logs** - System audit trail
15. **ai_chat_sessions** - AI assistant sessions
16. **system_settings** - System configuration

## Issues Resolved

### ✅ Naming Inconsistency
- **Before**: Mixed `users` and `app_users` references
- **After**: Standardized to `users` table name

### ✅ Dependency Order
- **Before**: Potential foreign key constraint issues
- **After**: Proper table creation order with dependency management

### ✅ Performance Optimization
- **Before**: Missing indexes for large datasets
- **After**: Comprehensive indexing strategy

### ✅ Seed Data
- **Before**: Scattered across multiple seeders
- **After**: Complete seed data in one place

## Seed Data Included

### Departments (28 total)
- **Administrative**: 6 departments (Registrar, Cashier, Bookstore, etc.)
- **Academic**: 22 departments (BSAIS, BSBA, BSCPE, etc.)

### User Accounts
- **Super Admin**: 1 account (`admin@bcp.edu.ph`)
- **Department Heads**: 28 accounts (one per department)

### Sample Data
- **Facilities**: 3 sample facilities
- **Emergency Contacts**: 3 emergency contacts
- **System Settings**: 5 configuration settings

## Login Credentials

### Super Admin
- **Email**: `admin@bcp.edu.ph`
- **Password**: `department@2025`

### Department Heads
- **Email**: `[department_email]@bcp.edu.ph`
- **Password**: `department2025`
- **Examples**:
  - `registrar@bcp.edu.ph`
  - `bsit@bcp.edu.ph`
  - `beed@bcp.edu.ph`

## Usage Instructions

### Fresh Installation
```bash
# Run the complete database setup
php database_setup_complete.php
```

### Verification
```bash
# Check database status
php artisan tinker --execute="echo 'Departments: ' . App\Models\Department::count();"
```

## Benefits

### ✅ Single Source of Truth
- All database structure in one file
- No migration conflicts
- Easy to understand and maintain

### ✅ Production Ready
- Proper foreign key constraints
- Performance indexes
- Complete audit trail
- Error handling

### ✅ Best Practices
- Standardized naming conventions
- Proper data types
- Comprehensive documentation
- Clean code structure

## Migration from Old System

If migrating from the old migration system:

1. **Backup existing data** (if any)
2. **Run the consolidated setup**: `php database_setup_complete.php`
3. **Verify data integrity**
4. **Update application code** to use `users` instead of `app_users`

## Support

For issues or questions about the database setup, refer to the comprehensive error handling and logging built into the setup script.
