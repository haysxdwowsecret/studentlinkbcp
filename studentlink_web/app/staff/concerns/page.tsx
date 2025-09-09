"use client"

import { RoleBasedNav } from "@/components/navigation/role-based-nav"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Textarea } from "@/components/ui/textarea"
import { MessageSquare, Clock, Search, Filter, Reply } from "lucide-react"
import { useState } from "react"

export default function StaffConcernsPage() {
  const [selectedConcern, setSelectedConcern] = useState<any>(null)
  const [replyText, setReplyText] = useState("")

  // Mock data for staff concerns
  const concerns = [
    {
      id: 1,
      title: "Library Access Issue",
      student: "Maria Santos",
      department: "BS Information Technology",
      status: "received",
      priority: "medium",
      date: "2024-01-15",
      description: "Cannot access digital library resources from home",
      replies: [{ author: "John Staff", message: "I'll check with IT department", date: "2024-01-15" }],
    },
    {
      id: 2,
      title: "Course Schedule Conflict",
      student: "Anonymous",
      department: "BS Business Administration",
      status: "in_process",
      priority: "high",
      date: "2024-01-14",
      description: "Two required courses scheduled at the same time",
      replies: [],
    },
  ]

  const getStatusColor = (status: string) => {
    switch (status) {
      case "received":
        return "bg-blue-100 text-blue-800"
      case "in_process":
        return "bg-yellow-100 text-yellow-800"
      case "resolved":
        return "bg-green-100 text-green-800"
      default:
        return "bg-gray-100 text-gray-800"
    }
  }

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

  return (
    <div className="flex h-screen bg-gray-50">
      <RoleBasedNav />

      <div className="flex-1 flex flex-col overflow-hidden">
        <header className="bg-white shadow-sm border-b border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-bold text-[#1E2A78]">My Concerns</h1>
              <p className="text-gray-600">Manage concerns assigned to you</p>
            </div>
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2">
                <Search className="h-4 w-4 text-gray-400" />
                <Input placeholder="Search concerns..." className="w-64" />
              </div>
              <Select>
                <SelectTrigger className="w-40">
                  <Filter className="h-4 w-4 mr-2" />
                  <SelectValue placeholder="Filter" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Status</SelectItem>
                  <SelectItem value="received">Received</SelectItem>
                  <SelectItem value="in_process">In Process</SelectItem>
                  <SelectItem value="resolved">Resolved</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
        </header>

        <div className="flex-1 flex overflow-hidden">
          {/* Concerns List */}
          <div className="w-1/2 border-r border-gray-200 overflow-y-auto">
            <div className="p-4 space-y-4">
              {concerns.map((concern) => (
                <Card
                  key={concern.id}
                  className={`cursor-pointer transition-colors hover:bg-gray-50 ${
                    selectedConcern?.id === concern.id ? "ring-2 ring-[#2480EA]" : ""
                  }`}
                  onClick={() => setSelectedConcern(concern)}
                >
                  <CardHeader className="pb-3">
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <CardTitle className="text-lg text-[#1E2A78]">{concern.title}</CardTitle>
                        <CardDescription className="mt-1">
                          From: {concern.student} • {concern.department}
                        </CardDescription>
                      </div>
                      <div className="flex flex-col items-end space-y-2">
                        <Badge className={getStatusColor(concern.status)}>
                          {concern.status.replace("_", " ").toUpperCase()}
                        </Badge>
                        <Badge className={getPriorityColor(concern.priority)}>{concern.priority.toUpperCase()}</Badge>
                      </div>
                    </div>
                  </CardHeader>
                  <CardContent>
                    <p className="text-gray-600 text-sm line-clamp-2">{concern.description}</p>
                    <div className="flex items-center justify-between mt-3 text-sm text-gray-500">
                      <div className="flex items-center">
                        <Clock className="h-4 w-4 mr-1" />
                        {concern.date}
                      </div>
                      <div className="flex items-center">
                        <MessageSquare className="h-4 w-4 mr-1" />
                        {concern.replies.length} replies
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          </div>

          {/* Concern Details */}
          <div className="w-1/2 flex flex-col">
            {selectedConcern ? (
              <>
                <div className="p-6 border-b border-gray-200 bg-white">
                  <div className="flex items-start justify-between mb-4">
                    <div>
                      <h2 className="text-xl font-bold text-[#1E2A78]">{selectedConcern.title}</h2>
                      <p className="text-gray-600">From: {selectedConcern.student}</p>
                      <p className="text-sm text-gray-500">
                        {selectedConcern.department} • {selectedConcern.date}
                      </p>
                    </div>
                    <div className="flex space-x-2">
                      <Badge className={getStatusColor(selectedConcern.status)}>
                        {selectedConcern.status.replace("_", " ").toUpperCase()}
                      </Badge>
                      <Badge className={getPriorityColor(selectedConcern.priority)}>
                        {selectedConcern.priority.toUpperCase()}
                      </Badge>
                    </div>
                  </div>
                  <p className="text-gray-700">{selectedConcern.description}</p>
                </div>

                <div className="flex-1 overflow-y-auto p-6">
                  <h3 className="font-semibold text-[#1E2A78] mb-4">Conversation</h3>
                  <div className="space-y-4">
                    {selectedConcern.replies.map((reply: any, index: number) => (
                      <div key={index} className="bg-gray-50 p-4 rounded-lg">
                        <div className="flex items-center justify-between mb-2">
                          <span className="font-medium text-[#1E2A78]">{reply.author}</span>
                          <span className="text-sm text-gray-500">{reply.date}</span>
                        </div>
                        <p className="text-gray-700">{reply.message}</p>
                      </div>
                    ))}
                  </div>
                </div>

                <div className="p-6 border-t border-gray-200 bg-white">
                  <div className="space-y-4">
                    <Textarea
                      placeholder="Type your reply..."
                      value={replyText}
                      onChange={(e) => setReplyText(e.target.value)}
                      className="min-h-[100px]"
                    />
                    <div className="flex items-center justify-between">
                      <Select>
                        <SelectTrigger className="w-40">
                          <SelectValue placeholder="Update Status" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="received">Received</SelectItem>
                          <SelectItem value="in_process">In Process</SelectItem>
                          <SelectItem value="resolved">Resolved</SelectItem>
                        </SelectContent>
                      </Select>
                      <Button className="bg-[#1E2A78] hover:bg-[#2480EA]">
                        <Reply className="h-4 w-4 mr-2" />
                        Send Reply
                      </Button>
                    </div>
                  </div>
                </div>
              </>
            ) : (
              <div className="flex-1 flex items-center justify-center text-gray-500">
                <div className="text-center">
                  <MessageSquare className="h-12 w-12 mx-auto mb-4 text-gray-300" />
                  <p>Select a concern to view details</p>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
