"use client"

import { RoleBasedNav } from "@/components/navigation/role-based-nav"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { BookOpen, Users, Calendar, Clock, FileText, Video } from "lucide-react"

export default function FacultyCoursesPage() {
  // Mock data for courses
  const courses = [
    {
      id: 1,
      code: "CS101",
      title: "Introduction to Programming",
      description: "Fundamental concepts of programming using Python",
      schedule: "MWF 9:00-10:30 AM",
      room: "Room 301, IT Building",
      students: 35,
      maxStudents: 40,
      semester: "1st Semester 2024-2025",
      status: "active",
      nextClass: "2024-01-16 09:00",
      materials: 12,
      assignments: 5,
    },
    {
      id: 2,
      code: "CS102",
      title: "Data Structures and Algorithms",
      description: "Advanced programming concepts and algorithm design",
      schedule: "TTh 2:00-3:30 PM",
      room: "Room 205, IT Building",
      students: 28,
      maxStudents: 35,
      semester: "1st Semester 2024-2025",
      status: "active",
      nextClass: "2024-01-16 14:00",
      materials: 18,
      assignments: 7,
    },
    {
      id: 3,
      code: "CS103",
      title: "Database Systems",
      description: "Database design, SQL, and database management systems",
      schedule: "MW 3:30-5:00 PM",
      room: "Room 102, IT Building",
      students: 22,
      maxStudents: 30,
      semester: "1st Semester 2024-2025",
      status: "active",
      nextClass: "2024-01-17 15:30",
      materials: 15,
      assignments: 4,
    },
  ]

  const getStatusColor = (status: string) => {
    switch (status) {
      case "active":
        return "bg-green-100 text-green-800"
      case "completed":
        return "bg-blue-100 text-blue-800"
      case "upcoming":
        return "bg-yellow-100 text-yellow-800"
      default:
        return "bg-gray-100 text-gray-800"
    }
  }

  const getEnrollmentColor = (current: number, max: number) => {
    const percentage = (current / max) * 100
    if (percentage >= 90) return "bg-red-100 text-red-800"
    if (percentage >= 75) return "bg-yellow-100 text-yellow-800"
    return "bg-green-100 text-green-800"
  }

  return (
    <div className="flex h-screen bg-gray-50">
      <RoleBasedNav />

      <div className="flex-1 overflow-y-auto">
        <header className="bg-white shadow-sm border-b border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-bold text-[#1E2A78]">My Courses</h1>
              <p className="text-gray-600">Manage your teaching assignments and course materials</p>
            </div>
            <div className="flex items-center space-x-4">
              <Badge className="bg-blue-100 text-blue-800">1st Semester 2024-2025</Badge>
              <Button className="bg-[#1E2A78] hover:bg-[#2480EA]">
                <BookOpen className="h-4 w-4 mr-2" />
                Add Course Material
              </Button>
            </div>
          </div>
        </header>

        <div className="p-6">
          {/* Course Statistics */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
            <Card>
              <CardContent className="p-6">
                <div className="flex items-center">
                  <BookOpen className="h-8 w-8 text-[#1E2A78]" />
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-600">Total Courses</p>
                    <p className="text-2xl font-bold text-[#1E2A78]">{courses.length}</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="p-6">
                <div className="flex items-center">
                  <Users className="h-8 w-8 text-[#2480EA]" />
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-600">Total Students</p>
                    <p className="text-2xl font-bold text-[#1E2A78]">
                      {courses.reduce((sum, course) => sum + course.students, 0)}
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="p-6">
                <div className="flex items-center">
                  <FileText className="h-8 w-8 text-[#DFD10F]" />
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-600">Course Materials</p>
                    <p className="text-2xl font-bold text-[#1E2A78]">
                      {courses.reduce((sum, course) => sum + course.materials, 0)}
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="p-6">
                <div className="flex items-center">
                  <Calendar className="h-8 w-8 text-[#E22824]" />
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-600">Assignments</p>
                    <p className="text-2xl font-bold text-[#1E2A78]">
                      {courses.reduce((sum, course) => sum + course.assignments, 0)}
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Courses List */}
          <div className="space-y-6">
            <h2 className="text-xl font-semibold text-[#1E2A78]">Course List</h2>
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              {courses.map((course) => (
                <Card key={course.id} className="hover:shadow-lg transition-shadow">
                  <CardHeader>
                    <div className="flex items-start justify-between">
                      <div>
                        <CardTitle className="text-xl text-[#1E2A78]">
                          {course.code} - {course.title}
                        </CardTitle>
                        <CardDescription className="mt-2">{course.description}</CardDescription>
                      </div>
                      <Badge className={getStatusColor(course.status)}>{course.status.toUpperCase()}</Badge>
                    </div>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    {/* Schedule and Location */}
                    <div className="space-y-2">
                      <div className="flex items-center text-sm text-gray-600">
                        <Clock className="h-4 w-4 mr-2" />
                        {course.schedule}
                      </div>
                      <div className="flex items-center text-sm text-gray-600">
                        <Calendar className="h-4 w-4 mr-2" />
                        {course.room}
                      </div>
                    </div>

                    {/* Enrollment */}
                    <div className="flex items-center justify-between">
                      <div className="flex items-center">
                        <Users className="h-4 w-4 mr-2 text-gray-400" />
                        <span className="text-sm text-gray-600">Enrollment</span>
                      </div>
                      <Badge className={getEnrollmentColor(course.students, course.maxStudents)}>
                        {course.students}/{course.maxStudents}
                      </Badge>
                    </div>

                    {/* Course Stats */}
                    <div className="grid grid-cols-2 gap-4 pt-4 border-t border-gray-200">
                      <div className="text-center">
                        <div className="text-lg font-semibold text-[#1E2A78]">{course.materials}</div>
                        <div className="text-xs text-gray-500">Materials</div>
                      </div>
                      <div className="text-center">
                        <div className="text-lg font-semibold text-[#1E2A78]">{course.assignments}</div>
                        <div className="text-xs text-gray-500">Assignments</div>
                      </div>
                    </div>

                    {/* Next Class */}
                    <div className="bg-blue-50 p-3 rounded-lg">
                      <div className="flex items-center justify-between">
                        <div>
                          <p className="text-sm font-medium text-blue-800">Next Class</p>
                          <p className="text-xs text-blue-600">{course.nextClass}</p>
                        </div>
                        <Button size="sm" variant="outline" className="text-blue-600 border-blue-200 bg-transparent">
                          <Video className="h-4 w-4 mr-1" />
                          Join
                        </Button>
                      </div>
                    </div>

                    {/* Action Buttons */}
                    <div className="flex space-x-2 pt-2">
                      <Button variant="outline" className="flex-1 bg-transparent" size="sm">
                        <Users className="h-4 w-4 mr-2" />
                        View Students
                      </Button>
                      <Button variant="outline" className="flex-1 bg-transparent" size="sm">
                        <FileText className="h-4 w-4 mr-2" />
                        Materials
                      </Button>
                      <Button className="flex-1 bg-[#1E2A78] hover:bg-[#2480EA]" size="sm">
                        <BookOpen className="h-4 w-4 mr-2" />
                        Manage
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
