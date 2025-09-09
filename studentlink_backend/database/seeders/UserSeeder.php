<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Department;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get departments
        $adminDept = Department::where('code', 'ADMIN')->first();
        $bsitDept = Department::where('code', 'BSIT')->first();
        $bsceDept = Department::where('code', 'BSCE')->first();
        $bsbaDept = Department::where('code', 'BSBA')->first();
        $bscrimDept = Department::where('code', 'BSCRIM')->first();
        $beedDept = Department::where('code', 'BEED')->first();
        $bshmDept = Department::where('code', 'BSHM')->first();
        $registrarDept = Department::where('code', 'REG')->first();
        $misDept = Department::where('code', 'MIS')->first();
        $podDept = Department::where('code', 'POD')->first();
        $libraryDept = Department::where('code', 'LIB')->first();
        $securityDept = Department::where('code', 'SEC')->first();

        $users = [
            // ADMIN ACCOUNTS
            [
                'employee_id' => 'ADMIN001',
                'name' => 'Dr. Maria Santos',
                'email' => 'admin@bestlink.edu.ph',
                'password' => Hash::make('admin123'),
                'role' => 'admin',
                'department_id' => $adminDept->id,
                'phone' => '+63-917-123-4567',
                'is_active' => true,
                'preferences' => [
                    'theme' => 'light',
                    'notifications' => [
                        'email' => true,
                        'push' => true,
                        'sms' => false
                    ],
                    'language' => 'en'
                ]
            ],

            // DEPARTMENT HEAD ACCOUNTS
            [
                'employee_id' => 'DEPT001',
                'name' => 'Prof. Juan Dela Cruz',
                'email' => 'depthead@bestlink.edu.ph',
                'password' => Hash::make('dept123'),
                'role' => 'department_head',
                'department_id' => $bsitDept->id,
                'phone' => '+63-917-123-4568',
                'is_active' => true,
                'preferences' => [
                    'theme' => 'light',
                    'notifications' => [
                        'email' => true,
                        'push' => true,
                        'sms' => true
                    ],
                    'language' => 'en'
                ]
            ],

            // STAFF ACCOUNTS
            [
                'employee_id' => 'STAFF001',
                'name' => 'Ms. Ana Rodriguez',
                'email' => 'staff@bestlink.edu.ph',
                'password' => Hash::make('staff123'),
                'role' => 'staff',
                'department_id' => $registrarDept->id,
                'phone' => '+63-917-123-4569',
                'is_active' => true,
                'preferences' => [
                    'theme' => 'light',
                    'notifications' => [
                        'email' => true,
                        'push' => true,
                        'sms' => false
                    ],
                    'language' => 'en'
                ]
            ],

            // FACULTY ACCOUNTS
            [
                'employee_id' => 'FAC001',
                'name' => 'Prof. Roberto Garcia',
                'email' => 'faculty@bestlink.edu.ph',
                'password' => Hash::make('faculty123'),
                'role' => 'faculty',
                'department_id' => $bsceDept->id,
                'phone' => '+63-917-123-4570',
                'is_active' => true,
                'preferences' => [
                    'theme' => 'light',
                    'notifications' => [
                        'email' => true,
                        'push' => true,
                        'sms' => false
                    ],
                    'language' => 'en'
                ]
            ],

            // STUDENT ACCOUNTS (for mobile app testing)
            [
                'student_id' => '2024-00001',
                'name' => 'John Michael Smith',
                'email' => 'student@bestlink.edu.ph',
                'password' => Hash::make('student123'),
                'role' => 'student',
                'department_id' => $bsitDept->id,
                'phone' => '+63-917-123-4571',
                'is_active' => true,
                'preferences' => [
                    'theme' => 'light',
                    'notifications' => [
                        'email' => true,
                        'push' => true,
                        'sms' => true
                    ],
                    'language' => 'en'
                ]
            ],

            // Additional staff for different departments
            [
                'employee_id' => 'STAFF002',
                'name' => 'Mr. Carlos Mendoza',
                'email' => 'mis.staff@bestlink.edu.ph',
                'password' => Hash::make('mis123'),
                'role' => 'staff',
                'department_id' => $misDept->id,
                'phone' => '+63-917-123-4572',
                'is_active' => true,
                'preferences' => [
                    'theme' => 'light',
                    'notifications' => [
                        'email' => true,
                        'push' => true,
                        'sms' => false
                    ],
                    'language' => 'en'
                ]
            ],

            [
                'employee_id' => 'STAFF003',
                'name' => 'Ms. Lisa Chen',
                'email' => 'library.staff@bestlink.edu.ph',
                'password' => Hash::make('library123'),
                'role' => 'staff',
                'department_id' => $libraryDept->id,
                'phone' => '+63-917-123-4573',
                'is_active' => true,
                'preferences' => [
                    'theme' => 'light',
                    'notifications' => [
                        'email' => true,
                        'push' => true,
                        'sms' => false
                    ],
                    'language' => 'en'
                ]
            ],

            // Additional faculty members
            [
                'employee_id' => 'FAC002',
                'name' => 'Dr. Sarah Johnson',
                'email' => 'bsba.faculty@bestlink.edu.ph',
                'password' => Hash::make('bsba123'),
                'role' => 'faculty',
                'department_id' => $bsbaDept->id,
                'phone' => '+63-917-123-4574',
                'is_active' => true,
                'preferences' => [
                    'theme' => 'light',
                    'notifications' => [
                        'email' => true,
                        'push' => true,
                        'sms' => false
                    ],
                    'language' => 'en'
                ]
            ],

            [
                'employee_id' => 'FAC003',
                'name' => 'Prof. Michael Brown',
                'email' => 'bscrim.faculty@bestlink.edu.ph',
                'password' => Hash::make('bscrim123'),
                'role' => 'faculty',
                'department_id' => $bscrimDept->id,
                'phone' => '+63-917-123-4575',
                'is_active' => true,
                'preferences' => [
                    'theme' => 'light',
                    'notifications' => [
                        'email' => true,
                        'push' => true,
                        'sms' => false
                    ],
                    'language' => 'en'
                ]
            ],

            // Additional students for testing
            [
                'student_id' => '2024-00002',
                'name' => 'Maria Garcia',
                'email' => 'student2@bestlink.edu.ph',
                'password' => Hash::make('student123'),
                'role' => 'student',
                'department_id' => $bsbaDept->id,
                'phone' => '+63-917-123-4576',
                'is_active' => true,
                'preferences' => [
                    'theme' => 'light',
                    'notifications' => [
                        'email' => true,
                        'push' => true,
                        'sms' => true
                    ],
                    'language' => 'en'
                ]
            ],

            [
                'student_id' => '2024-00003',
                'name' => 'David Wilson',
                'email' => 'student3@bestlink.edu.ph',
                'password' => Hash::make('student123'),
                'role' => 'student',
                'department_id' => $bscrimDept->id,
                'phone' => '+63-917-123-4577',
                'is_active' => true,
                'preferences' => [
                    'theme' => 'light',
                    'notifications' => [
                        'email' => true,
                        'push' => true,
                        'sms' => true
                    ],
                    'language' => 'en'
                ]
            ]
        ];

        foreach ($users as $user) {
            User::create($user);
        }
    }
}
