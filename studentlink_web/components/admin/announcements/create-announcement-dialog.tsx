import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { useState } from "react"

export function CreateAnnouncementDialog({ isOpen, onClose, onCreate }) {
  const [title, setTitle] = useState("")
  const [content, setContent] = useState("")

  const handleSubmit = () => {
    if (title && content) {
      onCreate({ title, content })
      onClose()
    } else {
      alert("Please fill out both title and content.")
    }
  }

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Create New Announcement</DialogTitle>
        </DialogHeader>
        <div className="space-y-4">
          <Input
            placeholder="Announcement Title"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
          />
          <Textarea
            placeholder="Announcement Content"
            value={content}
            onChange={(e) => setContent(e.target.value)}
            rows={6}
          />
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={onClose}>
            Cancel
          </Button>
          <Button onClick={handleSubmit} className="bg-[#1E2A78] hover:bg-[#2480EA]">
            Publish Announcement
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
