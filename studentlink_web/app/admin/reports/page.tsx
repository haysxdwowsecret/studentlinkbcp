"use client"

import { ReportsAndAnalytics } from "@/components/admin/reports/reports-and-analytics"

export default function AdminReportsPage() {
  return (
    <>
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-[#1E2A78]">Reports & Analytics</h1>
        <p className="text-gray-600">View insights and generate reports on student concerns and portal activity.</p>
      </div>
      <ReportsAndAnalytics />
    </>
  )
}
