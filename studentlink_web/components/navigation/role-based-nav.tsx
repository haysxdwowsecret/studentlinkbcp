"use client"

import { useAuth } from "@/components/auth-provider"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import {
  Users,
  MessageSquare,
  Bell,
  BarChart3,
  Shield,
  Database,
  Bot,
  LogOut,
  User,
  BookOpen,
  Calendar,
  TrendingUp,
  AlertTriangle,
} from "lucide-react"
import Link from "next/link"
import Image from "next/image"

export function RoleBasedNav() {
  const { user, logout } = useAuth()

  if (!user) return null

  const getNavItems = () => {
    switch (user.role) {
      case "admin":
        return [
          { href: "/admin", icon: BarChart3, label: "Dashboard", badge: null },
          { href: "/admin/users", icon: Users, label: "User Management", badge: null },
          { href: "/admin/all-concerns", icon: MessageSquare, label: "All Concerns", badge: null },
          { href: "/admin/announcements", icon: Bell, label: "Announcements", badge: null },
          { href: "/admin/chatbot", icon: Bot, label: "AI Chatbot", badge: null },
          { href: "/admin/settings", icon: Database, label: "System Settings", badge: null },
          { href: "/admin/reports", icon: BarChart3, label: "Reports", badge: null },
          { href: "/admin/emergency", icon: AlertTriangle, label: "Emergency Help", badge: null },
        ]

      case "department_head":
        return [
          { href: "/department-head", icon: BarChart3, label: "Dashboard", badge: null },
          { href: "/department-head/concerns", icon: MessageSquare, label: "Department Concerns", badge: null },
          { href: "/department-head/staff", icon: Users, label: "Manage Staff", badge: null },
          { href: "/department-head/reports", icon: TrendingUp, label: "Department Reports", badge: null },
          { href: "/department-head/announcements", icon: Bell, label: "Announcements", badge: null },
          { href: "/department-head/priority", icon: AlertTriangle, label: "Priority Items", badge: null },
        ]

      case "staff":
        return [
          { href: "/staff", icon: BarChart3, label: "Dashboard", badge: null },
          { href: "/staff/concerns", icon: MessageSquare, label: "My Concerns", badge: null },
          { href: "/staff/announcements", icon: Bell, label: "Announcements", badge: null },
          { href: "/staff/emergency", icon: AlertTriangle, label: "Emergency Help", badge: null },
        ]

      case "faculty":
        return [
          { href: "/faculty", icon: BarChart3, label: "Dashboard", badge: null },
          { href: "/faculty/concerns", icon: MessageSquare, label: "Student Concerns", badge: null },
          { href: "/faculty/students", icon: Users, label: "My Students", badge: null },
          { href: "/faculty/courses", icon: BookOpen, label: "Courses", badge: null },
          { href: "/faculty/announcements", icon: Bell, label: "Announcements", badge: null },
          { href: "/faculty/office-hours", icon: Calendar, label: "Office Hours", badge: null },
        ]

      default:
        return []
    }
  }

  const navItems = getNavItems()

  return (
    <nav className="w-64 bg-white border-r border-gray-200 h-screen flex flex-col">
      {/* Header */}
      <div className="p-6 border-b border-gray-200">
        <div className="flex items-center space-x-3">
          <div className="w-10 h-10 rounded-lg overflow-hidden flex items-center justify-center">
            <Image 
              src="/Picsart_25-09-06_16-04-40-076.jpg" 
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
        <Button variant="ghost" className="w-full justify-start hover:bg-red-50 hover:text-red-600" onClick={logout}>
          <LogOut className="mr-3 h-4 w-4" />
          Logout
        </Button>
      </div>
    </nav>
  )
}
