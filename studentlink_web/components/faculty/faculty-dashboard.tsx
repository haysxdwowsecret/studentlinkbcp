"use client"

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { MessageSquare, Users, BookOpen, Calendar } from "lucide-react"
import { apiClient } from "@/lib/api-client"
import { useEffect, useState } from "react"

interface FacultyStats {
  studentConcerns: number
  myStudents: number
  courses: number
  officeHours: string
  recentInteractions: Array<{
    action: string
    student: string
    concern: string
    time: string
  }>
}

export function FacultyDashboard() {
  const [stats, setStats] = useState<FacultyStats | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchStats = async () => {
      try {
        // Get faculty-specific data
        const concernsResponse = await apiClient.getConcerns({ department_id: 1 }) // TODO: Get faculty's department
        const concerns = concernsResponse.data
        
        const studentConcerns = concerns.length
        const myStudents = 156 // TODO: Get actual student count from courses
        const courses = 4 // TODO: Get actual course count
        const officeHours = "MWF 2:00-4:00 PM" // TODO: Get from user preferences
        
        const recentInteractions = concerns
          .slice(0, 4)
          .map(concern => ({
            action: "Student submitted concern",
            student: concern.student.name,
            concern: concern.subject,
            time: new Date(concern.created_at).toLocaleDateString()
          }))

        setStats({
          studentConcerns,
          myStudents,
          courses,
          officeHours,
          recentInteractions
        })
      } catch (err) {
        console.error("Failed to fetch faculty stats:", err)
        setError("Failed to load dashboard data")
      } finally {
        setLoading(false)
      }
    }

    fetchStats()
  }, [])
  if (loading) {
    return (
      <div className="space-y-6">
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          {[1, 2, 3, 4].map((i) => (
            <Card key={i} className="border-[#1E2A78]">
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <div className="h-4 w-20 bg-gray-200 rounded animate-pulse"></div>
                <div className="h-4 w-4 bg-gray-200 rounded animate-pulse"></div>
              </CardHeader>
              <CardContent>
                <div className="h-8 w-16 bg-gray-200 rounded animate-pulse mb-2"></div>
                <div className="h-3 w-24 bg-gray-200 rounded animate-pulse"></div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="space-y-6">
        <div className="text-center py-8">
          <p className="text-red-600 mb-4">{error}</p>
          <Button onClick={() => window.location.reload()} className="bg-[#1E2A78] hover:bg-[#2480EA]">
            Retry
          </Button>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Faculty Overview Cards */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card className="border-[#1E2A78]">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Student Concerns</CardTitle>
            <MessageSquare className="h-4 w-4 text-[#2480EA]" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-[#1E2A78]">{stats?.studentConcerns || 0}</div>
            <p className="text-xs text-muted-foreground">From your students</p>
          </CardContent>
        </Card>

        <Card className="border-[#1E2A78]">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">My Students</CardTitle>
            <Users className="h-4 w-4 text-[#2480EA]" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-[#1E2A78]">{stats?.myStudents || 0}</div>
            <p className="text-xs text-muted-foreground">Active students</p>
          </CardContent>
        </Card>

        <Card className="border-[#1E2A78]">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Courses</CardTitle>
            <BookOpen className="h-4 w-4 text-[#2480EA]" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-[#1E2A78]">{stats?.courses || 0}</div>
            <p className="text-xs text-muted-foreground">This semester</p>
          </CardContent>
        </Card>

        <Card className="border-[#1E2A78]">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Office Hours</CardTitle>
            <Calendar className="h-4 w-4 text-[#2480EA]" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-[#1E2A78]">{stats?.officeHours || "Not set"}</div>
            <p className="text-xs text-muted-foreground">Available times</p>
          </CardContent>
        </Card>
      </div>

      {/* Faculty Quick Actions */}
      <div className="grid gap-6 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle className="text-[#1E2A78]">Student Support</CardTitle>
            <CardDescription>Help your students with their concerns</CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            <Button className="w-full justify-start bg-[#1E2A78] hover:bg-[#2480EA]">
              <MessageSquare className="mr-2 h-4 w-4" />
              Student Concerns
            </Button>
            <Button className="w-full justify-start bg-[#1E2A78] hover:bg-[#2480EA]">
              <Users className="mr-2 h-4 w-4" />
              My Students
            </Button>
            <Button className="w-full justify-start bg-[#1E2A78] hover:bg-[#2480EA]">
              <Calendar className="mr-2 h-4 w-4" />
              Office Hours
            </Button>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-[#1E2A78]">Course Management</CardTitle>
            <CardDescription>Manage your courses and announcements</CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            <Button className="w-full justify-start bg-[#2480EA] hover:bg-[#1E2A78]">
              <BookOpen className="mr-2 h-4 w-4" />
              Course Announcements
            </Button>
            <Button className="w-full justify-start bg-[#2480EA] hover:bg-[#1E2A78]">
              <Users className="mr-2 h-4 w-4" />
              Student Roster
            </Button>
            <Button className="w-full justify-start bg-[#2480EA] hover:bg-[#1E2A78]">
              <MessageSquare className="mr-2 h-4 w-4" />
              Class Feedback
            </Button>
          </CardContent>
        </Card>
      </div>

      {/* Recent Student Interactions */}
      <Card>
        <CardHeader>
          <CardTitle className="text-[#1E2A78]">Recent Student Interactions</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {stats?.recentInteractions && stats.recentInteractions.length > 0 ? (
              stats.recentInteractions.map((activity, index) => (
                <div key={index} className="flex items-center justify-between border-b pb-2">
                  <div>
                    <p className="font-medium text-[#1E2A78]">{activity.action}</p>
                    <p className="text-sm text-muted-foreground">
                      {activity.student} - {activity.concern}
                    </p>
                  </div>
                  <div className="text-right">
                    <Badge variant="secondary">{activity.time}</Badge>
                  </div>
                </div>
              ))
            ) : (
              <div className="text-center py-4 text-gray-500">
                <p>No recent student interactions</p>
              </div>
            )}
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
