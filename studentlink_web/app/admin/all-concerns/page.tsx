"use client"

import { ProtectedRoute } from "@/components/protected-route"
import { ConcernsManagement } from "@/components/admin/concerns/concerns-management"
import { RoleBasedNav } from "@/components/navigation/role-based-nav"

export default function AdminConcernsPage() {
  return (
    <ProtectedRoute allowedRoles={["admin"]}>
      <div className="flex h-screen bg-gray-50">
        <RoleBasedNav />
        <main className="flex-1 overflow-auto p-6">
          <div className="max-w-7xl mx-auto">
            <div className="mb-6">
              <h1 className="text-3xl font-bold text-[#1E2A78]">All Concerns</h1>
              <p className="text-gray-600">View and manage all student concerns from one place.</p>
            </div>
            <ConcernsManagement />
          </div>
        </main>
      </div>
    </ProtectedRoute>
  )
}
