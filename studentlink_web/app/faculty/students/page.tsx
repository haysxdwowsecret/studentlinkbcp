"use client"

import { RoleBasedNav } from "@/components/navigation/role-based-nav"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Users, Search, Filter, Mail, MessageSquare, GraduationCap, Calendar } from "lucide-react"
import { useState } from "react"

export default function FacultyStudentsPage() {
  const [selectedStudent, setSelectedStudent] = useState<any>(null)

  // Mock data for students
  const students = [
    {
      id: 1,
      name: "Jay Literal",
      studentId: "2024-001234",
      course: "BS Information Technology",
      year: "3rd Year",
      email: "john.delacruz@student.bestlink.edu.ph",
      phone: "+63 912 345 6789",
      enrolledCourses: ["CS101 - Introduction to Programming", "CS102 - Data Structures", "CS103 - Database Systems"],
      gpa: 3.75,
      attendance: 95,
      concerns: 2,
      lastActive: "2024-01-15",
    },
    {
      id: 2,
      name: "Jay Literal",
      studentId: "2024-001235",
      course: "BS Information Technology",
      year: "2nd Year",
      email: "maria.santos@student.bestlink.edu.ph",
      phone: "+63 912 345 6790",
      enrolledCourses: ["CS101 - Introduction to Programming", "CS104 - Web Development"],
      gpa: 3.9,
      attendance: 98,
      concerns: 1,
      lastActive: "2024-01-14",
    },
    {
      id: 3,
      name: "Jay Literal",
      studentId: "2024-001236",
      course: "BS Information Technology",
      year: "4th Year",
      email: "carlos.rodriguez@student.bestlink.edu.ph",
      phone: "+63 912 345 6791",
      enrolledCourses: ["CS105 - Software Engineering", "CS106 - Mobile Development"],
      gpa: 3.6,
      attendance: 92,
      concerns: 0,
      lastActive: "2024-01-13",
    },
  ]

  const getGPAColor = (gpa: number) => {
    if (gpa >= 3.5) return "bg-green-100 text-green-800"
    if (gpa >= 3.0) return "bg-yellow-100 text-yellow-800"
    return "bg-red-100 text-red-800"
  }

  const getAttendanceColor = (attendance: number) => {
    if (attendance >= 95) return "bg-green-100 text-green-800"
    if (attendance >= 85) return "bg-yellow-100 text-yellow-800"
    return "bg-red-100 text-red-800"
  }

  return (
    <div className="flex h-screen bg-gray-50">
      <RoleBasedNav />

      <div className="flex-1 flex flex-col overflow-hidden">
        <header className="bg-white shadow-sm border-b border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-bold text-[#1E2A78]">My Students</h1>
              <p className="text-gray-600">Manage and track your students' progress</p>
            </div>
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2">
                <Search className="h-4 w-4 text-gray-400" />
                <Input placeholder="Search students..." className="w-64" />
              </div>
              <Select>
                <SelectTrigger className="w-40">
                  <Filter className="h-4 w-4 mr-2" />
                  <SelectValue placeholder="Filter" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Years</SelectItem>
                  <SelectItem value="1st">1st Year</SelectItem>
                  <SelectItem value="2nd">2nd Year</SelectItem>
                  <SelectItem value="3rd">3rd Year</SelectItem>
                  <SelectItem value="4th">4th Year</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
        </header>

        <div className="flex-1 flex overflow-hidden">
          {/* Students List */}
          <div className="w-1/2 border-r border-gray-200 overflow-y-auto">
            <div className="p-4 space-y-4">
              {students.map((student) => (
                <Card
                  key={student.id}
                  className={`cursor-pointer transition-colors hover:bg-gray-50 ${
                    selectedStudent?.id === student.id ? "ring-2 ring-[#2480EA]" : ""
                  }`}
                  onClick={() => setSelectedStudent(student)}
                >
                  <CardHeader className="pb-3">
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <CardTitle className="text-lg text-[#1E2A78]">{student.name}</CardTitle>
                        <CardDescription className="mt-1">
                          {student.studentId} • {student.course}
                        </CardDescription>
                      </div>
                      <div className="flex flex-col items-end space-y-2">
                        <Badge className="bg-blue-100 text-blue-800">{student.year}</Badge>
                        <Badge className={getGPAColor(student.gpa)}>GPA: {student.gpa}</Badge>
                      </div>
                    </div>
                  </CardHeader>
                  <CardContent>
                    <div className="flex items-center justify-between text-sm text-gray-500">
                      <div className="flex items-center">
                        <Calendar className="h-4 w-4 mr-1" />
                        Last active: {student.lastActive}
                      </div>
                      <div className="flex items-center space-x-4">
                        <span>Attendance: {student.attendance}%</span>
                        {student.concerns > 0 && <Badge variant="destructive">{student.concerns} concerns</Badge>}
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          </div>

          {/* Student Details */}
          <div className="w-1/2 flex flex-col">
            {selectedStudent ? (
              <div className="p-6 overflow-y-auto">
                <div className="mb-6">
                  <div className="flex items-start justify-between mb-4">
                    <div>
                      <h2 className="text-2xl font-bold text-[#1E2A78] mb-2">{selectedStudent.name}</h2>
                      <p className="text-gray-600">{selectedStudent.studentId}</p>
                      <p className="text-sm text-gray-500">
                        {selectedStudent.course} • {selectedStudent.year}
                      </p>
                    </div>
                    <div className="flex space-x-2">
                      <Button variant="outline" size="sm">
                        <Mail className="h-4 w-4 mr-2" />
                        Email
                      </Button>
                      <Button variant="outline" size="sm">
                        <MessageSquare className="h-4 w-4 mr-2" />
                        Message
                      </Button>
                    </div>
                  </div>
                </div>

                {/* Contact Information */}
                <Card className="mb-6">
                  <CardHeader>
                    <CardTitle className="text-lg">Contact Information</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-2">
                    <div className="flex items-center">
                      <Mail className="h-4 w-4 mr-2 text-gray-400" />
                      <span className="text-sm">{selectedStudent.email}</span>
                    </div>
                    <div className="flex items-center">
                      <span className="h-4 w-4 mr-2 text-gray-400">📱</span>
                      <span className="text-sm">{selectedStudent.phone}</span>
                    </div>
                  </CardContent>
                </Card>

                {/* Academic Performance */}
                <Card className="mb-6">
                  <CardHeader>
                    <CardTitle className="text-lg">Academic Performance</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="grid grid-cols-2 gap-4 mb-4">
                      <div className="text-center p-4 bg-gray-50 rounded-lg">
                        <div className="text-2xl font-bold text-[#1E2A78]">{selectedStudent.gpa}</div>
                        <div className="text-sm text-gray-600">Current GPA</div>
                      </div>
                      <div className="text-center p-4 bg-gray-50 rounded-lg">
                        <div className="text-2xl font-bold text-[#1E2A78]">{selectedStudent.attendance}%</div>
                        <div className="text-sm text-gray-600">Attendance Rate</div>
                      </div>
                    </div>
                    <div className="flex space-x-2">
                      <Badge className={getGPAColor(selectedStudent.gpa)}>
                        GPA:{" "}
                        {selectedStudent.gpa >= 3.5
                          ? "Excellent"
                          : selectedStudent.gpa >= 3.0
                            ? "Good"
                            : "Needs Improvement"}
                      </Badge>
                      <Badge className={getAttendanceColor(selectedStudent.attendance)}>
                        Attendance:{" "}
                        {selectedStudent.attendance >= 95
                          ? "Excellent"
                          : selectedStudent.attendance >= 85
                            ? "Good"
                            : "Poor"}
                      </Badge>
                    </div>
                  </CardContent>
                </Card>

                {/* Enrolled Courses */}
                <Card className="mb-6">
                  <CardHeader>
                    <CardTitle className="text-lg">Enrolled Courses</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-2">
                      {selectedStudent.enrolledCourses.map((course, index) => (
                        <div key={index} className="flex items-center p-3 bg-gray-50 rounded-lg">
                          <GraduationCap className="h-4 w-4 mr-3 text-[#1E2A78]" />
                          <span className="text-sm">{course}</span>
                        </div>
                      ))}
                    </div>
                  </CardContent>
                </Card>

                {/* Recent Activity */}
                <Card>
                  <CardHeader>
                    <CardTitle className="text-lg">Recent Activity</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-3">
                      <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                        <div>
                          <p className="text-sm font-medium">Submitted Assignment</p>
                          <p className="text-xs text-gray-500">CS102 - Data Structures</p>
                        </div>
                        <span className="text-xs text-gray-500">2 days ago</span>
                      </div>
                      <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                        <div>
                          <p className="text-sm font-medium">Attended Class</p>
                          <p className="text-xs text-gray-500">CS101 - Introduction to Programming</p>
                        </div>
                        <span className="text-xs text-gray-500">3 days ago</span>
                      </div>
                      {selectedStudent.concerns > 0 && (
                        <div className="flex items-center justify-between p-3 bg-red-50 rounded-lg">
                          <div>
                            <p className="text-sm font-medium text-red-800">Submitted Concern</p>
                            <p className="text-xs text-red-600">Needs attention</p>
                          </div>
                          <Badge variant="destructive">{selectedStudent.concerns}</Badge>
                        </div>
                      )}
                    </div>
                  </CardContent>
                </Card>
              </div>
            ) : (
              <div className="flex-1 flex items-center justify-center text-gray-500">
                <div className="text-center">
                  <Users className="h-12 w-12 mx-auto mb-4 text-gray-300" />
                  <p>Select a student to view details</p>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
