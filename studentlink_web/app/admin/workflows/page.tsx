"use client"

import { ProtectedRoute } from "@/components/protected-route"
import { WorkflowManagement } from "@/components/admin/workflows/workflow-management"
import { RoleBasedNav } from "@/components/navigation/role-based-nav"

export default function AdminWorkflowsPage() {
  return (
    <ProtectedRoute allowedRoles={["admin"]}>
      <div className="flex h-screen bg-gray-50">
        <RoleBasedNav />
        <main className="flex-1 overflow-auto p-6">
          <div className="max-w-7xl mx-auto">
            <div className="mb-6">
              <h1 className="text-3xl font-bold text-[#1E2A78]">Workflow Automation</h1>
              <p className="text-gray-600">Automate concern routing and escalation.</p>
            </div>
            <WorkflowManagement />
          </div>
        </main>
      </div>
    </ProtectedRoute>
  )
}
