"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { 
  BarChart3, 
  TrendingUp, 
  TrendingDown, 
  Clock, 
  CheckCircle, 
  AlertCircle,
  MessageSquare,
  Users,
  Calendar,
  Download
} from "lucide-react"
import { apiClient } from "@/lib/api-client"

interface DepartmentAnalyticsProps {
  department: {
    name: string
    code: string
  }
  concerns: any[]
}

interface AnalyticsData {
  totalConcerns: number
  resolvedConcerns: number
  pendingConcerns: number
  inProgressConcerns: number
  avgResponseTime: number
  satisfactionRate: number
  concernsByMonth: Array<{ month: string; count: number }>
  concernsByPriority: Array<{ priority: string; count: number }>
  concernsByStatus: Array<{ status: string; count: number }>
  recentTrends: {
    concernsGrowth: number
    resolutionGrowth: number
    responseTimeChange: number
  }
}

export function DepartmentAnalytics({ department, concerns }: DepartmentAnalyticsProps) {
  const [analyticsData, setAnalyticsData] = useState<AnalyticsData | null>(null)
  const [loading, setLoading] = useState(true)
  const [timeRange, setTimeRange] = useState("30")
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const calculateAnalytics = () => {
      try {
        // Calculate analytics from concerns data
        const totalConcerns = concerns.length
        const resolvedConcerns = concerns.filter(c => c.status === 'resolved').length
        const pendingConcerns = concerns.filter(c => c.status === 'pending').length
        const inProgressConcerns = concerns.filter(c => c.status === 'in_progress').length

        // Calculate average response time from real data
        const avgResponseTime = 0 // Will be calculated from real response time data

        // Calculate satisfaction rate from real data
        const satisfactionRate = 0 // Will be calculated from real satisfaction data

        // Group concerns by month
        const concernsByMonth = concerns.reduce((acc, concern) => {
          const month = new Date(concern.created_at).toLocaleDateString('en-US', { month: 'short' })
          const existing = acc.find((item: any) => item.month === month)
          if (existing) {
            existing.count++
          } else {
            acc.push({ month, count: 1 })
          }
          return acc
        }, [] as Array<{ month: string; count: number }>)

        // Group concerns by priority
        const concernsByPriority = concerns.reduce((acc, concern) => {
          const priority = concern.priority || 'low'
          const existing = acc.find((item: any) => item.priority === priority)
          if (existing) {
            existing.count++
          } else {
            acc.push({ priority, count: 1 })
          }
          return acc
        }, [] as Array<{ priority: string; count: number }>)

        // Group concerns by status
        const concernsByStatus = concerns.reduce((acc, concern) => {
          const status = concern.status || 'pending'
          const existing = acc.find((item: any) => item.status === status)
          if (existing) {
            existing.count++
          } else {
            acc.push({ status, count: 1 })
          }
          return acc
        }, [] as Array<{ status: string; count: number }>)

        // Calculate trends from real data
        const recentTrends = {
          concernsGrowth: 0, // Will be calculated from real trend data
          resolutionGrowth: 0, // Will be calculated from real trend data
          responseTimeChange: 0 // Will be calculated from real trend data
        }

        setAnalyticsData({
          totalConcerns,
          resolvedConcerns,
          pendingConcerns,
          inProgressConcerns,
          avgResponseTime,
          satisfactionRate,
          concernsByMonth,
          concernsByPriority,
          concernsByStatus,
          recentTrends
        })
      } catch (err) {
        setError("Failed to calculate analytics")
        console.error('Analytics calculation error:', err)
      } finally {
        setLoading(false)
      }
    }

    calculateAnalytics()
  }, [concerns, timeRange])

  const handleExportReport = async () => {
    try {
      const blob = await apiClient.exportReport('department-analytics', {
        department_code: department.code,
        time_range: timeRange
      })
      
      // Create download link
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `${department.code}-analytics-${new Date().toISOString().split('T')[0]}.csv`
      document.body.appendChild(a)
      a.click()
      window.URL.revokeObjectURL(url)
      document.body.removeChild(a)
    } catch (error) {
      console.error('Failed to export report:', error)
    }
  }

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
          {[1, 2, 3, 4].map((i) => (
            <Card key={i}>
              <CardContent className="p-6">
                <div className="h-4 w-20 bg-gray-200 rounded animate-pulse mb-2"></div>
                <div className="h-8 w-16 bg-gray-200 rounded animate-pulse"></div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    )
  }

  if (error || !analyticsData) {
    return (
      <div className="text-center py-8">
        <AlertCircle className="h-12 w-12 text-red-500 mx-auto mb-4" />
        <h3 className="text-lg font-medium text-gray-900 mb-2">Unable to load analytics</h3>
        <p className="text-gray-500">{error || "No data available"}</p>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Time Range Selector */}
      <div className="flex justify-between items-center">
        <h2 className="text-2xl font-bold text-[#1E2A78]">Analytics Dashboard</h2>
        <div className="flex gap-3">
          <Select value={timeRange} onValueChange={setTimeRange}>
            <SelectTrigger className="w-40">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="7">Last 7 days</SelectItem>
              <SelectItem value="30">Last 30 days</SelectItem>
              <SelectItem value="90">Last 90 days</SelectItem>
              <SelectItem value="365">Last year</SelectItem>
            </SelectContent>
          </Select>
          <Button onClick={handleExportReport} variant="outline">
            <Download className="h-4 w-4 mr-2" />
            Export Report
          </Button>
        </div>
      </div>

      {/* Key Metrics */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <Card>
          <CardContent className="p-6">
            <div className="flex items-center">
              <MessageSquare className="h-8 w-8 text-[#1E2A78]" />
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Total Concerns</p>
                <p className="text-2xl font-bold text-[#1E2A78]">{analyticsData.totalConcerns}</p>
                <div className="flex items-center mt-1">
                  <TrendingUp className="h-3 w-3 text-green-500 mr-1" />
                  <span className="text-xs text-green-600">+{analyticsData.recentTrends.concernsGrowth}%</span>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-6">
            <div className="flex items-center">
              <CheckCircle className="h-8 w-8 text-green-600" />
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Resolved</p>
                <p className="text-2xl font-bold text-[#1E2A78]">{analyticsData.resolvedConcerns}</p>
                <div className="flex items-center mt-1">
                  <TrendingUp className="h-3 w-3 text-green-500 mr-1" />
                  <span className="text-xs text-green-600">+{analyticsData.recentTrends.resolutionGrowth}%</span>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-6">
            <div className="flex items-center">
              <Clock className="h-8 w-8 text-orange-600" />
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Avg Response Time</p>
                <p className="text-2xl font-bold text-[#1E2A78]">{analyticsData.avgResponseTime}h</p>
                <div className="flex items-center mt-1">
                  <TrendingDown className="h-3 w-3 text-green-500 mr-1" />
                  <span className="text-xs text-green-600">{analyticsData.recentTrends.responseTimeChange}%</span>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-6">
            <div className="flex items-center">
              <Users className="h-8 w-8 text-blue-600" />
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-600">Satisfaction Rate</p>
                <p className="text-2xl font-bold text-[#1E2A78]">{analyticsData.satisfactionRate}%</p>
                <div className="flex items-center mt-1">
                  <TrendingUp className="h-3 w-3 text-green-500 mr-1" />
                  <span className="text-xs text-green-600">+3%</span>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Charts Section */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Concerns by Status */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center">
              <BarChart3 className="h-5 w-5 mr-2" />
              Concerns by Status
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {analyticsData.concernsByStatus.map((item) => (
                <div key={item.status} className="flex items-center justify-between">
                  <div className="flex items-center">
                    <Badge className={
                      item.status === 'resolved' ? 'bg-green-100 text-green-800' :
                      item.status === 'in_progress' ? 'bg-blue-100 text-blue-800' :
                      'bg-gray-100 text-gray-800'
                    }>
                      {item.status.charAt(0).toUpperCase() + item.status.slice(1)}
                    </Badge>
                  </div>
                  <span className="font-medium">{item.count}</span>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Concerns by Priority */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center">
              <AlertCircle className="h-5 w-5 mr-2" />
              Concerns by Priority
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {analyticsData.concernsByPriority.map((item) => (
                <div key={item.priority} className="flex items-center justify-between">
                  <div className="flex items-center">
                    <Badge className={
                      item.priority === 'urgent' ? 'bg-red-100 text-red-800' :
                      item.priority === 'high' ? 'bg-orange-100 text-orange-800' :
                      item.priority === 'medium' ? 'bg-yellow-100 text-yellow-800' :
                      'bg-gray-100 text-gray-800'
                    }>
                      {item.priority.charAt(0).toUpperCase() + item.priority.slice(1)}
                    </Badge>
                  </div>
                  <span className="font-medium">{item.count}</span>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Monthly Trends */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center">
            <Calendar className="h-5 w-5 mr-2" />
            Monthly Trends
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-3">
            {analyticsData.concernsByMonth.length > 0 ? (
              analyticsData.concernsByMonth.map((item) => (
                <div key={item.month} className="flex items-center justify-between">
                  <span className="font-medium">{item.month}</span>
                  <div className="flex items-center">
                    <div className="w-32 bg-gray-200 rounded-full h-2 mr-3">
                      <div 
                        className="bg-[#1E2A78] h-2 rounded-full" 
                        style={{ width: `${(item.count / Math.max(...analyticsData.concernsByMonth.map(m => m.count))) * 100}%` }}
                      ></div>
                    </div>
                    <span className="text-sm text-gray-600">{item.count}</span>
                  </div>
                </div>
              ))
            ) : (
              <p className="text-gray-500 text-center py-4">No data available for the selected time range</p>
            )}
          </div>
        </CardContent>
      </Card>
    </div>
  )
}

