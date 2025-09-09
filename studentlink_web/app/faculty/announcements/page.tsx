"use client"

import { RoleBasedNav } from "@/components/navigation/role-based-nav"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Bell, Calendar, Search, Filter, Eye, Plus } from "lucide-react"
import { useState } from "react"

export default function FacultyAnnouncementsPage() {
  const [selectedAnnouncement, setSelectedAnnouncement] = useState<any>(null)

  // Mock data for announcements
  const announcements = [
    {
      id: 1,
      title: "Midterm Exam Schedule Released",
      content:
        "The midterm examination schedule for all IT courses has been released. Please check your course schedules and inform students accordingly. Exam period: February 5-12, 2024.",
      author: "Academic Affairs",
      date: "2024-01-15",
      priority: "high",
      department: "IT Department",
      type: "academic",
      targetCourses: ["CS101", "CS102", "CS103"],
    },
    {
      id: 2,
      title: "Faculty Development Workshop",
      content:
        "Join us for a professional development workshop on 'Modern Teaching Methodologies in IT Education' on January 25th, 2024, from 2:00-5:00 PM in Conference Room A.",
      author: "HR Department",
      date: "2024-01-14",
      priority: "medium",
      department: "All Faculty",
      type: "training",
      targetCourses: ["All"],
    },
    {
      id: 3,
      title: "New Learning Management System",
      content:
        "We're transitioning to a new LMS starting next semester. Training sessions will be conducted next week. Please attend your assigned session.",
      author: "IT Support",
      date: "2024-01-13",
      priority: "high",
      department: "All Faculty",
      type: "technical",
      targetCourses: ["All"],
    },
  ]

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case "high":
        return "bg-red-100 text-red-800"
      case "medium":
        return "bg-yellow-100 text-yellow-800"
      case "low":
        return "bg-green-100 text-green-800"
      default:
        return "bg-gray-100 text-gray-800"
    }
  }

  const getTypeColor = (type: string) => {
    switch (type) {
      case "academic":
        return "bg-blue-100 text-blue-800"
      case "technical":
        return "bg-purple-100 text-purple-800"
      case "training":
        return "bg-orange-100 text-orange-800"
      case "general":
        return "bg-green-100 text-green-800"
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
              <h1 className="text-2xl font-bold text-[#1E2A78]">Announcements</h1>
              <p className="text-gray-600">Stay updated with faculty and department notices</p>
            </div>
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2">
                <Search className="h-4 w-4 text-gray-400" />
                <Input placeholder="Search announcements..." className="w-64" />
              </div>
              <Select>
                <SelectTrigger className="w-40">
                  <Filter className="h-4 w-4 mr-2" />
                  <SelectValue placeholder="Filter" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Types</SelectItem>
                  <SelectItem value="academic">Academic</SelectItem>
                  <SelectItem value="technical">Technical</SelectItem>
                  <SelectItem value="training">Training</SelectItem>
                  <SelectItem value="general">General</SelectItem>
                </SelectContent>
              </Select>
              <Button className="bg-[#1E2A78] hover:bg-[#2480EA]">
                <Plus className="h-4 w-4 mr-2" />
                Create Announcement
              </Button>
            </div>
          </div>
        </header>

        <div className="flex-1 flex overflow-hidden">
          {/* Announcements List */}
          <div className="w-1/2 border-r border-gray-200 overflow-y-auto">
            <div className="p-4 space-y-4">
              {announcements.map((announcement) => (
                <Card
                  key={announcement.id}
                  className={`cursor-pointer transition-colors hover:bg-gray-50 ${
                    selectedAnnouncement?.id === announcement.id ? "ring-2 ring-[#2480EA]" : ""
                  }`}
                  onClick={() => setSelectedAnnouncement(announcement)}
                >
                  <CardHeader className="pb-3">
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <CardTitle className="text-lg text-[#1E2A78]">{announcement.title}</CardTitle>
                        <CardDescription className="mt-1">
                          By: {announcement.author} • {announcement.department}
                        </CardDescription>
                      </div>
                      <div className="flex flex-col items-end space-y-2">
                        <Badge className={getPriorityColor(announcement.priority)}>
                          {announcement.priority.toUpperCase()}
                        </Badge>
                        <Badge className={getTypeColor(announcement.type)}>{announcement.type.toUpperCase()}</Badge>
                      </div>
                    </div>
                  </CardHeader>
                  <CardContent>
                    <p className="text-gray-600 text-sm line-clamp-2">{announcement.content}</p>
                    <div className="flex items-center justify-between mt-3 text-sm text-gray-500">
                      <div className="flex items-center">
                        <Calendar className="h-4 w-4 mr-1" />
                        {announcement.date}
                      </div>
                      <div className="flex items-center">
                        <span className="text-xs">Courses: {announcement.targetCourses.join(", ")}</span>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          </div>

          {/* Announcement Details */}
          <div className="w-1/2 flex flex-col">
            {selectedAnnouncement ? (
              <div className="p-6 overflow-y-auto">
                <div className="mb-6">
                  <div className="flex items-start justify-between mb-4">
                    <div>
                      <h2 className="text-2xl font-bold text-[#1E2A78] mb-2">{selectedAnnouncement.title}</h2>
                      <p className="text-gray-600">By: {selectedAnnouncement.author}</p>
                      <p className="text-sm text-gray-500">
                        {selectedAnnouncement.department} • {selectedAnnouncement.date}
                      </p>
                    </div>
                    <div className="flex space-x-2">
                      <Badge className={getPriorityColor(selectedAnnouncement.priority)}>
                        {selectedAnnouncement.priority.toUpperCase()}
                      </Badge>
                      <Badge className={getTypeColor(selectedAnnouncement.type)}>
                        {selectedAnnouncement.type.toUpperCase()}
                      </Badge>
                    </div>
                  </div>
                </div>

                <div className="prose max-w-none mb-6">
                  <p className="text-gray-700 leading-relaxed">{selectedAnnouncement.content}</p>
                </div>

                {/* Target Courses */}
                <Card className="mb-6">
                  <CardHeader>
                    <CardTitle className="text-lg">Target Courses</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="flex flex-wrap gap-2">
                      {selectedAnnouncement.targetCourses.map((course: string, index: number) => (
                        <Badge key={index} variant="outline" className="bg-blue-50 text-blue-700">
                          {course}
                        </Badge>
                      ))}
                    </div>
                  </CardContent>
                </Card>

                <div className="mt-8 pt-6 border-t border-gray-200">
                  <div className="flex items-center justify-between">
                    <div className="text-sm text-gray-500">
                      <p>Target Audience: {selectedAnnouncement.department}</p>
                      <p>Posted: {selectedAnnouncement.date}</p>
                    </div>
                    <div className="flex space-x-2">
                      <Button variant="outline">
                        <Bell className="h-4 w-4 mr-2" />
                        Mark as Read
                      </Button>
                      <Button variant="outline">
                        <Eye className="h-4 w-4 mr-2" />
                        Share with Students
                      </Button>
                    </div>
                  </div>
                </div>
              </div>
            ) : (
              <div className="flex-1 flex items-center justify-center text-gray-500">
                <div className="text-center">
                  <Bell className="h-12 w-12 mx-auto mb-4 text-gray-300" />
                  <p>Select an announcement to view details</p>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
