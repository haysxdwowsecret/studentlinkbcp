"use client"

import { useAuth } from "@/components/auth-provider"
import { LoginForm } from "@/components/login-form"
import { useRouter } from "next/navigation"
import { useEffect } from "react"

export default function LoginPage() {
  const { user, loading } = useAuth()
  const router = useRouter()

  useEffect(() => {
    if (user) {
      // Simple redirect based on role
      const roleRoutes = {
        admin: "/admin",
        department_head: "/department-head",
        staff: "/staff", 
        faculty: "/faculty"
      }
      
      const route = roleRoutes[user.role as keyof typeof roleRoutes] || "/login"
      router.replace(route)
    }
  }, [user, router])

  // Show login form if not authenticated
  if (!user) {
    return <LoginForm />
  }

  // Show nothing while redirecting
  return null
}