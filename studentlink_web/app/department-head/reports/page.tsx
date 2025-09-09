import { ProtectedRoute } from "@/components/protected-route"
import { RoleBasedNav } from "@/components/navigation/role-based-nav"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Calendar, Download, TrendingUp, Users, AlertTriangle, CheckCircle, Clock, BarChart3 } from "lucide-react"

export default function DepartmentHeadReportsPage() {
  return (
    <ProtectedRoute allowedRoles={["department_head"]}>
      <div className="flex min-h-screen bg-gray-50">
        <RoleBasedNav />
        <main className="flex-1 p-6">
          <div className="max-w-7xl mx-auto">
            <div className="mb-8">
              <h1 className="text-3xl font-bold text-[#1E2A78] mb-2">Department Reports</h1>
              <p className="text-gray-600">Analytics and performance metrics for your department</p>
            </div>

            {/* Report Filters */}
            <Card className="mb-6">
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Calendar className="h-5 w-5" />
                  Report Filters
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <Select>
                    <SelectTrigger>
                      <SelectValue placeholder="Time Period" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="7days">Last 7 Days</SelectItem>
                      <SelectItem value="30days">Last 30 Days</SelectItem>
                      <SelectItem value="90days">Last 90 Days</SelectItem>
                      <SelectItem value="1year">Last Year</SelectItem>
                    </SelectContent>
                  </Select>
                  <Select>
                    <SelectTrigger>
                      <SelectValue placeholder="Report Type" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="concerns">Concerns Report</SelectItem>
                      <SelectItem value="staff">Staff Performance</SelectItem>
                      <SelectItem value="students">Student Engagement</SelectItem>
                    </SelectContent>
                  </Select>
                  <Button className="bg-[#2480EA] hover:bg-[#1E2A78]">
                    <Download className="h-4 w-4 mr-2" />
                    Export Report
                  </Button>
                </div>
              </CardContent>
            </Card>

            {/* Key Metrics */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
              <Card>
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm font-medium text-gray-600">Department Concerns</p>
                      <p className="text-2xl font-bold text-[#1E2A78]">89</p>
                    </div>
                    <AlertTriangle className="h-8 w-8 text-[#2480EA]" />
                  </div>
                  <div className="flex items-center mt-2">
                    <TrendingUp className="h-4 w-4 text-green-500 mr-1" />
                    <span className="text-sm text-green-500">+8% from last month</span>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm font-medium text-gray-600">Resolution Rate</p>
                      <p className="text-2xl font-bold text-green-600">92.1%</p>
                    </div>
                    <CheckCircle className="h-8 w-8 text-green-500" />
                  </div>
                  <div className="flex items-center mt-2">
                    <span className="text-sm text-gray-500">82 of 89 resolved</span>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm font-medium text-gray-600">Active Staff</p>
                      <p className="text-2xl font-bold text-[#2480EA]">12</p>
                    </div>
                    <Users className="h-8 w-8 text-[#2480EA]" />
                  </div>
                  <div className="flex items-center mt-2">
                    <span className="text-sm text-gray-500">Faculty & Staff</span>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm font-medium text-gray-600">Avg Response Time</p>
                      <p className="text-2xl font-bold text-[#1E2A78]">1.8h</p>
                    </div>
                    <Clock className="h-8 w-8 text-[#2480EA]" />
                  </div>
                  <div className="flex items-center mt-2">
                    <span className="text-sm text-green-500">-20min improvement</span>
                  </div>
                </CardContent>
              </Card>
            </div>

            {/* Detailed Reports */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              <Card>
                <CardHeader>
                  <CardTitle>Staff Performance</CardTitle>
                  <CardDescription>Concern handling by staff members</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    {[
                      { name: "Prof. Smith", handled: 23, resolved: 21, rate: 91.3 },
                      { name: "Dr. Johnson", handled: 18, resolved: 17, rate: 94.4 },
                      { name: "Ms. Garcia", handled: 15, resolved: 14, rate: 93.3 },
                      { name: "Mr. Brown", handled: 12, resolved: 10, rate: 83.3 },
                    ].map((staff, index) => (
                      <div key={index} className="flex items-center justify-between">
                        <div className="flex-1">
                          <p className="font-medium text-sm">{staff.name}</p>
                          <div className="w-full bg-gray-200 rounded-full h-2 mt-1">
                            <div className="bg-[#2480EA] h-2 rounded-full" style={{ width: `${staff.rate}%` }}></div>
                          </div>
                        </div>
                        <div className="ml-4 text-right">
                          <Badge variant="secondary">{staff.rate}%</Badge>
                          <p className="text-xs text-gray-500 mt-1">
                            {staff.resolved}/{staff.handled}
                          </p>
                        </div>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle>Concern Categories</CardTitle>
                  <CardDescription>Most common concern types in your department</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    {[
                      { category: "Laboratory Issues", count: 28, percentage: 31.5 },
                      { category: "Course Registration", count: 22, percentage: 24.7 },
                      { category: "Technical Support", count: 18, percentage: 20.2 },
                      { category: "Academic Guidance", count: 12, percentage: 13.5 },
                      { category: "Other", count: 9, percentage: 10.1 },
                    ].map((item, index) => (
                      <div key={index} className="flex items-center justify-between">
                        <div className="flex-1">
                          <p className="font-medium text-sm">{item.category}</p>
                          <div className="w-full bg-gray-200 rounded-full h-2 mt-1">
                            <div
                              className="bg-[#2480EA] h-2 rounded-full"
                              style={{ width: `${item.percentage}%` }}
                            ></div>
                          </div>
                        </div>
                        <div className="ml-4 text-right">
                          <p className="font-medium text-sm">{item.count}</p>
                          <p className="text-xs text-gray-500">{item.percentage}%</p>
                        </div>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <BarChart3 className="h-5 w-5" />
                    Monthly Trends
                  </CardTitle>
                  <CardDescription>Concern volume and resolution trends</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    {[
                      { month: "January", concerns: 89, resolved: 82, rate: 92.1 },
                      { month: "December", concerns: 76, resolved: 71, rate: 93.4 },
                      { month: "November", concerns: 68, resolved: 62, rate: 91.2 },
                      { month: "October", concerns: 72, resolved: 65, rate: 90.3 },
                    ].map((month, index) => (
                      <div key={index} className="flex items-center justify-between">
                        <div className="flex-1">
                          <p className="font-medium text-sm">{month.month}</p>
                          <div className="w-full bg-gray-200 rounded-full h-2 mt-1">
                            <div className="bg-[#2480EA] h-2 rounded-full" style={{ width: `${month.rate}%` }}></div>
                          </div>
                        </div>
                        <div className="ml-4 text-right">
                          <p className="font-medium text-sm">{month.concerns}</p>
                          <p className="text-xs text-gray-500">{month.rate}% resolved</p>
                        </div>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle>Student Engagement</CardTitle>
                  <CardDescription>Student participation by course</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    {[
                      { course: "BSIT 3rd Year", students: 45, concerns: 28, engagement: 62.2 },
                      { course: "BSIT 2nd Year", students: 52, concerns: 22, engagement: 42.3 },
                      { course: "BSIT 4th Year", students: 38, concerns: 18, engagement: 47.4 },
                      { course: "BSIT 1st Year", students: 48, concerns: 15, engagement: 31.3 },
                    ].map((course, index) => (
                      <div key={index} className="flex items-center justify-between">
                        <div className="flex-1">
                          <p className="font-medium text-sm">{course.course}</p>
                          <p className="text-xs text-gray-500">{course.students} students</p>
                        </div>
                        <div className="text-right">
                          <p className="font-medium text-sm">{course.concerns} concerns</p>
                          <Badge variant="secondary">{course.engagement}% engagement</Badge>
                        </div>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            </div>
          </div>
        </main>
      </div>
    </ProtectedRoute>
  )
}
