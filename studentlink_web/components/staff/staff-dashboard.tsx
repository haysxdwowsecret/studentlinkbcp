"use client"

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { MessageSquare, Clock, CheckCircle, User } from "lucide-react"
import { apiClient } from "@/lib/api-client"
import { useEffect, useState } from "react"

interface StaffStats {
  assignedConcerns: number
  inProgress: number
  resolvedToday: number
  responseRate: number
  priorityConcerns: Array<{
    title: string
    student: string
    priority: string
    time: string
  }>
  recentActivity: Array<{
    action: string
    student: string
    time: string
    status: string
  }>
}

export function StaffDashboard() {
  const [stats, setStats] = useState<StaffStats | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchStats = async () => {
      try {
        // Get staff-specific concerns
        const concernsResponse = await apiClient.getConcerns({ assigned_to: 1 }) // TODO: Get current user ID
        const concerns = concernsResponse.data
        
        const assignedConcerns = concerns.length
        const inProgress = concerns.filter(c => c.status === 'in_progress').length
        const resolvedToday = concerns.filter(c => 
          c.status === 'resolved' && 
          new Date(c.resolved_at || '').toDateString() === new Date().toDateString()
        ).length
        
        const priorityConcerns = concerns
          .filter(c => c.priority === 'high' || c.priority === 'urgent')
          .slice(0, 3)
          .map(concern => ({
            title: concern.subject,
            student: concern.student.name,
            priority: concern.priority,
            time: new Date(concern.created_at).toLocaleDateString()
          }))
        
        const recentActivity = concerns
          .slice(0, 4)
          .map(concern => ({
            action: `Concern: ${concern.subject}`,
            student: concern.student.name,
            time: new Date(concern.created_at).toLocaleDateString(),
            status: concern.status
          }))

        setStats({
          assignedConcerns,
          inProgress,
          resolvedToday,
          responseRate: 92, // TODO: Calculate actual response rate
          priorityConcerns,
          recentActivity
        })
      } catch (err) {
        console.error("Failed to fetch staff stats:", err)
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
      {/* Staff Overview Cards */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card className="border-[#1E2A78]">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Assigned Concerns</CardTitle>
            <MessageSquare className="h-4 w-4 text-[#2480EA]" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-[#1E2A78]">{stats?.assignedConcerns || 0}</div>
            <p className="text-xs text-muted-foreground">Total assigned</p>
          </CardContent>
        </Card>

        <Card className="border-[#1E2A78]">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">In Progress</CardTitle>
            <Clock className="h-4 w-4 text-[#DFD10F]" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-[#DFD10F]">{stats?.inProgress || 0}</div>
            <p className="text-xs text-muted-foreground">Active cases</p>
          </CardContent>
        </Card>

        <Card className="border-[#1E2A78]">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Resolved Today</CardTitle>
            <CheckCircle className="h-4 w-4 text-green-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">{stats?.resolvedToday || 0}</div>
            <p className="text-xs text-muted-foreground">Great work!</p>
          </CardContent>
        </Card>

        <Card className="border-[#1E2A78]">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Response Rate</CardTitle>
            <User className="h-4 w-4 text-[#2480EA]" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-[#1E2A78]">{stats?.responseRate || 0}%</div>
            <p className="text-xs text-muted-foreground">This week</p>
          </CardContent>
        </Card>
      </div>

      {/* Staff Quick Actions */}
      <div className="grid gap-6 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle className="text-[#1E2A78]">My Tasks</CardTitle>
            <CardDescription>Concerns assigned to you</CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            <Button className="w-full justify-start bg-[#1E2A78] hover:bg-[#2480EA]">
              <MessageSquare className="mr-2 h-4 w-4" />
              View My Concerns
            </Button>
            <Button className="w-full justify-start bg-[#1E2A78] hover:bg-[#2480EA]">
              <Clock className="mr-2 h-4 w-4" />
              Pending Responses
            </Button>
            <Button className="w-full justify-start bg-[#1E2A78] hover:bg-[#2480EA]">
              <CheckCircle className="mr-2 h-4 w-4" />
              Recently Resolved
            </Button>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-[#1E2A78]">Priority Concerns</CardTitle>
            <CardDescription>Items requiring immediate attention</CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            {stats?.priorityConcerns && stats.priorityConcerns.length > 0 ? (
              stats.priorityConcerns.map((concern, index) => (
                <div key={index} className="flex items-center justify-between p-2 border rounded">
                  <div>
                    <p className="font-medium text-sm text-[#1E2A78]">{concern.title}</p>
                    <p className="text-xs text-muted-foreground">{concern.student}</p>
                  </div>
                  <div className="text-right">
                    <Badge
                      variant={
                        concern.priority === "high" || concern.priority === "urgent"
                          ? "destructive"
                          : concern.priority === "medium"
                            ? "default"
                            : "secondary"
                      }
                    >
                      {concern.time}
                    </Badge>
                  </div>
                </div>
              ))
            ) : (
              <div className="text-center py-4 text-gray-500">
                <p>No priority concerns at this time</p>
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Recent Activity */}
      <Card>
        <CardHeader>
          <CardTitle className="text-[#1E2A78]">My Recent Activity</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {stats?.recentActivity && stats.recentActivity.length > 0 ? (
              stats.recentActivity.map((activity, index) => (
                <div key={index} className="flex items-center justify-between border-b pb-2">
                  <div>
                    <p className="font-medium text-[#1E2A78]">{activity.action}</p>
                    <p className="text-sm text-muted-foreground">{activity.student}</p>
                  </div>
                  <div className="text-right">
                    <Badge variant="secondary">{activity.time}</Badge>
                  </div>
                </div>
              ))
            ) : (
              <div className="text-center py-4 text-gray-500">
                <p>No recent activity</p>
              </div>
            )}
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
