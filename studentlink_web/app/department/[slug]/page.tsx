"use client"

import { useParams, useSearchParams } from "next/navigation"
import { useState, useEffect } from "react"
import { RoleBasedNav } from "@/components/navigation/role-based-nav"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { useAuth } from "@/components/auth-provider"
import { ProtectedRoute } from "@/components/protected-route"
import { ConcernDetailsDialog } from "@/components/department/concern-details-dialog"
import { DepartmentSettings } from "@/components/department/department-settings"
import { DepartmentAnalytics } from "@/components/department/department-analytics"
import { DepartmentAnnouncements } from "@/components/department/department-announcements"
import { 
  MessageSquare, 
  Users, 
  TrendingUp, 
  Clock, 
  CheckCircle, 
  AlertCircle,
  FileText,
  Bell,
  Settings,
  BarChart3
} from "lucide-react"

// Type definitions
interface Concern {
  id: number
  subject: string
  description: string
  status: 'pending' | 'in_progress' | 'resolved'
  priority: 'low' | 'medium' | 'high' | 'urgent'
  is_anonymous: boolean
  reference_number: string
  created_at: string
  student?: {
    name: string
  }
  department?: {
    name: string
  }
}

interface DepartmentStats {
  totalConcerns: number
  resolved: number
  inProcess: number
  pending: number
}

