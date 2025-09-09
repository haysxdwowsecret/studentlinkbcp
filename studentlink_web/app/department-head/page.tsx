"use client"

import { ProtectedRoute } from "@/components/protected-route"
import { DepartmentHeadDashboard } from "@/components/department-head/department-head-dashboard"
import { RoleBasedNav } from "@/components/navigation/role-based-nav"

export default function DepartmentHeadPage() {
  return (
    <ProtectedRoute allowedRoles={["department_head"]}>
      <div className="flex h-screen bg-gray-50">
        <RoleBasedNav />
        <main className="flex-1 overflow-auto p-6">
          <div className="max-w-7xl mx-auto">
            <div className="mb-6">
              <h1 className="text-3xl font-bold text-[#1E2A78]">Department Dashboard</h1>
              <p className="text-gray-600">Department overview and management tools.</p>
            </div>
            <DepartmentHeadDashboard />
          </div>
        </main>
      </div>
    </ProtectedRoute>
  )
}
