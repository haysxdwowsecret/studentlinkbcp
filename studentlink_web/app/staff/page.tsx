"use client"

import { ProtectedRoute } from "@/components/protected-route"
import { StaffDashboard } from "@/components/staff/staff-dashboard"
import { RoleBasedNav } from "@/components/navigation/role-based-nav"

export default function StaffPage() {
  return (
    <ProtectedRoute allowedRoles={["staff"]}>
      <div className="flex h-screen bg-gray-50">
        <RoleBasedNav />
        <main className="flex-1 overflow-auto p-6">
          <div className="max-w-7xl mx-auto">
            <div className="mb-6">
              <h1 className="text-3xl font-bold text-[#1E2A78]">Staff Dashboard</h1>
              <p className="text-gray-600">Your assigned tasks and concerns overview.</p>
            </div>
            <StaffDashboard />
          </div>
        </main>
      </div>
    </ProtectedRoute>
  )
}
