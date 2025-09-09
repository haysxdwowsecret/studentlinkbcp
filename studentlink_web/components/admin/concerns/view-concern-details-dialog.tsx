import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter, DialogDescription } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"

export function ViewConcernDetailsDialog({ isOpen, onClose, concern }) {
  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="max-w-2xl">
        <DialogHeader>
          <DialogTitle>{concern.subject}</DialogTitle>
          <DialogDescription>
            From: {concern.student.name} ({concern.student.id}) | Submitted: {new Date(concern.submittedAt).toLocaleString()}
          </DialogDescription>
        </DialogHeader>
        <div className="space-y-6">
          <div>
            <h3 className="font-medium text-[#1E2A78]">Message</h3>
            <p className="bg-gray-50 p-3 rounded-md">{concern.message}</p>
          </div>

          <div>
            <h3 className="font-medium text-[#1E2A78]">Internal Notes</h3>
            {/* Placeholder for internal notes/timeline */}
            <div className="bg-gray-50 p-3 rounded-md min-h-[100px]">
              <p className="text-sm text-gray-500">No notes yet.</p>
            </div>
          </div>

          <div>
            <h3 className="font-medium text-[#1E2A78]">Conversation History</h3>
            <div className="space-y-4 bg-gray-50 p-3 rounded-md">
              {concern.history.map((entry, index) => (
                <div key={index}>
                  <p className="font-medium">{entry.actor}</p>
                  <p className="text-sm text-muted-foreground">{new Date(entry.timestamp).toLocaleString()}</p>
                  <p className="mt-1">{entry.comment}</p>
                </div>
              ))}
            </div>
          </div>

          <div>
            <h3 className="font-medium text-[#1E2A78]">Actions</h3>
            <div className="flex space-x-2 mt-2">
              <Button variant="outline">Assign to Staff</Button>
              <Button variant="outline">Escalate</Button>
              <Button>Mark as Resolved</Button>
            </div>
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={onClose}>
            Close
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
