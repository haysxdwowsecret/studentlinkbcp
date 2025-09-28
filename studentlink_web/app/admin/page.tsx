"use client"

import { AdminDashboard } from "@/components/admin/admin-dashboard"

export default function AdminPage() {
  return (
    <>
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-[#1E2A78]">Admin Dashboard</h1>
        <p className="text-gray-600">System overview and management tools.</p>
      </div>
      <AdminDashboard />
    </>
  )
}
