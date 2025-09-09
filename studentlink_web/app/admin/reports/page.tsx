"use client"

import { ProtectedRoute } from "@/components/protected-route"
import { ReportsAndAnalytics } from "@/components/admin/reports/reports-and-analytics"
import { RoleBasedNav } from "@/components/navigation/role-based-nav"

export default function AdminReportsPage() {
  return (
    <ProtectedRoute allowedRoles={["admin"]}>
      <div className="flex h-screen bg-gray-50">
        <RoleBasedNav />
        <main className="flex-1 overflow-auto p-6">
          <div className="max-w-7xl mx-auto">
            <div className="mb-6">
              <h1 className="text-3xl font-bold text-[#1E2A78]">Reports & Analytics</h1>
              <p className="text-gray-600">View insights and generate reports on student concerns and portal activity.</p>
            </div>
            <ReportsAndAnalytics />
          </div>
        </main>
      </div>
    </ProtectedRoute>
  )
}
