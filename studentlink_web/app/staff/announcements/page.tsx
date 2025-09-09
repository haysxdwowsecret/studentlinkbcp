"use client"

import { RoleBasedNav } from "@/components/navigation/role-based-nav"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Bell, Calendar, Search, Filter, Eye } from "lucide-react"
import { useState } from "react"

export default function StaffAnnouncementsPage() {
  const [selectedAnnouncement, setSelectedAnnouncement] = useState<any>(null)

  // Mock data for announcements
  const announcements = [
    {
      id: 1,
      title: "New Library Hours",
      content:
        "The library will extend its hours starting next week. New hours: Monday-Friday 7AM-10PM, Saturday-Sunday 8AM-8PM.",
      author: "Library Administration",
      date: "2024-01-15",
      priority: "medium",
      department: "All Departments",
      type: "general",
    },
    {
      id: 2,
      title: "System Maintenance Notice",
      content:
        "The student portal will be down for maintenance on Saturday, January 20th from 2AM-6AM. Please plan accordingly.",
      author: "IT Department",
      date: "2024-01-14",
      priority: "high",
      department: "All Departments",
      type: "technical",
    },
    {
      id: 3,
      title: "Faculty Meeting Reminder",
      content:
        "Monthly faculty meeting scheduled for January 25th at 2PM in Conference Room A. Attendance is mandatory.",
      author: "Academic Affairs",
      date: "2024-01-13",
      priority: "high",
      department: "All Faculty",
      type: "meeting",
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
      case "general":
        return "bg-blue-100 text-blue-800"
      case "technical":
        return "bg-purple-100 text-purple-800"
      case "meeting":
        return "bg-orange-100 text-orange-800"
      case "academic":
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
              <p className="text-gray-600">Stay updated with important notices</p>
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
                  <SelectItem value="general">General</SelectItem>
                  <SelectItem value="technical">Technical</SelectItem>
                  <SelectItem value="meeting">Meeting</SelectItem>
                  <SelectItem value="academic">Academic</SelectItem>
                </SelectContent>
              </Select>
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
                      <Button variant="ghost" size="sm">
                        <Eye className="h-4 w-4 mr-1" />
                        Read More
                      </Button>
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

                <div className="prose max-w-none">
                  <p className="text-gray-700 leading-relaxed">{selectedAnnouncement.content}</p>
                </div>

                <div className="mt-8 pt-6 border-t border-gray-200">
                  <div className="flex items-center justify-between">
                    <div className="text-sm text-gray-500">
                      <p>Target Audience: {selectedAnnouncement.department}</p>
                      <p>Posted: {selectedAnnouncement.date}</p>
                    </div>
                    <Button variant="outline">
                      <Bell className="h-4 w-4 mr-2" />
                      Mark as Read
                    </Button>
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
