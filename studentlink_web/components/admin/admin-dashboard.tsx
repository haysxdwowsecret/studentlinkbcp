"use client"

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Users, MessageSquare, Bell, Settings, BarChart3, Shield, Database, Bot } from "lucide-react"
import { apiClient, DashboardStats } from "@/lib/api-client"
import { useEffect, useState } from "react"

export function AdminDashboard() {
  const [stats, setStats] = useState<DashboardStats | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const dashboardStats = await apiClient.getDashboardStats()
        setStats(dashboardStats)
      } catch (err) {
        console.error("Failed to fetch dashboard stats:", err)
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
      {/* Admin Overview Cards */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card className="border-[#1E2A78]">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Users</CardTitle>
            <Users className="h-4 w-4 text-[#2480EA]" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-[#1E2A78]">{stats?.totalUsers || 0}</div>
            <p className="text-xs text-muted-foreground">Registered users</p>
          </CardContent>
        </Card>

        <Card className="border-[#1E2A78]">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Active Concerns</CardTitle>
            <MessageSquare className="h-4 w-4 text-[#E22824]" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-[#1E2A78]">{stats?.activeConcerns || 0}</div>
            <p className="text-xs text-muted-foreground">Currently open</p>
          </CardContent>
        </Card>

        <Card className="border-[#1E2A78]">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">System Health</CardTitle>
            <Shield className="h-4 w-4 text-green-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">{stats?.systemHealth || 0}%</div>
            <p className="text-xs text-muted-foreground">System uptime</p>
          </CardContent>
        </Card>

        <Card className="border-[#1E2A78]">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">AI Interactions</CardTitle>
            <Bot className="h-4 w-4 text-[#2480EA]" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-[#1E2A78]">{stats?.aiInteractions || 0}</div>
            <p className="text-xs text-muted-foreground">Total interactions</p>
          </CardContent>
        </Card>
      </div>

      {/* Admin Quick Actions */}
      <div className="grid gap-6 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle className="text-[#1E2A78]">System Management</CardTitle>
            <CardDescription>Manage system-wide settings and configurations</CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            <Button className="w-full justify-start bg-[#1E2A78] hover:bg-[#2480EA]">
              <Users className="mr-2 h-4 w-4" />
              Manage All Users
            </Button>
            <Button className="w-full justify-start bg-[#1E2A78] hover:bg-[#2480EA]">
              <Database className="mr-2 h-4 w-4" />
              Database Administration
            </Button>
            <Button className="w-full justify-start bg-[#1E2A78] hover:bg-[#2480EA]">
              <Settings className="mr-2 h-4 w-4" />
              System Configuration
            </Button>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-[#1E2A78]">AI & Analytics</CardTitle>
            <CardDescription>Configure AI features and view system analytics</CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            <Button className="w-full justify-start bg-[#2480EA] hover:bg-[#1E2A78]">
              <Bot className="mr-2 h-4 w-4" />
              AI Chatbot Settings
            </Button>
            <Button className="w-full justify-start bg-[#2480EA] hover:bg-[#1E2A78]">
              <BarChart3 className="mr-2 h-4 w-4" />
              System Analytics
            </Button>
            <Button className="w-full justify-start bg-[#2480EA] hover:bg-[#1E2A78]">
              <Bell className="mr-2 h-4 w-4" />
              Notification Center
            </Button>
          </CardContent>
        </Card>
      </div>

      {/* Recent System Activity */}
      <Card>
        <CardHeader>
          <CardTitle className="text-[#1E2A78]">Recent System Activity</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {stats?.departmentStats && stats.departmentStats.length > 0 ? (
              stats.departmentStats.map((dept, index) => (
                <div key={index} className="flex items-center justify-between border-b pb-2">
                  <div>
                    <p className="font-medium text-[#1E2A78]">{dept.department} Department</p>
                    <p className="text-sm text-muted-foreground">
                      {dept.concernCount} concerns, {dept.resolvedCount} resolved
                    </p>
                  </div>
                  <div className="text-right">
                    <Badge variant="secondary">Active</Badge>
                  </div>
                </div>
              ))
            ) : (
              <div className="text-center py-4 text-gray-500">
                <p>No recent activity data available</p>
              </div>
            )}
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
