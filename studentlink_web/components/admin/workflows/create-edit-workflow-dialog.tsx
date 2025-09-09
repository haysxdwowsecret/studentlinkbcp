import { useState, useEffect } from "react"
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"

export function CreateEditWorkflowDialog({ isOpen, onClose, onSave, workflow }) {
  const [name, setName] = useState("")
  const [triggerType, setTriggerType] = useState("keyword")
  const [triggerValue, setTriggerValue] = useState("")
  const [actionType, setActionType] = useState("assign-department")
  const [actionValue, setActionValue] = useState("")

  useEffect(() => {
    if (workflow) {
      setName(workflow.name)
      setTriggerType(workflow.trigger.type)
      setTriggerValue(workflow.trigger.value)
      setActionType(workflow.action.type)
      setActionValue(workflow.action.value)
    } else {
      setName("")
      setTriggerType("keyword")
      setTriggerValue("")
      setActionType("assign-department")
      setActionValue("")
    }
  }, [workflow, isOpen])

  const handleSave = () => {
    onSave({
      id: workflow?.id,
      name,
      trigger: { type: triggerType, value: triggerValue },
      action: { type: actionType, value: actionValue },
    })
    onClose()
  }

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{workflow ? "Edit Rule" : "Create Rule"}</DialogTitle>
        </DialogHeader>
        <div className="space-y-4">
          <Input
            placeholder="Rule Name"
            value={name}
            onChange={(e) => setName(e.target.value)}
          />
          <div>
            <p className="font-medium mb-2">Trigger</p>
            <div className="grid grid-cols-2 gap-4">
              <Select value={triggerType} onValueChange={setTriggerType}>
                <SelectTrigger>
                  <SelectValue placeholder="Trigger Type" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="keyword">Keyword</SelectItem>
                  <SelectItem value="time-unanswered">Time Unanswered</SelectItem>
                </SelectContent>
              </Select>
              <Input
                placeholder="Trigger Value"
                value={triggerValue}
                onChange={(e) => setTriggerValue(e.target.value)}
              />
            </div>
          </div>
          <div>
            <p className="font-medium mb-2">Action</p>
            <div className="grid grid-cols-2 gap-4">
              <Select value={actionType} onValueChange={setActionType}>
                <SelectTrigger>
                  <SelectValue placeholder="Action Type" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="assign-department">Assign to Department</SelectItem>
                  <SelectItem value="escalate-to-head">Escalate to Head</SelectItem>
                </SelectContent>
              </Select>
              <Input
                placeholder="Action Value"
                value={actionValue}
                onChange={(e) => setActionValue(e.target.value)}
              />
            </div>
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={onClose}>
            Cancel
          </Button>
          <Button onClick={handleSave} className="bg-[#1E2A78] hover:bg-[#2480EA]">
            Save
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