// Department data - this would come from API in real implementation
const departmentData = {
  "registrar-office": {
    name: "Registrar Office",
    code: "REGISTRAR",
    type: "administrative",
    headName: "Ms. Rosa Mendoza",
    email: "registrar@bcp.edu.ph",
    phone: "(02) 8XXX-XXXX",
    description: "Office of the Registrar - Student Records and Academic Services"
  },
  "cashier": {
    name: "Cashier",
    code: "CASHIER", 
    type: "administrative",
    headName: "Ms. Lourdes Cruz",
    email: "cashier@bcp.edu.ph",
    phone: "(02) 8XXX-XXXX",
    description: "Cashier Office - Financial Transactions and Payments"
  },
  "bookstore-and-uniform": {
    name: "Bookstore and Uniform",
    code: "BOOKSTORE",
    type: "administrative", 
    headName: "Ms. Teresa Reyes",
    email: "bookstore@bcp.edu.ph",
    phone: "(02) 8XXX-XXXX",
    description: "Bookstore and Uniform Services"
  },
  "prefect-of-discipline": {
    name: "Prefect of Discipline",
    code: "DISCIPLINE",
    type: "administrative",
    headName: "Mr. Carlos Morales", 
    email: "discipline@bcp.edu.ph",
    phone: "(02) 8XXX-XXXX",
    description: "Office of the Prefect of Discipline - Student Conduct and Discipline"
  },
  "library": {
    name: "Library",
    code: "LIBRARY",
    type: "administrative",
    headName: "Ms. Isabel Gutierrez",
    email: "library@bcp.edu.ph", 
    phone: "(02) 8XXX-XXXX",
    description: "College Library - Information Resources and Services"
  },
  "mis": {
    name: "MIS",
    code: "MIS",
    type: "administrative",
    headName: "Engr. Ricardo Silva",
    email: "mis@bcp.edu.ph",
    phone: "(02) 8XXX-XXXX", 
    description: "Management Information Systems - IT Support and Services"
  },
  "bs-accounting-information-system": {
    name: "BS in Accounting Information System",
    code: "BSAIS",
    type: "academic",
    headName: "Dr. Maria Santos",
    email: "bsais@bcp.edu.ph",
    phone: "(02) 8XXX-XXXX",
    description: "Department of Accounting Information System"
  },
  "bs-in-computer-engineering": {
    name: "BS in Computer Engineering",
    code: "BSCPE",
    type: "academic",
    headName: "Engr. Juan Dela Cruz",
    email: "bscpe@bcp.edu.ph",
    phone: "(02) 8XXX-XXXX",
    description: "Department of Computer Engineering"
  },
  "bs-criminology": {
    name: "BS in Criminology",
    code: "BSCrim",
    type: "academic",
    headName: "Dr. Roberto Garcia",
    email: "bscrim@bcp.edu.ph", 
    phone: "(02) 8XXX-XXXX",
    description: "Department of Criminology and Criminal Justice"
  },
  "bs-entrepreneurship": {
    name: "BS in Entrepreneurship",
    code: "BSEntrep",
    type: "academic",
    headName: "Prof. Miguel Ramos",
    email: "bsentrep@bcp.edu.ph",
    phone: "(02) 8XXX-XXXX",
    description: "Department of Entrepreneurship"
  },
  "bs-in-information-technology": {
    name: "BS in Information Technology",
    code: "BSIT",
    type: "academic",
    headName: "Engr. Carlos Morales",
    email: "bsit@bcp.edu.ph",
    phone: "(02) 8XXX-XXXX",
    description: "Department of Information Technology"
  },
  "bs-in-psychology": {
    name: "BS in Psychology",
    code: "BSPsych",
    type: "academic",
    headName: "Dr. Patricia Martinez",
    email: "bspsych@bcp.edu.ph",
    phone: "(02) 8XXX-XXXX",
    description: "Department of Psychology and Behavioral Sciences"
  },
  "blis": {
    name: "BLIS – Bachelor in Library Information Science",
    code: "BLIS",
    type: "academic",
    headName: "Prof. Sofia Herrera",
    email: "blis@bcp.edu.ph",
    phone: "(02) 8XXX-XXXX",
    description: "Department of Library and Information Science"
  },
  "bped": {
    name: "BPED – Bachelor in Physical Education",
    code: "BPED",
    type: "academic",
    headName: "Prof. Miguel Ramos",
    email: "bped@bcp.edu.ph",
    phone: "(02) 8XXX-XXXX",
    description: "Department of Physical Education and Sports"
  },
  "beed--bachelor-of-elementary-education": {
    name: "BEED – Bachelor of Elementary Education",
    code: "BEED",
    type: "academic",
    headName: "Dr. Elena Torres",
    email: "beed@bcp.edu.ph",
    phone: "(02) 8XXX-XXXX",
    description: "Department of Elementary Education"
  },
  "bsed-major-in-social-studies": {
    name: "BSED major in Social Studies",
    code: "BSED-Social Studies",
    type: "academic",
    headName: "Engr. Juan Dela Cruz",
    email: "bsedsoc@bcp.edu.ph",
    phone: "(02) 8XXX-XXXX",
    description: "Department of Secondary Education - Social Studies"
  },
  "btled--bachelor-of-technology-and-livelihood-education": {
    name: "BTLED – Bachelor of Technology and Livelihood Education",
    code: "BTLED",
    type: "academic",
    headName: "Prof. Miguel Ramos",
    email: "btled@bcp.edu.ph",
    phone: "(02) 8XXX-XXXX",
    description: "Department of Technology and Livelihood Education"
  },
  "bsed-major-in-values": {
    name: "BSED major in Values",
    code: "BSED-Values",
    type: "academic",
    headName: "Dr. Roberto Garcia",
    email: "bsedval@bcp.edu.ph",
    phone: "(02) 8XXX-XXXX",
    description: "Department of Secondary Education - Values"
  },
  "bsed-major-in-science": {
    name: "BSED major in Science",
    code: "BSED-Science",
    type: "academic",
    headName: "Dr. Elena Torres",
    email: "bsedsci@bcp.edu.ph",
    phone: "(02) 8XXX-XXXX",
    description: "Department of Secondary Education - Science"
  },
  "bs-in-tourism-management": {
    name: "BS in Tourism Management",
    code: "BSTM",
    type: "academic",
    headName: "Prof. Ana Rodriguez",
    email: "bstm@bcp.edu.ph",
    phone: "(02) 8XXX-XXXX",
    description: "Department of Tourism Management"
  },
  "bs-in-office-administration": {
    name: "BS in Office Administration",
    code: "BSOA",
    type: "academic",
    headName: "Prof. Carmen Lopez",
    email: "bsoa@bcp.edu.ph",
    phone: "(02) 8XXX-XXXX", 
    description: "Department of Office Administration"
  },
  "bs-in-hospitality-management": {
    name: "BS in Hospitality Management",
    code: "BSHM",
    type: "academic",
    headName: "Prof. Sofia Herrera", 
    email: "bshm@bcp.edu.ph",
    phone: "(02) 8XXX-XXXX",
    description: "Department of Hospitality Management"
  },
  "bsba-major-in-financial-management": {
    name: "BSBA major in Financial Management",
    code: "BSBA-FM",
    type: "academic",
    headName: "Dr. Fernando Reyes",
    email: "bsbafm@bcp.edu.ph",
    phone: "(02) 8XXX-XXXX",
    description: "Department of Business Administration - Financial Management"
  },
  "bsba-major-in-human-resource-management": {
    name: "BSBA major in Human Resource Management",
    code: "BSBA-HRM",
    type: "academic",
    headName: "Dr. Carmen Dela Cruz",
    email: "bsbahrm@bcp.edu.ph",
    phone: "(02) 8XXX-XXXX",
    description: "Department of Business Administration - Human Resource Management"
  },
  "bsba-major-in-marketing-management": {
    name: "BSBA major in Marketing Management",
    code: "BSBA-MM",
    type: "academic",
    headName: "Dr. Antonio Santos",
    email: "bsbamm@bcp.edu.ph",
    phone: "(02) 8XXX-XXXX",
    description: "Department of Business Administration - Marketing Management"
  },
  "bsed-major-in-english": {
    name: "BSED major in English",
    code: "BSED-English",
    type: "academic",
    headName: "Dr. Maria Rodriguez",
    email: "bsedeng@bcp.edu.ph",
    phone: "(02) 8XXX-XXXX",
    description: "Department of Secondary Education - English"
  },
  "bsed-major-in-filipino": {
    name: "BSED major in Filipino",
    code: "BSED-Filipino",
    type: "academic",
    headName: "Dr. Lourdes Cruz",
    email: "bsedfil@bcp.edu.ph",
    phone: "(02) 8XXX-XXXX",
    description: "Department of Secondary Education - Filipino"
  },
  "bsed-major-in-mathematics": {
    name: "BSED major in Mathematics",
    code: "BSED-Math",
    type: "academic",
    headName: "Dr. Ricardo Silva",
    email: "bsedmath@bcp.edu.ph",
    phone: "(02) 8XXX-XXXX",
    description: "Department of Secondary Education - Mathematics"
  }
}

