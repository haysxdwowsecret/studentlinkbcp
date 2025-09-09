"use client"

import { RoleBasedNav } from "@/components/navigation/role-based-nav"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Calendar, Clock, MapPin, User, Plus, Edit, Trash2 } from "lucide-react"
import { useState } from "react"

export default function FacultyOfficeHoursPage() {
  const [selectedSlot, setSelectedSlot] = useState<any>(null)
  const [isEditing, setIsEditing] = useState(false)

  // Mock data for office hours
  const officeHours = [
    {
      id: 1,
      day: "Monday",
      startTime: "10:00",
      endTime: "12:00",
      location: "Faculty Office 201",
      status: "available",
      appointments: [
        { student: "John Dela Cruz", time: "10:30", topic: "Assignment Help", status: "confirmed" },
        { student: "Maria Santos", time: "11:15", topic: "Project Discussion", status: "pending" },
      ],
    },
    {
      id: 2,
      day: "Wednesday",
      startTime: "14:00",
      endTime: "16:00",
      location: "Faculty Office 201",
      status: "available",
      appointments: [{ student: "Carlos Rodriguez", time: "14:30", topic: "Exam Review", status: "confirmed" }],
    },
    {
      id: 3,
      day: "Friday",
      startTime: "09:00",
      endTime: "11:00",
      location: "Faculty Office 201",
      status: "available",
      appointments: [],
    },
  ]

  const upcomingAppointments = [
    {
      id: 1,
      student: "John Dela Cruz",
      course: "CS101",
      date: "2024-01-16",
      time: "10:30",
      topic: "Assignment Help",
      status: "confirmed",
    },
    {
      id: 2,
      student: "Maria Santos",
      course: "CS102",
      date: "2024-01-16",
      time: "11:15",
      topic: "Project Discussion",
      status: "pending",
    },
    {
      id: 3,
      student: "Carlos Rodriguez",
      course: "CS103",
      date: "2024-01-17",
      time: "14:30",
      topic: "Exam Review",
      status: "confirmed",
    },
  ]

  const getStatusColor = (status: string) => {
    switch (status) {
      case "available":
        return "bg-green-100 text-green-800"
      case "busy":
        return "bg-red-100 text-red-800"
      case "break":
        return "bg-yellow-100 text-yellow-800"
      default:
        return "bg-gray-100 text-gray-800"
    }
  }

  const getAppointmentStatusColor = (status: string) => {
    switch (status) {
      case "confirmed":
        return "bg-green-100 text-green-800"
      case "pending":
        return "bg-yellow-100 text-yellow-800"
      case "cancelled":
        return "bg-red-100 text-red-800"
      default:
        return "bg-gray-100 text-gray-800"
    }
  }

  return (
    <div className="flex h-screen bg-gray-50">
      <RoleBasedNav />

      <div className="flex-1 overflow-y-auto">
        <header className="bg-white shadow-sm border-b border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-bold text-[#1E2A78]">Office Hours</h1>
              <p className="text-gray-600">Manage your availability and student appointments</p>
            </div>
            <div className="flex items-center space-x-4">
              <Button variant="outline">
                <Calendar className="h-4 w-4 mr-2" />
                View Calendar
              </Button>
              <Button className="bg-[#1E2A78] hover:bg-[#2480EA]">
                <Plus className="h-4 w-4 mr-2" />
                Add Office Hours
              </Button>
            </div>
          </div>
        </header>

        <div className="p-6 space-y-6">
          {/* Office Hours Schedule */}
          <div>
            <h2 className="text-xl font-semibold text-[#1E2A78] mb-4">Weekly Schedule</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {officeHours.map((slot) => (
                <Card key={slot.id} className="hover:shadow-lg transition-shadow">
                  <CardHeader className="pb-3">
                    <div className="flex items-center justify-between">
                      <CardTitle className="text-lg text-[#1E2A78]">{slot.day}</CardTitle>
                      <Badge className={getStatusColor(slot.status)}>{slot.status.toUpperCase()}</Badge>
                    </div>
                    <CardDescription>
                      {slot.startTime} - {slot.endTime}
                    </CardDescription>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="flex items-center text-sm text-gray-600">
                      <MapPin className="h-4 w-4 mr-2" />
                      {slot.location}
                    </div>

                    <div>
                      <p className="text-sm font-medium text-gray-700 mb-2">
                        Appointments ({slot.appointments.length})
                      </p>
                      {slot.appointments.length > 0 ? (
                        <div className="space-y-2">
                          {slot.appointments.map((appointment, index) => (
                            <div key={index} className="flex items-center justify-between p-2 bg-gray-50 rounded">
                              <div>
                                <p className="text-sm font-medium">{appointment.student}</p>
                                <p className="text-xs text-gray-500">
                                  {appointment.time} - {appointment.topic}
                                </p>
                              </div>
                              <Badge className={getAppointmentStatusColor(appointment.status)} variant="outline">
                                {appointment.status}
                              </Badge>
                            </div>
                          ))}
                        </div>
                      ) : (
                        <p className="text-sm text-gray-500">No appointments scheduled</p>
                      )}
                    </div>

                    <div className="flex space-x-2">
                      <Button variant="outline" size="sm" className="flex-1 bg-transparent">
                        <Edit className="h-4 w-4 mr-1" />
                        Edit
                      </Button>
                      <Button variant="outline" size="sm" className="flex-1 bg-transparent">
                        <Trash2 className="h-4 w-4 mr-1" />
                        Delete
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          </div>

          {/* Upcoming Appointments */}
          <div>
            <h2 className="text-xl font-semibold text-[#1E2A78] mb-4">Upcoming Appointments</h2>
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">This Week's Appointments</CardTitle>
                <CardDescription>Manage your scheduled student meetings</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {upcomingAppointments.map((appointment) => (
                    <div key={appointment.id} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                      <div className="flex items-center space-x-4">
                        <div className="w-10 h-10 bg-[#1E2A78] rounded-full flex items-center justify-center">
                          <User className="h-5 w-5 text-white" />
                        </div>
                        <div>
                          <p className="font-medium text-[#1E2A78]">{appointment.student}</p>
                          <p className="text-sm text-gray-600">
                            {appointment.course} • {appointment.topic}
                          </p>
                          <div className="flex items-center text-sm text-gray-500 mt-1">
                            <Calendar className="h-4 w-4 mr-1" />
                            {appointment.date}
                            <Clock className="h-4 w-4 ml-3 mr-1" />
                            {appointment.time}
                          </div>
                        </div>
                      </div>
                      <div className="flex items-center space-x-2">
                        <Badge className={getAppointmentStatusColor(appointment.status)}>
                          {appointment.status.toUpperCase()}
                        </Badge>
                        <div className="flex space-x-1">
                          <Button variant="outline" size="sm">
                            <Edit className="h-4 w-4" />
                          </Button>
                          <Button variant="outline" size="sm">
                            <Trash2 className="h-4 w-4" />
                          </Button>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Quick Actions */}
          <div>
            <h2 className="text-xl font-semibold text-[#1E2A78] mb-4">Quick Actions</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <Card>
                <CardHeader>
                  <CardTitle className="text-lg">Set Availability</CardTitle>
                  <CardDescription>Update your office hours for the week</CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="text-sm font-medium">Day</label>
                      <Select>
                        <SelectTrigger>
                          <SelectValue placeholder="Select day" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="monday">Monday</SelectItem>
                          <SelectItem value="tuesday">Tuesday</SelectItem>
                          <SelectItem value="wednesday">Wednesday</SelectItem>
                          <SelectItem value="thursday">Thursday</SelectItem>
                          <SelectItem value="friday">Friday</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                    <div>
                      <label className="text-sm font-medium">Status</label>
                      <Select>
                        <SelectTrigger>
                          <SelectValue placeholder="Status" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="available">Available</SelectItem>
                          <SelectItem value="busy">Busy</SelectItem>
                          <SelectItem value="break">Break</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                  </div>
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="text-sm font-medium">Start Time</label>
                      <Input type="time" />
                    </div>
                    <div>
                      <label className="text-sm font-medium">End Time</label>
                      <Input type="time" />
                    </div>
                  </div>
                  <div>
                    <label className="text-sm font-medium">Location</label>
                    <Input placeholder="Faculty Office 201" />
                  </div>
                  <Button className="w-full bg-[#1E2A78] hover:bg-[#2480EA]">
                    <Plus className="h-4 w-4 mr-2" />
                    Add Office Hours
                  </Button>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle className="text-lg">Appointment Notes</CardTitle>
                  <CardDescription>Add notes for upcoming appointments</CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div>
                    <label className="text-sm font-medium">Select Appointment</label>
                    <Select>
                      <SelectTrigger>
                        <SelectValue placeholder="Choose appointment" />
                      </SelectTrigger>
                      <SelectContent>
                        {upcomingAppointments.map((appointment) => (
                          <SelectItem key={appointment.id} value={appointment.id.toString()}>
                            {appointment.student} - {appointment.date} {appointment.time}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  <div>
                    <label className="text-sm font-medium">Notes</label>
                    <Textarea placeholder="Add notes about the appointment..." className="min-h-[100px]" />
                  </div>
                  <Button className="w-full bg-[#1E2A78] hover:bg-[#2480EA]">Save Notes</Button>
                </CardContent>
              </Card>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
