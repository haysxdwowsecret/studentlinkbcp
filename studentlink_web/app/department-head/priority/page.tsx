"use client"

import { RoleBasedNav } from "@/components/navigation/role-based-nav"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Textarea } from "@/components/ui/textarea"
import { AlertTriangle, Clock, User, MessageSquare, Search, Filter, ArrowUp, ArrowDown } from "lucide-react"
import { useState } from "react"

export default function DepartmentHeadPriorityPage() {
  const [selectedItem, setSelectedItem] = useState<any>(null)

  // Mock data for priority items
  const priorityItems = [
    {
      id: 1,
      title: "Critical System Outage - Student Portal",
      description: "Multiple students unable to access course materials and submit assignments",
      type: "technical",
      priority: "critical",
      status: "in_progress",
      assignedTo: "IT Support Team",
      reporter: "Multiple Students",
      dateReported: "2024-01-15",
      deadline: "2024-01-15",
      affectedUsers: 150,
      department: "Information Technology",
      updates: [
        { time: "14:30", author: "IT Support", message: "Investigating database connection issues" },
        { time: "15:00", author: "System Admin", message: "Identified root cause, implementing fix" },
      ],
    },
    {
      id: 2,
      title: "Faculty Shortage - Database Systems Course",
      description: "Prof. Martinez on medical leave, need immediate replacement for CS103",
      type: "staffing",
      priority: "high",
      status: "pending",
      assignedTo: "HR Department",
      reporter: "Academic Coordinator",
      dateReported: "2024-01-14",
      deadline: "2024-01-20",
      affectedUsers: 35,
      department: "Information Technology",
      updates: [{ time: "09:00", author: "HR Manager", message: "Reviewing available substitute faculty" }],
    },
    {
      id: 3,
      title: "Equipment Malfunction - Computer Lab 2",
      description: "15 computers not functioning, affecting programming classes",
      type: "facilities",
      priority: "high",
      status: "assigned",
      assignedTo: "Facilities Management",
      reporter: "Lab Technician",
      dateReported: "2024-01-13",
      deadline: "2024-01-18",
      affectedUsers: 40,
      department: "Information Technology",
      updates: [
        { time: "10:00", author: "Facilities", message: "Ordered replacement parts" },
        { time: "11:30", author: "Facilities", message: "Temporary workstations set up in Lab 3" },
      ],
    },
  ]

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case "critical":
        return "bg-red-100 text-red-800 border-red-200"
      case "high":
        return "bg-orange-100 text-orange-800 border-orange-200"
      case "medium":
        return "bg-yellow-100 text-yellow-800 border-yellow-200"
      case "low":
        return "bg-green-100 text-green-800 border-green-200"
      default:
        return "bg-gray-100 text-gray-800 border-gray-200"
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case "pending":
        return "bg-yellow-100 text-yellow-800"
      case "assigned":
        return "bg-blue-100 text-blue-800"
      case "in_progress":
        return "bg-purple-100 text-purple-800"
      case "resolved":
        return "bg-green-100 text-green-800"
      default:
        return "bg-gray-100 text-gray-800"
    }
  }

  const getTypeColor = (type: string) => {
    switch (type) {
      case "technical":
        return "bg-blue-100 text-blue-800"
      case "staffing":
        return "bg-purple-100 text-purple-800"
      case "facilities":
        return "bg-green-100 text-green-800"
      case "academic":
        return "bg-orange-100 text-orange-800"
      default:
        return "bg-gray-100 text-gray-800"
    }
  }

  const getPriorityIcon = (priority: string) => {
    switch (priority) {
      case "critical":
      case "high":
        return <ArrowUp className="h-4 w-4 text-red-600" />
      case "medium":
        return <ArrowUp className="h-4 w-4 text-yellow-600" />
      case "low":
        return <ArrowDown className="h-4 w-4 text-green-600" />
      default:
        return <ArrowUp className="h-4 w-4 text-gray-600" />
    }
  }

  return (
    <div className="flex h-screen bg-gray-50">
      <RoleBasedNav />

      <div className="flex-1 flex flex-col overflow-hidden">
        <header className="bg-white shadow-sm border-b border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-bold text-[#1E2A78]">Priority Items</h1>
              <p className="text-gray-600">Manage critical issues and urgent department matters</p>
            </div>
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2">
                <Search className="h-4 w-4 text-gray-400" />
                <Input placeholder="Search priority items..." className="w-64" />
              </div>
              <Select>
                <SelectTrigger className="w-40">
                  <Filter className="h-4 w-4 mr-2" />
                  <SelectValue placeholder="Filter" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Priority</SelectItem>
                  <SelectItem value="critical">Critical</SelectItem>
                  <SelectItem value="high">High</SelectItem>
                  <SelectItem value="medium">Medium</SelectItem>
                  <SelectItem value="low">Low</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
        </header>

        <div className="flex-1 flex overflow-hidden">
          {/* Priority Items List */}
          <div className="w-1/2 border-r border-gray-200 overflow-y-auto">
            <div className="p-4 space-y-4">
              {priorityItems.map((item) => (
                <Card
                  key={item.id}
                  className={`cursor-pointer transition-colors hover:bg-gray-50 border-l-4 ${
                    selectedItem?.id === item.id ? "ring-2 ring-[#2480EA]" : ""
                  } ${getPriorityColor(item.priority)}`}
                  onClick={() => setSelectedItem(item)}
                >
                  <CardHeader className="pb-3">
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <div className="flex items-center space-x-2 mb-2">
                          {getPriorityIcon(item.priority)}
                          <CardTitle className="text-lg text-[#1E2A78]">{item.title}</CardTitle>
                        </div>
                        <CardDescription className="mt-1">{item.description}</CardDescription>
                      </div>
                      <div className="flex flex-col items-end space-y-2">
                        <Badge className={getPriorityColor(item.priority)}>{item.priority.toUpperCase()}</Badge>
                        <Badge className={getStatusColor(item.status)}>
                          {item.status.replace("_", " ").toUpperCase()}
                        </Badge>
                      </div>
                    </div>
                  </CardHeader>
                  <CardContent>
                    <div className="flex items-center justify-between text-sm text-gray-500 mb-2">
                      <div className="flex items-center">
                        <User className="h-4 w-4 mr-1" />
                        {item.assignedTo}
                      </div>
                      <Badge className={getTypeColor(item.type)}>{item.type.toUpperCase()}</Badge>
                    </div>
                    <div className="flex items-center justify-between text-sm text-gray-500">
                      <div className="flex items-center">
                        <Clock className="h-4 w-4 mr-1" />
                        Deadline: {item.deadline}
                      </div>
                      <div className="flex items-center">
                        <AlertTriangle className="h-4 w-4 mr-1" />
                        {item.affectedUsers} affected
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          </div>

          {/* Priority Item Details */}
          <div className="w-1/2 flex flex-col">
            {selectedItem ? (
              <>
                <div className="p-6 border-b border-gray-200 bg-white">
                  <div className="flex items-start justify-between mb-4">
                    <div>
                      <div className="flex items-center space-x-2 mb-2">
                        {getPriorityIcon(selectedItem.priority)}
                        <h2 className="text-xl font-bold text-[#1E2A78]">{selectedItem.title}</h2>
                      </div>
                      <p className="text-gray-600 mb-2">{selectedItem.description}</p>
                      <div className="flex items-center space-x-4 text-sm text-gray-500">
                        <span>Reported by: {selectedItem.reporter}</span>
                        <span>Date: {selectedItem.dateReported}</span>
                      </div>
                    </div>
                    <div className="flex space-x-2">
                      <Badge className={getPriorityColor(selectedItem.priority)}>
                        {selectedItem.priority.toUpperCase()}
                      </Badge>
                      <Badge className={getStatusColor(selectedItem.status)}>
                        {selectedItem.status.replace("_", " ").toUpperCase()}
                      </Badge>
                      <Badge className={getTypeColor(selectedItem.type)}>{selectedItem.type.toUpperCase()}</Badge>
                    </div>
                  </div>

                  {/* Key Information */}
                  <div className="grid grid-cols-2 gap-4 p-4 bg-gray-50 rounded-lg">
                    <div>
                      <p className="text-sm font-medium text-gray-700">Assigned To</p>
                      <p className="text-sm text-gray-600">{selectedItem.assignedTo}</p>
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-700">Deadline</p>
                      <p className="text-sm text-gray-600">{selectedItem.deadline}</p>
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-700">Affected Users</p>
                      <p className="text-sm text-gray-600">{selectedItem.affectedUsers} users</p>
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-700">Department</p>
                      <p className="text-sm text-gray-600">{selectedItem.department}</p>
                    </div>
                  </div>
                </div>

                <div className="flex-1 overflow-y-auto p-6">
                  <h3 className="font-semibold text-[#1E2A78] mb-4">Progress Updates</h3>
                  <div className="space-y-4">
                    {selectedItem.updates.map((update: any, index: number) => (
                      <div key={index} className="bg-gray-50 p-4 rounded-lg">
                        <div className="flex items-center justify-between mb-2">
                          <span className="font-medium text-[#1E2A78]">{update.author}</span>
                          <span className="text-sm text-gray-500">{update.time}</span>
                        </div>
                        <p className="text-gray-700">{update.message}</p>
                      </div>
                    ))}
                  </div>
                </div>

                <div className="p-6 border-t border-gray-200 bg-white">
                  <div className="space-y-4">
                    <div className="flex items-center space-x-4">
                      <Select>
                        <SelectTrigger className="w-40">
                          <SelectValue placeholder="Update Status" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="pending">Pending</SelectItem>
                          <SelectItem value="assigned">Assigned</SelectItem>
                          <SelectItem value="in_progress">In Progress</SelectItem>
                          <SelectItem value="resolved">Resolved</SelectItem>
                        </SelectContent>
                      </Select>
                      <Select>
                        <SelectTrigger className="w-40">
                          <SelectValue placeholder="Change Priority" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="critical">Critical</SelectItem>
                          <SelectItem value="high">High</SelectItem>
                          <SelectItem value="medium">Medium</SelectItem>
                          <SelectItem value="low">Low</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                    <Textarea placeholder="Add progress update..." className="min-h-[80px]" />
                    <div className="flex items-center justify-between">
                      <Button variant="outline">
                        <User className="h-4 w-4 mr-2" />
                        Reassign
                      </Button>
                      <Button className="bg-[#1E2A78] hover:bg-[#2480EA]">
                        <MessageSquare className="h-4 w-4 mr-2" />
                        Add Update
                      </Button>
                    </div>
                  </div>
                </div>
              </>
            ) : (
              <div className="flex-1 flex items-center justify-center text-gray-500">
                <div className="text-center">
                  <AlertTriangle className="h-12 w-12 mx-auto mb-4 text-gray-300" />
                  <p>Select a priority item to view details</p>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
