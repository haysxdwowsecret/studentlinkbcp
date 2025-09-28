"use client"

import { ProtectedRoute } from "@/components/protected-route"
import { RoleBasedNav } from "@/components/navigation/role-based-nav"
import { ChatDashboard } from "@/components/chat/chat-dashboard"

export default function DepartmentChatPage() {
  return (
    <ProtectedRoute allowedRoles={["department_head", "admin"]}>
      <div className="flex h-screen bg-gray-50">
        <RoleBasedNav />
        <main className="flex-1 overflow-auto">
          <div className="h-full">
            <ChatDashboard />
          </div>
        </main>
      </div>
    </ProtectedRoute>
  )
}

