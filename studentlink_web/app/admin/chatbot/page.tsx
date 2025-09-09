"use client"

import { ProtectedRoute } from "@/components/protected-route"
import { ChatbotManagement } from "@/components/admin/chatbot/chatbot-management"
import { RoleBasedNav } from "@/components/navigation/role-based-nav"

export default function AdminChatbotPage() {
  return (
    <ProtectedRoute allowedRoles={["admin"]}>
      <div className="flex h-screen bg-gray-50">
        <RoleBasedNav />
        <main className="flex-1 overflow-auto p-6">
          <div className="max-w-7xl mx-auto">
            <div className="mb-6">
              <h1 className="text-3xl font-bold text-[#1E2A78]">AI Chatbot Management</h1>
              <p className="text-gray-600">Train, manage, and monitor the AI-powered student assistant.</p>
            </div>
            <ChatbotManagement />
          </div>
        </main>
      </div>
    </ProtectedRoute>
  )
}
