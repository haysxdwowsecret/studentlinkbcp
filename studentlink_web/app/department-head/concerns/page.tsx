import { ProtectedRoute } from "@/components/protected-route"
import { RoleBasedNav } from "@/components/navigation/role-based-nav"
import { Card, CardContent } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Search, Eye, MessageSquare, Clock, User, AlertCircle, CheckCircle } from "lucide-react"

export default function DepartmentHeadConcernsPage() {
  const concerns = [
    {
      id: "CON-2024-001",
      title: "Laboratory Equipment Issue",
      student: "John Doe",
      department: "BS Information Technology",
      status: "In Process",
      priority: "High",
      assignedTo: "Prof. Smith",
      createdAt: "2024-01-15",
      lastReply: "2 hours ago",
      replies: 3,
    },
    {
      id: "CON-2024-002",
      title: "Course Registration Problem",
      student: "Jane Smith",
      department: "BS Information Technology",
      status: "Received",
      priority: "Medium",
      assignedTo: "Unassigned",
      createdAt: "2024-01-14",
      lastReply: "1 day ago",
      replies: 1,
    },
    {
      id: "CON-2024-003",
      title: "Internet Connectivity Issues",
      student: "Mike Johnson",
      department: "BS Information Technology",
      status: "Resolved",
      priority: "Low",
      assignedTo: "IT Support",
      createdAt: "2024-01-13",
      lastReply: "3 days ago",
      replies: 5,
    },
  ]

  const getStatusColor = (status: string) => {
    switch (status) {
      case "Received":
        return "bg-blue-100 text-blue-800"
      case "In Process":
        return "bg-yellow-100 text-yellow-800"
      case "Resolved":
        return "bg-green-100 text-green-800"
      default:
        return "bg-gray-100 text-gray-800"
    }
  }

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case "High":
        return "bg-red-100 text-red-800"
      case "Medium":
        return "bg-yellow-100 text-yellow-800"
      case "Low":
        return "bg-green-100 text-green-800"
      default:
        return "bg-gray-100 text-gray-800"
    }
  }

  return (
    <ProtectedRoute allowedRoles={["department_head"]}>
      <div className="flex min-h-screen bg-gray-50">
        <RoleBasedNav />
        <main className="flex-1 p-6">
          <div className="max-w-7xl mx-auto">
            <div className="mb-8">
              <h1 className="text-3xl font-bold text-[#1E2A78] mb-2">Department Concerns</h1>
              <p className="text-gray-600">Manage and oversee concerns for your department</p>
            </div>

            {/* Filters and Search */}
            <Card className="mb-6">
              <CardContent className="p-4">
                <div className="flex flex-col md:flex-row gap-4">
                  <div className="flex-1">
                    <div className="relative">
                      <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
                      <Input placeholder="Search concerns..." className="pl-10" />
                    </div>
                  </div>
                  <Select>
                    <SelectTrigger className="w-full md:w-48">
                      <SelectValue placeholder="Status" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Status</SelectItem>
                      <SelectItem value="received">Received</SelectItem>
                      <SelectItem value="in-process">In Process</SelectItem>
                      <SelectItem value="resolved">Resolved</SelectItem>
                    </SelectContent>
                  </Select>
                  <Select>
                    <SelectTrigger className="w-full md:w-48">
                      <SelectValue placeholder="Priority" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Priority</SelectItem>
                      <SelectItem value="high">High</SelectItem>
                      <SelectItem value="medium">Medium</SelectItem>
                      <SelectItem value="low">Low</SelectItem>
                    </SelectContent>
                  </Select>
                  <Select>
                    <SelectTrigger className="w-full md:w-48">
                      <SelectValue placeholder="Assigned To" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Staff</SelectItem>
                      <SelectItem value="prof-smith">Prof. Smith</SelectItem>
                      <SelectItem value="it-support">IT Support</SelectItem>
                      <SelectItem value="unassigned">Unassigned</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </CardContent>
            </Card>

            <Tabs defaultValue="all" className="space-y-6">
              <TabsList>
                <TabsTrigger value="all">All Concerns (12)</TabsTrigger>
                <TabsTrigger value="received">Received (3)</TabsTrigger>
                <TabsTrigger value="in-process">In Process (5)</TabsTrigger>
                <TabsTrigger value="resolved">Resolved (4)</TabsTrigger>
              </TabsList>

              <TabsContent value="all">
                <div className="space-y-4">
                  {concerns.map((concern) => (
                    <Card key={concern.id} className="hover:shadow-md transition-shadow">
                      <CardContent className="p-6">
                        <div className="flex items-start justify-between">
                          <div className="flex-1">
                            <div className="flex items-center gap-3 mb-2">
                              <h3 className="font-semibold text-lg text-[#1E2A78]">{concern.title}</h3>
                              <Badge className={getStatusColor(concern.status)}>{concern.status}</Badge>
                              <Badge className={getPriorityColor(concern.priority)}>{concern.priority}</Badge>
                            </div>

                            <div className="grid grid-cols-1 md:grid-cols-4 gap-4 text-sm text-gray-600 mb-4">
                              <div className="flex items-center gap-2">
                                <User className="h-4 w-4" />
                                <span>{concern.student}</span>
                              </div>
                              <div className="flex items-center gap-2">
                                <AlertCircle className="h-4 w-4" />
                                <span>{concern.id}</span>
                              </div>
                              <div className="flex items-center gap-2">
                                <Clock className="h-4 w-4" />
                                <span>Created {concern.createdAt}</span>
                              </div>
                              <div className="flex items-center gap-2">
                                <MessageSquare className="h-4 w-4" />
                                <span>{concern.replies} replies</span>
                              </div>
                            </div>

                            <div className="flex items-center gap-4 text-sm">
                              <span className="text-gray-500">Assigned to:</span>
                              <Badge variant="outline">{concern.assignedTo}</Badge>
                              <span className="text-gray-500">Last reply:</span>
                              <span className="font-medium">{concern.lastReply}</span>
                            </div>
                          </div>

                          <div className="flex gap-2 ml-4">
                            <Button size="sm" variant="outline">
                              <Eye className="h-4 w-4 mr-2" />
                              View
                            </Button>
                            <Button size="sm" className="bg-[#2480EA] hover:bg-[#1E2A78]">
                              Manage
                            </Button>
                          </div>
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              </TabsContent>

              <TabsContent value="received">
                <div className="text-center py-12">
                  <AlertCircle className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                  <h3 className="text-lg font-medium text-gray-900 mb-2">No received concerns</h3>
                  <p className="text-gray-500">All concerns have been processed or assigned.</p>
                </div>
              </TabsContent>

              <TabsContent value="in-process">
                <div className="text-center py-12">
                  <Clock className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                  <h3 className="text-lg font-medium text-gray-900 mb-2">Concerns in process</h3>
                  <p className="text-gray-500">5 concerns are currently being handled by your team.</p>
                </div>
              </TabsContent>

              <TabsContent value="resolved">
                <div className="text-center py-12">
                  <CheckCircle className="h-12 w-12 text-green-400 mx-auto mb-4" />
                  <h3 className="text-lg font-medium text-gray-900 mb-2">Resolved concerns</h3>
                  <p className="text-gray-500">4 concerns have been successfully resolved this month.</p>
                </div>
              </TabsContent>
            </Tabs>
          </div>
        </main>
      </div>
    </ProtectedRoute>
  )
}
