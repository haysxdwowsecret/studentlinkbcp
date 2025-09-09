import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { ViewConcernDetailsDialog } from "./view-concern-details-dialog"
import { apiClient, type Concern } from "@/lib/api-client"

export function ConcernsManagement() {
  const [concerns, setConcerns] = useState<Concern[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedConcern, setSelectedConcern] = useState<Concern | null>(null)
  const [isViewDetailsOpen, setViewDetailsOpen] = useState(false)
  const [searchTerm, setSearchTerm] = useState("")

  // Fetch concerns from API
  useEffect(() => {
    const fetchConcerns = async () => {
      try {
        setLoading(true)
        const result = await apiClient.getConcerns()
        setConcerns(result.data)
      } catch (error) {
        console.error('Failed to fetch concerns:', error)
        setConcerns([]) // Fall back to empty array on error
      } finally {
        setLoading(false)
      }
    }

    fetchConcerns()
  }, [])

  const filteredConcerns = concerns.filter((concern) =>
    concern.subject?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    concern.student?.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    concern.department?.name?.toLowerCase().includes(searchTerm.toLowerCase())
  )

  const getConcernsByStatus = (status: string) => {
    if (status === "all") return filteredConcerns
    return filteredConcerns.filter((concern) => concern.status.toLowerCase() === status)
  }

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle className="text-[#1E2A78]">Manage Concerns</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex justify-between items-center mb-4">
            <Input
              placeholder="Search by subject, student, or department..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="max-w-sm"
            />
          </div>
          <Tabs defaultValue="all">
            <TabsList>
              <TabsTrigger value="all">All</TabsTrigger>
              <TabsTrigger value="pending">Pending</TabsTrigger>
              <TabsTrigger value="in-progress">In Progress</TabsTrigger>
              <TabsTrigger value="resolved">Resolved</TabsTrigger>
              <TabsTrigger value="escalated">Escalated</TabsTrigger>
            </TabsList>
            {["all", "pending", "in-progress", "resolved", "escalated"].map((status) => (
              <TabsContent key={status} value={status}>
                <div className="space-y-4 mt-4">
                  {loading ? (
                    <div className="text-center py-8">Loading concerns...</div>
                  ) : getConcernsByStatus(status).length === 0 ? (
                    <div className="text-center py-8 text-muted-foreground">
                      No concerns found for this status.
                    </div>
                  ) : (
                    getConcernsByStatus(status).map((concern) => (
                    <div
                      key={concern.id}
                      className="flex items-center justify-between border p-4 rounded-md"
                    >
                      <div>
                        <p className="font-medium text-[#1E2A78]">{concern.subject}</p>
                        <p className="text-sm text-muted-foreground">
                          From: {concern.student.name} ({concern.student.id}) | Department: {concern.department}
                        </p>
                      </div>
                      <div className="flex items-center space-x-2">
                        <span
                          className={`px-2 py-1 text-xs font-semibold rounded-full ${
                            concern.status === "Resolved"
                              ? "bg-green-100 text-green-800"
                              : concern.status === "Pending"
                              ? "bg-yellow-100 text-yellow-800"
                              : "bg-blue-100 text-blue-800"
                          }`}>
                          {concern.status}
                        </span>
                        <button
                          onClick={() => {
                            setSelectedConcern(concern)
                            setViewDetailsOpen(true)
                          }}
                          className="text-[#1E2A78] hover:underline"
                        >
                          View Details
                        </button>
                      </div>
                    </div>
                    ))
                  )}
                </div>
              </TabsContent>
            ))}
          </Tabs>
        </CardContent>
      </Card>

      {selectedConcern && (
        <ViewConcernDetailsDialog
          isOpen={isViewDetailsOpen}
          onClose={() => {
            setViewDetailsOpen(false)
            setSelectedConcern(null)
          }}
          concern={selectedConcern}
        />
      )}
    </div>
  )
}
