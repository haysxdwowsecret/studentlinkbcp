"use client"

import { ConcernsManagement } from "@/components/admin/concerns/concerns-management"

export default function AdminConcernsPage() {
  return (
    <>
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-[#1E2A78]">All Concerns</h1>
        <p className="text-gray-600">View and manage all student concerns from one place.</p>
      </div>
      <ConcernsManagement />
    </>
  )
}
