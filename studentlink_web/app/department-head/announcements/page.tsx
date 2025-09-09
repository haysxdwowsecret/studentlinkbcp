import { ProtectedRoute } from "@/components/protected-route"
import { RoleBasedNav } from "@/components/navigation/role-based-nav"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Plus, Search, Edit, Trash2, Megaphone, Calendar, Users } from "lucide-react"

export default function DepartmentHeadAnnouncementsPage() {
  const announcements = [
    {
      id: 1,
      title: "New Laboratory Schedule",
      content: "Updated laboratory schedules for BS Information Technology students effective next week.",
      targetCourse: "BS Information Technology",
      concernType: "Academic",
      status: "active",
      createdAt: "2024-01-15",
      author: "Dr. Johnson",
      views: 234,
    },
    {
      id: 2,
      title: "Department Meeting",
      content: "Monthly department meeting scheduled for Friday at 2:00 PM in Conference Room A.",
      targetCourse: "All Courses",
      concernType: "Administrative",
      status: "active",
      createdAt: "2024-01-14",
      author: "Dr. Johnson",
      views: 156,
    },
    {
      id: 3,
      title: "System Maintenance Notice",
      content: "The student portal will be under maintenance this weekend from 10 PM to 6 AM.",
      targetCourse: "All Courses",
      concernType: "Technical",
      status: "scheduled",
      createdAt: "2024-01-13",
      author: "Dr. Johnson",
      views: 89,
    },
  ]

  const getStatusColor = (status: string) => {
    switch (status) {
      case "active":
        return "bg-green-100 text-green-800"
      case "scheduled":
        return "bg-blue-100 text-blue-800"
      case "expired":
        return "bg-gray-100 text-gray-800"
      default:
        return "bg-gray-100 text-gray-800"
    }
  }

  return (
    <ProtectedRoute allowedRoles={["department_head"]}>
      <div className="flex min-h-screen bg-gray-50">
        <RoleBasedNav />
        <main className="flex-1 p-6">
          <div className="max-w-6xl mx-auto">
            <div className="mb-8">
              <h1 className="text-3xl font-bold text-[#1E2A78] mb-2">Department Announcements</h1>
              <p className="text-gray-600">Create and manage announcements for your department</p>
            </div>

            <Tabs defaultValue="manage" className="space-y-6">
              <TabsList>
                <TabsTrigger value="manage">Manage Announcements</TabsTrigger>
                <TabsTrigger value="create">Create New</TabsTrigger>
              </TabsList>

              <TabsContent value="manage">
                {/* Search and Filters */}
                <Card className="mb-6">
                  <CardContent className="p-4">
                    <div className="flex flex-col md:flex-row gap-4">
                      <div className="flex-1">
                        <div className="relative">
                          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
                          <Input placeholder="Search announcements..." className="pl-10" />
                        </div>
                      </div>
                      <Select>
                        <SelectTrigger className="w-full md:w-48">
                          <SelectValue placeholder="Status" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="all">All Status</SelectItem>
                          <SelectItem value="active">Active</SelectItem>
                          <SelectItem value="scheduled">Scheduled</SelectItem>
                          <SelectItem value="expired">Expired</SelectItem>
                        </SelectContent>
                      </Select>
                      <Select>
                        <SelectTrigger className="w-full md:w-48">
                          <SelectValue placeholder="Target Course" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="all">All Courses</SelectItem>
                          <SelectItem value="it">BS Information Technology</SelectItem>
                          <SelectItem value="ba">BS Business Administration</SelectItem>
                          <SelectItem value="hm">BS Hospitality Management</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                  </CardContent>
                </Card>

                {/* Announcements List */}
                <div className="space-y-4">
                  {announcements.map((announcement) => (
                    <Card key={announcement.id} className="hover:shadow-md transition-shadow">
                      <CardContent className="p-6">
                        <div className="flex items-start justify-between">
                          <div className="flex-1">
                            <div className="flex items-center gap-3 mb-2">
                              <h3 className="font-semibold text-lg text-[#1E2A78]">{announcement.title}</h3>
                              <Badge className={getStatusColor(announcement.status)}>{announcement.status}</Badge>
                            </div>

                            <p className="text-gray-600 mb-4 line-clamp-2">{announcement.content}</p>

                            <div className="grid grid-cols-1 md:grid-cols-4 gap-4 text-sm text-gray-600">
                              <div className="flex items-center gap-2">
                                <Users className="h-4 w-4" />
                                <span>{announcement.targetCourse}</span>
                              </div>
                              <div className="flex items-center gap-2">
                                <Megaphone className="h-4 w-4" />
                                <span>{announcement.concernType}</span>
                              </div>
                              <div className="flex items-center gap-2">
                                <Calendar className="h-4 w-4" />
                                <span>{announcement.createdAt}</span>
                              </div>
                              <div className="flex items-center gap-2">
                                <span>{announcement.views} views</span>
                              </div>
                            </div>
                          </div>

                          <div className="flex gap-2 ml-4">
                            <Button size="sm" variant="outline">
                              <Edit className="h-4 w-4" />
                            </Button>
                            <Button
                              size="sm"
                              variant="outline"
                              className="text-red-600 hover:text-red-700 bg-transparent"
                            >
                              <Trash2 className="h-4 w-4" />
                            </Button>
                          </div>
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              </TabsContent>

              <TabsContent value="create">
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <Plus className="h-5 w-5" />
                      Create New Announcement
                    </CardTitle>
                    <CardDescription>Create a new announcement for your department</CardDescription>
                  </CardHeader>
                  <CardContent className="space-y-6">
                    <div className="space-y-2">
                      <Label htmlFor="announcement-title">Title</Label>
                      <Input id="announcement-title" placeholder="Enter announcement title..." />
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="announcement-content">Content</Label>
                      <Textarea id="announcement-content" placeholder="Enter announcement content..." rows={6} />
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div className="space-y-2">
                        <Label htmlFor="target-course">Target Course</Label>
                        <Select>
                          <SelectTrigger>
                            <SelectValue placeholder="Select target course" />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="all">All Courses</SelectItem>
                            <SelectItem value="it">BS Information Technology</SelectItem>
                            <SelectItem value="ba">BS Business Administration</SelectItem>
                            <SelectItem value="hm">BS Hospitality Management</SelectItem>
                            <SelectItem value="oa">BS Office Administration</SelectItem>
                            <SelectItem value="crim">BS Criminology</SelectItem>
                            <SelectItem value="elem">Bachelor of Elementary Education</SelectItem>
                            <SelectItem value="sec">Bachelor of Secondary Education</SelectItem>
                            <SelectItem value="ce">BS Computer Engineering</SelectItem>
                            <SelectItem value="tm">BS Tourism Management</SelectItem>
                            <SelectItem value="entrep">BS Entrepreneurship</SelectItem>
                            <SelectItem value="ais">BS Accounting Information System</SelectItem>
                            <SelectItem value="psych">BS Psychology</SelectItem>
                          </SelectContent>
                        </Select>
                      </div>

                      <div className="space-y-2">
                        <Label htmlFor="concern-type">Concern Type</Label>
                        <Select>
                          <SelectTrigger>
                            <SelectValue placeholder="Select concern type" />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="academic">Academic</SelectItem>
                            <SelectItem value="administrative">Administrative</SelectItem>
                            <SelectItem value="technical">Technical</SelectItem>
                            <SelectItem value="facilities">Facilities</SelectItem>
                            <SelectItem value="general">General</SelectItem>
                          </SelectContent>
                        </Select>
                      </div>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div className="space-y-2">
                        <Label htmlFor="publish-date">Publish Date</Label>
                        <Input id="publish-date" type="datetime-local" />
                      </div>

                      <div className="space-y-2">
                        <Label htmlFor="expiry-date">Expiry Date (Optional)</Label>
                        <Input id="expiry-date" type="datetime-local" />
                      </div>
                    </div>

                    <div className="flex gap-4">
                      <Button className="bg-[#2480EA] hover:bg-[#1E2A78]">Publish Announcement</Button>
                      <Button variant="outline">Save as Draft</Button>
                    </div>
                  </CardContent>
                </Card>
              </TabsContent>
            </Tabs>
          </div>
        </main>
      </div>
    </ProtectedRoute>
  )
}