export default function DepartmentPage() {
  const params = useParams()
  const searchParams = useSearchParams()
  const { user } = useAuth()
  const slug = params.slug as string
  const department = departmentData[slug as keyof typeof departmentData]
  
  const [concerns, setConcerns] = useState<Concern[]>([])
  const [loading, setLoading] = useState(true)
  const [stats, setStats] = useState<DepartmentStats & { avgResponseTime: string }>({
    totalConcerns: 0,
    resolved: 0,
    inProcess: 0,
    pending: 0,
    avgResponseTime: "0 hours"
  })
  const [selectedConcern, setSelectedConcern] = useState<Concern | null>(null)
  const [isConcernDialogOpen, setIsConcernDialogOpen] = useState(false)
  const [activeTab, setActiveTab] = useState("concerns")

  // Handle tab parameter from URL
  useEffect(() => {
    const tab = searchParams.get('tab')
    if (tab && ['concerns', 'announcements', 'analytics', 'settings'].includes(tab)) {
      setActiveTab(tab)
    }
  }, [searchParams])

  // Handle tab change
  const handleTabChange = (value: string) => {
    setActiveTab(value)
    // Update URL without page reload
    const url = new URL(window.location.href)
    url.searchParams.set('tab', value)
    window.history.pushState({}, '', url.toString())
  }

  // Fetch department concerns
  useEffect(() => {
    const fetchConcerns = async () => {
      if (!user || !department) return
      
      try {
        setLoading(true)
        const response = await fetch('/api/concerns', {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('auth_token')}`,
            'Content-Type': 'application/json'
          }
        })
        
        if (response.ok) {
          const data = await response.json()
          const departmentConcerns = data.data.filter((concern: Concern) => 
            concern.department?.name === department.name
          )
          
          setConcerns(departmentConcerns)
          
          // Calculate stats
          const total = departmentConcerns.length
          const resolved = departmentConcerns.filter((c: Concern) => c.status === 'resolved').length
          const inProcess = departmentConcerns.filter((c: Concern) => c.status === 'in_progress').length
          const pending = departmentConcerns.filter((c: Concern) => c.status === 'pending').length
          
          setStats({
            totalConcerns: total,
            resolved,
            inProcess,
            pending,
            avgResponseTime: "2.5 hours" // TODO: Calculate from actual data
          })
        }
      } catch (error) {
        console.error('Error fetching concerns:', error)
      } finally {
        setLoading(false)
      }
    }

    fetchConcerns()
  }, [user, department])

  const handleViewConcernDetails = (concern: Concern) => {
    setSelectedConcern(concern)
    setIsConcernDialogOpen(true)
  }

  const handleConcernUpdate = () => {
    // Refresh concerns data
    const fetchConcerns = async () => {
      if (!user || !department) return

      try {
        setLoading(true)
        const response = await fetch('/api/concerns')
        const data = await response.json()
        
        if (data.success) {
          const departmentConcerns = data.data.filter((concern: Concern) =>
            concern.department?.name === department.name
          )
          setConcerns(departmentConcerns)
          
          // Update stats
          const resolved = departmentConcerns.filter((c: Concern) => c.status === 'resolved').length
          const inProcess = departmentConcerns.filter((c: Concern) => c.status === 'in_progress').length
          const pending = departmentConcerns.filter((c: Concern) => c.status === 'pending').length
          
          setStats({
            totalConcerns: departmentConcerns.length,
            resolved,
            inProcess,
            pending,
            avgResponseTime: "2.5 hours" // TODO: Calculate actual response time
          })
        }
      } catch (error) {
        console.error('Failed to fetch concerns:', error)
      } finally {
        setLoading(false)
      }
    }

    fetchConcerns()
  }

  if (!department) {
    return (
      <ProtectedRoute allowedRoles={["department_head"]}>
        <div className="flex h-screen bg-gray-50">
          <RoleBasedNav />
          <div className="flex-1 flex items-center justify-center">
            <div className="text-center">
              <h1 className="text-2xl font-bold text-gray-900 mb-4">Department Not Found</h1>
              <p className="text-gray-600">The requested department does not exist.</p>
            </div>
          </div>
        </div>
      </ProtectedRoute>
    )
  }

  return (
    <ProtectedRoute allowedRoles={["department_head"]}>
    <div className="flex h-screen bg-gray-50">
      <RoleBasedNav />

      <div className="flex-1 overflow-y-auto">
        {/* Header */}
        <header className="bg-white shadow-sm border-b border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-bold text-[#1E2A78]">{department.name}</h1>
              <p className="text-gray-600">{department.description}</p>
              <div className="flex items-center mt-2 space-x-4">
                <Badge className={department.type === 'academic' ? 'bg-blue-100 text-blue-800' : 'bg-green-100 text-green-800'}>
                  {department.type === 'academic' ? 'Academic Department' : 'Administrative Department'}
                </Badge>
                <span className="text-sm text-gray-500">Head: {department.headName}</span>
              </div>
            </div>
            <div className="flex items-center space-x-4">
              <Button variant="outline" className="bg-transparent">
                <Settings className="h-4 w-4 mr-2" />
                Settings
              </Button>
              <Button className="bg-[#1E2A78] hover:bg-[#2480EA]">
                <MessageSquare className="h-4 w-4 mr-2" />
                New Response
              </Button>
            </div>
          </div>
        </header>

        <div className="p-6">
          {/* Statistics Cards - Only show for concerns tab */}
          {activeTab === "concerns" && (
            <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
            <Card>
              <CardContent className="p-6">
                <div className="flex items-center">
                  <MessageSquare className="h-8 w-8 text-[#1E2A78]" />
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-600">Total Concerns</p>
                    <p className="text-2xl font-bold text-[#1E2A78]">{stats.totalConcerns}</p>
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
                    <p className="text-2xl font-bold text-[#1E2A78]">{stats.resolved}</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="p-6">
                <div className="flex items-center">
                  <Clock className="h-8 w-8 text-orange-600" />
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-600">In Process</p>
                    <p className="text-2xl font-bold text-[#1E2A78]">{stats.inProcess}</p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="p-6">
                <div className="flex items-center">
                  <TrendingUp className="h-8 w-8 text-blue-600" />
                  <div className="ml-4">
                    <p className="text-sm font-medium text-gray-600">Avg Response</p>
                    <p className="text-2xl font-bold text-[#1E2A78]">{stats.avgResponseTime}</p>
                  </div>
                </div>
              </CardContent>
            </Card>
            </div>
          )}

          {/* Main Content Tabs */}
          <Tabs value={activeTab} onValueChange={handleTabChange} className="space-y-6">
            <TabsList className="grid w-full grid-cols-4">
              <TabsTrigger value="concerns">Concerns</TabsTrigger>
              <TabsTrigger value="announcements">Announcements</TabsTrigger>
              <TabsTrigger value="analytics">Analytics</TabsTrigger>
              <TabsTrigger value="settings">Settings</TabsTrigger>
            </TabsList>

            <TabsContent value="concerns" className="space-y-6">
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center">
                    <MessageSquare className="h-5 w-5 mr-2" />
                    Recent Concerns
                  </CardTitle>
                  <CardDescription>
                    Manage and respond to student concerns
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  {loading ? (
                    <div className="text-center py-8">
                      <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-[#1E2A78] mx-auto"></div>
                      <p className="text-gray-500 mt-2">Loading concerns...</p>
                    </div>
                  ) : concerns.length === 0 ? (
                    <div className="text-center py-8">
                      <MessageSquare className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                      <h3 className="text-lg font-medium text-gray-900 mb-2">No concerns yet</h3>
                      <p className="text-gray-500">Students haven't submitted any concerns to this department.</p>
                    </div>
                  ) : (
                    <div className="space-y-4">
                      {concerns.map((concern) => (
                        <div key={concern.id} className="flex items-center justify-between p-4 border rounded-lg hover:bg-gray-50">
                          <div className="flex-1">
                            <h3 className="font-medium text-gray-900">{concern.subject}</h3>
                            <p className="text-sm text-gray-500">
                              From: {concern.is_anonymous ? 'Anonymous Student' : (concern.student?.name || 'Unknown')}
                            </p>
                            <p className="text-xs text-gray-400">
                              {new Date(concern.created_at).toLocaleDateString()}
                            </p>
                            <p className="text-xs text-gray-400">
                              Reference: {concern.reference_number}
                            </p>
                          </div>
                          <div className="flex items-center space-x-3">
                            <Badge className={
                              concern.priority === 'urgent' ? 'bg-red-100 text-red-800' :
                              concern.priority === 'high' ? 'bg-orange-100 text-orange-800' :
                              concern.priority === 'medium' ? 'bg-yellow-100 text-yellow-800' :
                              'bg-gray-100 text-gray-800'
                            }>
                              {concern.priority?.charAt(0).toUpperCase() + concern.priority?.slice(1)}
                            </Badge>
                            <Badge className={
                              concern.status === 'resolved' ? 'bg-green-100 text-green-800' :
                              concern.status === 'in_progress' ? 'bg-blue-100 text-blue-800' :
                              'bg-gray-100 text-gray-800'
                            }>
                              {concern.status?.charAt(0).toUpperCase() + concern.status?.slice(1)}
                            </Badge>
                            <Button 
                              size="sm" 
                              variant="outline"
                              onClick={() => handleViewConcernDetails(concern)}
                            >
                              View Details
                            </Button>
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </CardContent>
              </Card>
            </TabsContent>

            <TabsContent value="announcements" className="space-y-6">
              <DepartmentAnnouncements department={department} />
            </TabsContent>

            <TabsContent value="analytics" className="space-y-6">
              <DepartmentAnalytics 
                department={department}
                concerns={concerns}
              />
            </TabsContent>

            <TabsContent value="settings" className="space-y-6">
              <DepartmentSettings 
                department={department}
                onUpdate={handleConcernUpdate}
              />
            </TabsContent>
          </Tabs>
        </div>
      </div>

      {/* Concern Details Dialog */}
      <ConcernDetailsDialog
        concern={selectedConcern}
        isOpen={isConcernDialogOpen}
        onClose={() => {
          setIsConcernDialogOpen(false)
          setSelectedConcern(null)
        }}
        onUpdate={handleConcernUpdate}
      />
    </div>
    </ProtectedRoute>
  )
}
