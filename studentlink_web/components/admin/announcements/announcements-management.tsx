import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Plus } from "lucide-react"
import { CreateAnnouncementDialog } from "./create-announcement-dialog"
import { apiClient, type Announcement } from "@/lib/api-client"

export function AnnouncementsManagement() {
  const [announcements, setAnnouncements] = useState<Announcement[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [isCreateOpen, setCreateOpen] = useState(false)

  // Fetch announcements from API
  useEffect(() => {
    const fetchAnnouncements = async () => {
      try {
        setLoading(true)
        setError(null)
        const result = await apiClient.getAnnouncements({ status: 'published' })
        setAnnouncements(result.data)
      } catch (error) {
        console.error('Failed to fetch announcements:', error)
        setError(error instanceof Error ? error.message : 'Failed to load announcements')
        setAnnouncements([]) // Fall back to empty array on error
      } finally {
        setLoading(false)
      }
    }

    fetchAnnouncements()
  }, [])

  const handleCreateAnnouncement = async (announcement: any) => {
    try {
      const newAnnouncement = await apiClient.createAnnouncement({
        title: announcement.title,
        content: announcement.content,
        type: announcement.type || 'general',
        priority: announcement.priority || 'medium',
        published_at: new Date().toISOString(),
      })
      setAnnouncements([newAnnouncement, ...announcements])
      setCreateOpen(false)
    } catch (error) {
      console.error('Failed to create announcement:', error)
      // You could show an error message to the user here
    }
  }

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle className="text-[#1E2A78]">Published Announcements</CardTitle>
          <Button onClick={() => setCreateOpen(true)} className="bg-[#1E2A78] hover:bg-[#2480EA]">
            <Plus className="mr-2 h-4 w-4" />
            New Announcement
          </Button>
        </CardHeader>
        <CardContent>
          {loading ? (
            <div className="text-center py-8">Loading announcements...</div>
          ) : error ? (
            <div className="text-center py-8">
              <div className="text-red-600 mb-2">Error loading announcements</div>
              <div className="text-sm text-muted-foreground">{error}</div>
              <Button 
                onClick={() => window.location.reload()} 
                variant="outline" 
                className="mt-4"
              >
                Retry
              </Button>
            </div>
          ) : (
            <div className="space-y-4">
              {announcements.length === 0 ? (
                <div className="text-center py-8 text-muted-foreground">
                  No announcements found. Create your first announcement using the button above.
                </div>
              ) : (
                announcements.map((ann) => (
              <div key={ann.id} className="border p-4 rounded-md">
                <h3 className="font-bold text-lg text-[#1E2A78]">{ann.title}</h3>
                <p className="text-sm text-muted-foreground">
                  Published by {ann.author} on {new Date(ann.createdAt).toLocaleDateString()}
                </p>
                <p className="mt-2">{ann.content}</p>
                <div className="flex space-x-2 mt-4">
                  <Button variant="outline" size="sm">Edit</Button>
                  <Button variant="destructive" size="sm">Delete</Button>
                  </div>
                </div>
                ))
              )}
            </div>
          )}
        </CardContent>
      </Card>

      <CreateAnnouncementDialog
        isOpen={isCreateOpen}
        onClose={() => setCreateOpen(false)}
        onCreate={handleCreateAnnouncement}
      />
    </div>
  )
}
