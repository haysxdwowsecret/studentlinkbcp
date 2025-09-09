import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Plus } from "lucide-react"
import { CreateEditWorkflowDialog } from "./create-edit-workflow-dialog"
import { DeleteWorkflowDialog } from "./delete-workflow-dialog"

// Mock data for initial implementation
const mockWorkflows = [
  {
    id: "1",
    name: "Route to Cashier",
    trigger: { type: "keyword", value: "tuition,payment" },
    action: { type: "assign-department", value: "Cashier's Office" },
  },
  {
    id: "2",
    name: "Escalate Unanswered Concerns",
    trigger: { type: "time-unanswered", value: "48h" },
    action: { type: "escalate-to-head", value: null },
  },
]

export function WorkflowManagement() {
  const [workflows, setWorkflows] = useState(mockWorkflows)
  const [isCreateDialogOpen, setCreateDialogOpen] = useState(false)
  const [isEditDialogOpen, setEditDialogOpen] = useState(false)
  const [isDeleteDialogOpen, setDeleteDialogOpen] = useState(false)
  const [selectedWorkflow, setSelectedWorkflow] = useState(null)

  const handleCreateWorkflow = (workflow) => {
    // API call to create workflow would be here
    setWorkflows([...workflows, { ...workflow, id: `${Date.now()}` }])
  }

  const handleUpdateWorkflow = (updatedWorkflow) => {
    // API call to update workflow would be here
    setWorkflows(
      workflows.map((workflow) => (workflow.id === updatedWorkflow.id ? updatedWorkflow : workflow))
    )
  }

  const handleDeleteWorkflow = (workflowId) => {
    // API call to delete workflow would be here
    setWorkflows(workflows.filter((workflow) => workflow.id !== workflowId))
  }

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle className="text-[#1E2A78]">Automation Rules</CardTitle>
          <Button onClick={() => setCreateDialogOpen(true)} className="bg-[#1E2A78] hover:bg-[#2480EA]">
            <Plus className="mr-2 h-4 w-4" />
            Create Rule
          </Button>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {workflows.map((workflow) => (
              <div key={workflow.id} className="flex items-center justify-between border p-4 rounded-md">
                <div>
                  <p className="font-medium text-[#1E2A78]">{workflow.name}</p>
                  <p className="text-sm text-muted-foreground">
                    Trigger: {workflow.trigger.type} ({workflow.trigger.value}) -&gt; Action:{" "}
                    {workflow.action.type} ({workflow.action.value})
                  </p>
                </div>
                <div className="space-x-2">
                  <Button
                    variant="outline"
                    onClick={() => {
                      setSelectedWorkflow(workflow)
                      setEditDialogOpen(true)
                    }}
                  >
                    Edit
                  </Button>
                  <Button
                    variant="destructive"
                    onClick={() => {
                      setSelectedWorkflow(workflow)
                      setDeleteDialogOpen(true)
                    }}
                  >
                    Delete
                  </Button>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      <CreateEditWorkflowDialog
        isOpen={isCreateDialogOpen}
        onClose={() => setCreateDialogOpen(false)}
        onSave={handleCreateWorkflow}
      />

      {selectedWorkflow && (
        <CreateEditWorkflowDialog
          isOpen={isEditDialogOpen}
          onClose={() => {
            setEditDialogOpen(false)
            setSelectedWorkflow(null)
          }}
          onSave={handleUpdateWorkflow}
          workflow={selectedWorkflow}
        />
      )}

      {selectedWorkflow && (
        <DeleteWorkflowDialog
          isOpen={isDeleteDialogOpen}
          onClose={() => {
            setDeleteDialogOpen(false)
            setSelectedWorkflow(null)
          }}
          onDelete={() => {
            handleDeleteWorkflow(selectedWorkflow.id)
            setDeleteDialogOpen(false)
            setSelectedWorkflow(null)
          }}
          workflowName={selectedWorkflow.name}
        />
      )}
    </div>
  )
}
