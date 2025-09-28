"use client"

import { UserManagement } from "@/components/admin/users/user-management"

export default function AdminUsersPage() {
  return (
    <>
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-[#1E2A78]">User Management</h1>
        <p className="text-gray-600">Add, edit, and manage user accounts and roles.</p>
      </div>
      <UserManagement />
    </>
  )
}
