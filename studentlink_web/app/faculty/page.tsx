"use client"

import { ProtectedRoute } from "@/components/protected-route"
import { FacultyDashboard } from "@/components/faculty/faculty-dashboard"
import { RoleBasedNav } from "@/components/navigation/role-based-nav"

export default function FacultyPage() {
  return (
    <ProtectedRoute allowedRoles={["faculty"]}>
      <div className="flex h-screen bg-gray-50">
        <RoleBasedNav />
        <main className="flex-1 overflow-auto p-6">
          <div className="max-w-7xl mx-auto">
            <div className="mb-6">
              <h1 className="text-3xl font-bold text-[#1E2A78]">Faculty Dashboard</h1>
              <p className="text-gray-600">Student interactions and course management.</p>
            </div>
            <FacultyDashboard />
          </div>
        </main>
      </div>
    </ProtectedRoute>
  )
}
