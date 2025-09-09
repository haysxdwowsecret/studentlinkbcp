<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Department;

class DepartmentSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $departments = [
            [
                'name' => 'Administration',
                'code' => 'ADMIN',
                'description' => 'College Administration and Management',
                'type' => 'administrative',
                'is_active' => true,
                'contact_info' => [
                    'email' => 'admin@bestlink.edu.ph',
                    'phone' => '+63-2-8123-4567',
                    'office' => 'Main Building, 2nd Floor'
                ]
            ],
            [
                'name' => 'BS Information Technology',
                'code' => 'BSIT',
                'description' => 'Bachelor of Science in Information Technology',
                'type' => 'academic',
                'is_active' => true,
                'contact_info' => [
                    'email' => 'bsit@bestlink.edu.ph',
                    'phone' => '+63-2-8123-4568',
                    'office' => 'IT Building, 1st Floor'
                ]
            ],
            [
                'name' => 'BS Computer Engineering',
                'code' => 'BSCE',
                'description' => 'Bachelor of Science in Computer Engineering',
                'type' => 'academic',
                'is_active' => true,
                'contact_info' => [
                    'email' => 'bsce@bestlink.edu.ph',
                    'phone' => '+63-2-8123-4569',
                    'office' => 'Engineering Building, 2nd Floor'
                ]
            ],
            [
                'name' => 'BS Business Administration',
                'code' => 'BSBA',
                'description' => 'Bachelor of Science in Business Administration',
                'type' => 'academic',
                'is_active' => true,
                'contact_info' => [
                    'email' => 'bsba@bestlink.edu.ph',
                    'phone' => '+63-2-8123-4570',
                    'office' => 'Business Building, 1st Floor'
                ]
            ],
            [
                'name' => 'BS Criminology',
                'code' => 'BSCRIM',
                'description' => 'Bachelor of Science in Criminology',
                'type' => 'academic',
                'is_active' => true,
                'contact_info' => [
                    'email' => 'bscrim@bestlink.edu.ph',
                    'phone' => '+63-2-8123-4571',
                    'office' => 'Criminology Building, 1st Floor'
                ]
            ],
            [
                'name' => 'Bachelor of Elementary Education',
                'code' => 'BEED',
                'description' => 'Bachelor of Elementary Education',
                'type' => 'academic',
                'is_active' => true,
                'contact_info' => [
                    'email' => 'beed@bestlink.edu.ph',
                    'phone' => '+63-2-8123-4572',
                    'office' => 'Education Building, 2nd Floor'
                ]
            ],
            [
                'name' => 'BS Hospitality Management',
                'code' => 'BSHM',
                'description' => 'Bachelor of Science in Hospitality Management',
                'type' => 'academic',
                'is_active' => true,
                'contact_info' => [
                    'email' => 'bshm@bestlink.edu.ph',
                    'phone' => '+63-2-8123-4573',
                    'office' => 'Hospitality Building, 1st Floor'
                ]
            ],
            [
                'name' => 'Registrar Office',
                'code' => 'REG',
                'description' => 'Student Records and Registration',
                'type' => 'administrative',
                'is_active' => true,
                'contact_info' => [
                    'email' => 'registrar@bestlink.edu.ph',
                    'phone' => '+63-2-8123-4574',
                    'office' => 'Main Building, 1st Floor'
                ]
            ],
            [
                'name' => 'MIS Department',
                'code' => 'MIS',
                'description' => 'Management Information Systems',
                'type' => 'administrative',
                'is_active' => true,
                'contact_info' => [
                    'email' => 'mis@bestlink.edu.ph',
                    'phone' => '+63-2-8123-4575',
                    'office' => 'IT Building, 2nd Floor'
                ]
            ],
            [
                'name' => 'Prefect of Discipline',
                'code' => 'POD',
                'description' => 'Student Discipline and Conduct',
                'type' => 'administrative',
                'is_active' => true,
                'contact_info' => [
                    'email' => 'pod@bestlink.edu.ph',
                    'phone' => '+63-2-8123-4576',
                    'office' => 'Main Building, 1st Floor'
                ]
            ],
            [
                'name' => 'Library',
                'code' => 'LIB',
                'description' => 'College Library and Learning Resources',
                'type' => 'administrative',
                'is_active' => true,
                'contact_info' => [
                    'email' => 'library@bestlink.edu.ph',
                    'phone' => '+63-2-8123-4577',
                    'office' => 'Library Building, 1st Floor'
                ]
            ],
            [
                'name' => 'Security',
                'code' => 'SEC',
                'description' => 'Campus Security and Safety',
                'type' => 'administrative',
                'is_active' => true,
                'contact_info' => [
                    'email' => 'security@bestlink.edu.ph',
                    'phone' => '+63-2-8123-4578',
                    'office' => 'Main Gate, Security Office'
                ]
            ]
        ];

        foreach ($departments as $department) {
            Department::create($department);
        }
    }
}
