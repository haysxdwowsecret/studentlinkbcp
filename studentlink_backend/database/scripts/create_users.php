<?php

require_once 'vendor/autoload.php';

// Load environment variables
$dotenv = Dotenv\Dotenv::createImmutable(__DIR__ . '/../..');
$dotenv->load();

// Database connection
$host = $_ENV['DB_HOST'] ?? 'db';
$port = $_ENV['DB_PORT'] ?? '3306';
$database = $_ENV['DB_DATABASE'] ?? 'studentlink';
$username = $_ENV['DB_USERNAME'] ?? 'studentlink';
$password = $_ENV['DB_PASSWORD'] ?? 'studentlink';

try {
    $pdo = new PDO("mysql:host=$host;port=$port;dbname=$database", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "Connected to database successfully!\n";
    
    // Create departments first
    $departments = [
        ['name' => 'Administration', 'code' => 'ADMIN', 'type' => 'administrative'],
        ['name' => 'BS Information Technology', 'code' => 'BSIT', 'type' => 'academic'],
        ['name' => 'BS Computer Engineering', 'code' => 'BSCE', 'type' => 'academic'],
        ['name' => 'BS Business Administration', 'code' => 'BSBA', 'type' => 'academic'],
        ['name' => 'BS Criminology', 'code' => 'BSCRIM', 'type' => 'academic'],
        ['name' => 'Bachelor of Elementary Education', 'code' => 'BEED', 'type' => 'academic'],
        ['name' => 'BS Hospitality Management', 'code' => 'BSHM', 'type' => 'academic'],
        ['name' => 'Registrar Office', 'code' => 'REG', 'type' => 'administrative'],
        ['name' => 'MIS Department', 'code' => 'MIS', 'type' => 'administrative'],
        ['name' => 'Prefect of Discipline', 'code' => 'POD', 'type' => 'administrative'],
        ['name' => 'Library', 'code' => 'LIB', 'type' => 'administrative'],
        ['name' => 'Security', 'code' => 'SEC', 'type' => 'administrative']
    ];
    
    // Insert departments
    $deptStmt = $pdo->prepare("INSERT INTO departments (name, code, description, type, is_active, contact_info, created_at, updated_at) VALUES (?, ?, ?, ?, 1, ?, NOW(), NOW())");
    
    foreach ($departments as $dept) {
        $contactInfo = json_encode([
            'email' => strtolower($dept['code']) . '@bestlink.edu.ph',
            'phone' => '+63-2-8123-4567',
            'office' => 'Main Building'
        ]);
        
        $deptStmt->execute([
            $dept['name'],
            $dept['code'],
            $dept['name'] . ' Department',
            $dept['type'],
            $contactInfo
        ]);
        
        echo "Created department: " . $dept['name'] . "\n";
    }
    
    // Get department IDs
    $deptIds = [];
    $deptQuery = $pdo->query("SELECT id, code FROM departments");
    while ($row = $deptQuery->fetch(PDO::FETCH_ASSOC)) {
        $deptIds[$row['code']] = $row['id'];
    }
    
    // Create users
    $users = [
        [
            'employee_id' => 'ADMIN001',
            'name' => 'Dr. Maria Santos',
            'email' => 'admin@bestlink.edu.ph',
            'password' => password_hash('admin123', PASSWORD_DEFAULT),
            'role' => 'admin',
            'department_code' => 'ADMIN',
            'phone' => '+63-917-123-4567'
        ],
        [
            'employee_id' => 'DEPT001',
            'name' => 'Prof. Juan Dela Cruz',
            'email' => 'depthead@bestlink.edu.ph',
            'password' => password_hash('dept123', PASSWORD_DEFAULT),
            'role' => 'department_head',
            'department_code' => 'BSIT',
            'phone' => '+63-917-123-4568'
        ],
        [
            'employee_id' => 'STAFF001',
            'name' => 'Ms. Ana Rodriguez',
            'email' => 'staff@bestlink.edu.ph',
            'password' => password_hash('staff123', PASSWORD_DEFAULT),
            'role' => 'staff',
            'department_code' => 'REG',
            'phone' => '+63-917-123-4569'
        ],
        [
            'employee_id' => 'FAC001',
            'name' => 'Prof. Roberto Garcia',
            'email' => 'faculty@bestlink.edu.ph',
            'password' => password_hash('faculty123', PASSWORD_DEFAULT),
            'role' => 'faculty',
            'department_code' => 'BSCE',
            'phone' => '+63-917-123-4570'
        ],
        [
            'student_id' => '2024-00001',
            'name' => 'John Michael Smith',
            'email' => 'student@bestlink.edu.ph',
            'password' => password_hash('student123', PASSWORD_DEFAULT),
            'role' => 'student',
            'department_code' => 'BSIT',
            'phone' => '+63-917-123-4571'
        ]
    ];
    
    // Insert users
    $userStmt = $pdo->prepare("INSERT INTO app_users (student_id, employee_id, name, email, password, role, department_id, phone, is_active, preferences, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, ?, NOW(), NOW())");
    
    foreach ($users as $user) {
        $preferences = json_encode([
            'theme' => 'light',
            'notifications' => [
                'email' => true,
                'push' => true,
                'sms' => false
            ],
            'language' => 'en'
        ]);
        
        $userStmt->execute([
            $user['student_id'] ?? null,
            $user['employee_id'] ?? null,
            $user['name'],
            $user['email'],
            $user['password'],
            $user['role'],
            $deptIds[$user['department_code']],
            $user['phone'],
            $preferences
        ]);
        
        echo "Created user: " . $user['name'] . " (" . $user['email'] . ")\n";
    }
    
    echo "\n✅ All users created successfully!\n";
    echo "\n📋 Login Credentials:\n";
    echo "Admin: admin@bestlink.edu.ph / admin123\n";
    echo "Department Head: depthead@bestlink.edu.ph / dept123\n";
    echo "Staff: staff@bestlink.edu.ph / staff123\n";
    echo "Faculty: faculty@bestlink.edu.ph / faculty123\n";
    echo "Student: student@bestlink.edu.ph / student123\n";
    
} catch (PDOException $e) {
    echo "Database error: " . $e->getMessage() . "\n";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
