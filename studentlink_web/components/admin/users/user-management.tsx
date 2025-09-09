import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Plus } from "lucide-react"
import { AddUserDialog } from "./add-user-dialog"
import { EditUserDialog } from "./edit-user-dialog"
import { apiClient, type User } from "@/lib/api-client"

export function UserManagement() {
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(true)
  const [isAddUserOpen, setAddUserOpen] = useState(false)
  const [isEditUserOpen, setEditUserOpen] = useState(false)
  const [selectedUser, setSelectedUser] = useState<User | null>(null)
  const [searchTerm, setSearchTerm] = useState("")

  // Fetch users from API
  useEffect(() => {
    const fetchUsers = async () => {
      try {
        setLoading(true)
        const result = await apiClient.getUsers()
        setUsers(result.data)
      } catch (error) {
        console.error('Failed to fetch users:', error)
        setUsers([]) // Fall back to empty array on error
      } finally {
        setLoading(false)
      }
    }

    fetchUsers()
  }, [])

  const filteredUsers = users.filter(
    (user) =>
      user.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
      user.role.toLowerCase().includes(searchTerm.toLowerCase())
  )

  const handleAddUser = async (user: any) => {
    try {
      const newUser = await apiClient.createUser({
        name: user.name,
        email: user.email,
        password: user.password,
        role: user.role,
        department_id: user.department_id,
        phone: user.phone,
      })
      setUsers([newUser, ...users])
      setAddUserOpen(false)
    } catch (error) {
      console.error('Failed to create user:', error)
    }
  }

  const handleUpdateUser = async (updatedUser: User) => {
    try {
      const updated = await apiClient.updateUser(updatedUser.id, updatedUser)
      setUsers(users.map((user) => (user.id === updated.id ? updated : user)))
      setEditUserOpen(false)
      setSelectedUser(null)
    } catch (error) {
      console.error('Failed to update user:', error)
    }
  }

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle className="text-[#1E2A78]">All Users</CardTitle>
          <Button onClick={() => setAddUserOpen(true)} className="bg-[#1E2A78] hover:bg-[#2480EA]">
            <Plus className="mr-2 h-4 w-4" />
            Add New User
          </Button>
        </CardHeader>
        <CardContent>
          <div className="mb-4">
            <Input
              placeholder="Search by name, email, or role..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="max-w-sm"
            />
          </div>
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Email</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Role</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {loading ? (
                  <tr>
                    <td colSpan={4} className="px-6 py-4 text-center">Loading users...</td>
                  </tr>
                ) : filteredUsers.length === 0 ? (
                  <tr>
                    <td colSpan={4} className="px-6 py-4 text-center text-muted-foreground">
                      No users found. Add your first user using the button above.
                    </td>
                  </tr>
                ) : (
                  filteredUsers.map((user) => (
                  <tr key={user.id}>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{user.name}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{user.email}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500 capitalize">{user.role.replace("_", " ")}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => {
                          setSelectedUser(user)
                          setEditUserOpen(true)
                        }}
                      >
                        Edit
                      </Button>
                    </td>
                  </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>

      <AddUserDialog
        isOpen={isAddUserOpen}
        onClose={() => setAddUserOpen(false)}
        onAddUser={handleAddUser}
      />

      {selectedUser && (
        <EditUserDialog
          isOpen={isEditUserOpen}
          onClose={() => {
            setEditUserOpen(false)
            setSelectedUser(null)
          }}
          user={selectedUser}
          onUpdateUser={handleUpdateUser}
        />
      )}
    </div>
  )
}
