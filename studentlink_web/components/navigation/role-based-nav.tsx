"use client"

import { useState } from "react"
import { useAuth } from "@/components/auth-provider"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog"
import {
  Users,
  MessageSquare,
  Bell,
  BarChart3,
  Database,
  Bot,
  LogOut,
  User,
  TrendingUp,
  AlertTriangle,
  FileText,
  Building,
} from "lucide-react"
import Link from "next/link"
import Image from "next/image"
import { generateDepartmentSlug } from "@/lib/utils/department-utils"

export function RoleBasedNav() {
  const { user, logout } = useAuth()
  const [isLoggingOut, setIsLoggingOut] = useState(false)

  if (!user) return null

  const getNavItems = () => {
    switch (user.role) {
      case "admin":
        return [
          { href: "/admin", icon: BarChart3, label: "Dashboard", badge: null },
          { href: "/admin/users", icon: Users, label: "User Management", badge: null },
          { href: "/admin/departments", icon: Building, label: "Departments", badge: null },
          { href: "/admin/all-concerns", icon: MessageSquare, label: "All Concerns", badge: null },
          { href: "/department/chat", icon: MessageSquare, label: "Real-time Chat", badge: null },
          { href: "/admin/announcements", icon: Bell, label: "Announcements", badge: null },
          { href: "/admin/notifications", icon: Bell, label: "Push Notifications", badge: null },
          { href: "/admin/chatbot", icon: Bot, label: "AI Chatbot", badge: null },
          { href: "/admin/settings", icon: Database, label: "System Settings", badge: null },
          { href: "/admin/reports", icon: BarChart3, label: "Reports", badge: null },
          { href: "/admin/emergency", icon: AlertTriangle, label: "Emergency Help", badge: null },
          { href: "/admin/audit-logs", icon: FileText, label: "Audit Logs", badge: null },
        ]

      case "department_head":
        const departmentSlug = generateDepartmentSlug(user.department || '')
        return [
          { href: `/department/${departmentSlug}`, icon: BarChart3, label: "Dashboard", badge: null },
          { href: `/department/${departmentSlug}?tab=concerns`, icon: MessageSquare, label: "Department Concerns", badge: null },
          { href: `/department/chat`, icon: MessageSquare, label: "Real-time Chat", badge: null },
          { href: `/department/${departmentSlug}?tab=announcements`, icon: Bell, label: "Announcements", badge: null },
          { href: `/department/${departmentSlug}?tab=analytics`, icon: TrendingUp, label: "Analytics", badge: null },
          { href: `/department/${departmentSlug}?tab=settings`, icon: Database, label: "Settings", badge: null },
        ]


      default:
        return []
    }
  }

  const navItems = getNavItems()

  const handleLogout = async () => {
    setIsLoggingOut(true)
    try {
      await logout()
    } catch (error) {
      console.error('Logout error:', error)
    } finally {
      setIsLoggingOut(false)
    }
  }

  return (
    <nav className="w-64 bg-white border-r border-gray-200 h-screen flex flex-col">
      {/* Header */}
      <div className="p-6 border-b border-gray-200">
        <div className="flex items-center space-x-3">
          <div className="w-10 h-10 rounded-lg overflow-hidden flex items-center justify-center">
            <Image 
              src="/studentlinklogo.png" 
              alt="StudentLink Logo" 
              width={40} 
              height={40}
              className="object-contain"
            />
          </div>
          <div>
            <h1 className="text-lg font-bold text-[#1E2A78]">StudentLink</h1>
            <p className="text-sm text-gray-600">Bestlink College</p>
          </div>
        </div>
      </div>

      {/* User Info */}
      <div className="p-4 border-b border-gray-200">
        <div className="flex items-center space-x-3">
          <div className="w-8 h-8 bg-[#2480EA] rounded-full flex items-center justify-center">
            <User className="h-4 w-4 text-white" />
          </div>
          <div>
            <p className="font-medium text-[#1E2A78]">{user.name}</p>
            <p className="text-sm text-gray-600 capitalize">{user.role.replace("_", " ")}</p>
          </div>
        </div>
      </div>

      {/* Navigation Items */}
      <div className="flex-1 p-4 space-y-2">
        {navItems.map((item) => (
          <Link key={item.href} href={item.href}>
            <Button variant="ghost" className="w-full justify-start hover:bg-[#1E2A78] hover:text-white group">
              <item.icon className="mr-3 h-4 w-4" />
              <span className="flex-1 text-left">{item.label}</span>
              {item.badge && (
                <Badge variant="destructive" className="ml-2">
                  {item.badge}
                </Badge>
              )}
            </Button>
          </Link>
        ))}
      </div>

      {/* Footer Actions */}
      <div className="p-4 border-t border-gray-200 space-y-2">
        <Link href={`/${user.role}/profile`}>
          <Button variant="ghost" className="w-full justify-start hover:bg-gray-100">
            <User className="mr-3 h-4 w-4" />
            Profile & Settings
          </Button>
        </Link>
        <AlertDialog>
          <AlertDialogTrigger asChild>
            <Button 
              variant="ghost" 
              className="w-full justify-start hover:bg-red-50 hover:text-red-600"
              disabled={isLoggingOut}
            >
              <LogOut className="mr-3 h-4 w-4" />
              {isLoggingOut ? "Logging out..." : "Logout"}
            </Button>
          </AlertDialogTrigger>
          <AlertDialogContent>
            <AlertDialogHeader>
              <AlertDialogTitle>Confirm Logout</AlertDialogTitle>
              <AlertDialogDescription>
                Are you sure you want to logout? You will need to sign in again to access your account.
              </AlertDialogDescription>
            </AlertDialogHeader>
            <AlertDialogFooter>
              <AlertDialogCancel>Cancel</AlertDialogCancel>
              <AlertDialogAction 
                onClick={handleLogout}
                className="bg-red-600 hover:bg-red-700"
              >
                Logout
              </AlertDialogAction>
            </AlertDialogFooter>
          </AlertDialogContent>
        </AlertDialog>
      </div>
    </nav>
  )
}
