"use client"

import { RoleBasedNav } from "@/components/navigation/role-based-nav"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Users, Search, Filter, Mail, Phone, MapPin, Calendar, Plus, Edit } from "lucide-react"
import { useState } from "react"

export default function DepartmentHeadStaffPage() {
  const [selectedStaff, setSelectedStaff] = useState<any>(null)

  // Mock data for department staff
  const staffMembers = [
    {
      id: 1,
      name: "Jay Literal",
      position: "Senior Faculty",
      department: "Information Technology",
      email: "maria.garcia@bestlink.edu.ph",
      phone: "+63 912 345 6789",
      office: "Room 301, IT Building",
      specialization: "Database Systems, Web Development",
      courses: ["CS103 - Database Systems", "CS104 - Web Development"],
      students: 65,
      concerns: 8,
      status: "active",
      joinDate: "2020-08-15",
      performance: "excellent",
    },
    {
      id: 2,
      name: "Jay Literal",
      position: "Faculty",
      department: "Information Technology",
      email: "john.santos@bestlink.edu.ph",
      phone: "+63 912 345 6790",
      office: "Room 302, IT Building",
      specialization: "Programming, Software Engineering",
      courses: ["CS101 - Introduction to Programming", "CS105 - Software Engineering"],
      students: 72,
      concerns: 12,
      status: "active",
      joinDate: "2021-06-01",
      performance: "good",
    },
    {
      id: 3,
      name: "Jay Literal",
      position: "Assistant Faculty",
      department: "Information Technology",
      email: "ana.rodriguez@bestlink.edu.ph",
      phone: "+63 912 345 6791",
      office: "Room 205, IT Building",
      specialization: "Mobile Development, UI/UX Design",
      courses: ["CS106 - Mobile Development"],
      students: 45,
      concerns: 5,
      status: "active",
      joinDate: "2022-01-10",
      performance: "good",
    },
    {
      id: 4,
      name: "Jay Literal",
      position: "Staff",
      department: "Information Technology",
      email: "carlos.delacruz@bestlink.edu.ph",
      phone: "+63 912 345 6792",
      office: "Room 101, IT Building",
      specialization: "Technical Support, Lab Management",
      courses: [],
      students: 0,
      concerns: 3,
      status: "active",
      joinDate: "2019-03-20",
      performance: "excellent",
    },
  ]

  const getStatusColor = (status: string) => {
    switch (status) {
      case "active":
        return "bg-green-100 text-green-800"
      case "inactive":
        return "bg-red-100 text-red-800"
      case "on_leave":
        return "bg-yellow-100 text-yellow-800"
      default:
        return "bg-gray-100 text-gray-800"
    }
  }

  const getPerformanceColor = (performance: string) => {
    switch (performance) {
      case "excellent":
        return "bg-green-100 text-green-800"
      case "good":
        return "bg-blue-100 text-blue-800"
      case "satisfactory":
        return "bg-yellow-100 text-yellow-800"
      case "needs_improvement":
        return "bg-red-100 text-red-800"
      default:
        return "bg-gray-100 text-gray-800"
    }
  }

  return (
    <div className="flex h-screen bg-gray-50">
      <RoleBasedNav />

      <div className="flex-1 flex flex-col overflow-hidden">
        <header className="bg-white shadow-sm border-b border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-bold text-[#1E2A78]">Manage Staff</h1>
              <p className="text-gray-600">Oversee department faculty and staff members</p>
            </div>
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2">
                <Search className="h-4 w-4 text-gray-400" />
                <Input placeholder="Search staff..." className="w-64" />
              </div>
              <Select>
                <SelectTrigger className="w-40">
                  <Filter className="h-4 w-4 mr-2" />
                  <SelectValue placeholder="Filter" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Staff</SelectItem>
                  <SelectItem value="faculty">Faculty</SelectItem>
                  <SelectItem value="staff">Staff</SelectItem>
                  <SelectItem value="active">Active</SelectItem>
                  <SelectItem value="inactive">Inactive</SelectItem>
                </SelectContent>
              </Select>
              <Button className="bg-[#1E2A78] hover:bg-[#2480EA]">
                <Plus className="h-4 w-4 mr-2" />
                Add Staff Member
              </Button>
            </div>
          </div>
        </header>

        <div className="flex-1 flex overflow-hidden">
          {/* Staff List */}
          <div className="w-1/2 border-r border-gray-200 overflow-y-auto">
            <div className="p-4 space-y-4">
              {staffMembers.map((staff) => (
                <Card
                  key={staff.id}
                  className={`cursor-pointer transition-colors hover:bg-gray-50 ${
                    selectedStaff?.id === staff.id ? "ring-2 ring-[#2480EA]" : ""
                  }`}
                  onClick={() => setSelectedStaff(staff)}
                >
                  <CardHeader className="pb-3">
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <CardTitle className="text-lg text-[#1E2A78]">{staff.name}</CardTitle>
                        <CardDescription className="mt-1">
                          {staff.position} • {staff.department}
                        </CardDescription>
                      </div>
                      <div className="flex flex-col items-end space-y-2">
                        <Badge className={getStatusColor(staff.status)}>{staff.status.toUpperCase()}</Badge>
                        <Badge className={getPerformanceColor(staff.performance)}>
                          {staff.performance.toUpperCase()}
                        </Badge>
                      </div>
                    </div>
                  </CardHeader>
                  <CardContent>
                    <p className="text-gray-600 text-sm mb-2">{staff.specialization}</p>
                    <div className="flex items-center justify-between text-sm text-gray-500">
                      <div className="flex items-center">
                        <MapPin className="h-4 w-4 mr-1" />
                        {staff.office}
                      </div>
                      <div className="flex items-center space-x-4">
                        <span>Students: {staff.students}</span>
                        {staff.concerns > 0 && <Badge variant="destructive">{staff.concerns} concerns</Badge>}
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          </div>

          {/* Staff Details */}
          <div className="w-1/2 flex flex-col">
            {selectedStaff ? (
              <div className="p-6 overflow-y-auto">
                <div className="mb-6">
                  <div className="flex items-start justify-between mb-4">
                    <div>
                      <h2 className="text-2xl font-bold text-[#1E2A78] mb-2">{selectedStaff.name}</h2>
                      <p className="text-gray-600">{selectedStaff.position}</p>
                      <p className="text-sm text-gray-500">{selectedStaff.department}</p>
                    </div>
                    <div className="flex space-x-2">
                      <Button variant="outline" size="sm">
                        <Edit className="h-4 w-4 mr-2" />
                        Edit
                      </Button>
                      <Button variant="outline" size="sm">
                        <Mail className="h-4 w-4 mr-2" />
                        Email
                      </Button>
                    </div>
                  </div>
                </div>

                {/* Contact Information */}
                <Card className="mb-6">
                  <CardHeader>
                    <CardTitle className="text-lg">Contact Information</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-3">
                    <div className="flex items-center">
                      <Mail className="h-4 w-4 mr-3 text-gray-400" />
                      <span className="text-sm">{selectedStaff.email}</span>
                    </div>
                    <div className="flex items-center">
                      <Phone className="h-4 w-4 mr-3 text-gray-400" />
                      <span className="text-sm">{selectedStaff.phone}</span>
                    </div>
                    <div className="flex items-center">
                      <MapPin className="h-4 w-4 mr-3 text-gray-400" />
                      <span className="text-sm">{selectedStaff.office}</span>
                    </div>
                    <div className="flex items-center">
                      <Calendar className="h-4 w-4 mr-3 text-gray-400" />
                      <span className="text-sm">Joined: {selectedStaff.joinDate}</span>
                    </div>
                  </CardContent>
                </Card>

                {/* Performance Overview */}
                <Card className="mb-6">
                  <CardHeader>
                    <CardTitle className="text-lg">Performance Overview</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="grid grid-cols-3 gap-4 mb-4">
                      <div className="text-center p-4 bg-gray-50 rounded-lg">
                        <div className="text-2xl font-bold text-[#1E2A78]">{selectedStaff.students}</div>
                        <div className="text-sm text-gray-600">Students</div>
                      </div>
                      <div className="text-center p-4 bg-gray-50 rounded-lg">
                        <div className="text-2xl font-bold text-[#1E2A78]">{selectedStaff.courses.length}</div>
                        <div className="text-sm text-gray-600">Courses</div>
                      </div>
                      <div className="text-center p-4 bg-gray-50 rounded-lg">
                        <div className="text-2xl font-bold text-[#1E2A78]">{selectedStaff.concerns}</div>
                        <div className="text-sm text-gray-600">Concerns</div>
                      </div>
                    </div>
                    <div className="flex space-x-2">
                      <Badge className={getStatusColor(selectedStaff.status)}>
                        Status: {selectedStaff.status.replace("_", " ").toUpperCase()}
                      </Badge>
                      <Badge className={getPerformanceColor(selectedStaff.performance)}>
                        Performance: {selectedStaff.performance.replace("_", " ").toUpperCase()}
                      </Badge>
                    </div>
                  </CardContent>
                </Card>

                {/* Specialization */}
                <Card className="mb-6">
                  <CardHeader>
                    <CardTitle className="text-lg">Specialization</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <p className="text-gray-700">{selectedStaff.specialization}</p>
                  </CardContent>
                </Card>

                {/* Assigned Courses */}
                <Card className="mb-6">
                  <CardHeader>
                    <CardTitle className="text-lg">Assigned Courses</CardTitle>
                  </CardHeader>
                  <CardContent>
                    {selectedStaff.courses.length > 0 ? (
                      <div className="space-y-2">
                        {selectedStaff.courses.map((course: string, index: number) => (
                          <div key={index} className="flex items-center p-3 bg-gray-50 rounded-lg">
                            <span className="text-sm">{course}</span>
                          </div>
                        ))}
                      </div>
                    ) : (
                      <p className="text-gray-500 text-sm">No courses assigned</p>
                    )}
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
                          <p className="text-sm font-medium">Responded to Student Concern</p>
                          <p className="text-xs text-gray-500">Database connection issue</p>
                        </div>
                        <span className="text-xs text-gray-500">2 hours ago</span>
                      </div>
                      <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                        <div>
                          <p className="text-sm font-medium">Updated Course Materials</p>
                          <p className="text-xs text-gray-500">CS103 - Database Systems</p>
                        </div>
                        <span className="text-xs text-gray-500">1 day ago</span>
                      </div>
                      <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                        <div>
                          <p className="text-sm font-medium">Submitted Grade Reports</p>
                          <p className="text-xs text-gray-500">Midterm evaluations</p>
                        </div>
                        <span className="text-xs text-gray-500">3 days ago</span>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </div>
            ) : (
              <div className="flex-1 flex items-center justify-center text-gray-500">
                <div className="text-center">
                  <Users className="h-12 w-12 mx-auto mb-4 text-gray-300" />
                  <p>Select a staff member to view details</p>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
