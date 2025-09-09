"use client"

import { useAuth } from "@/components/auth-provider"
import { LoginForm } from "@/components/login-form"
import { LoadingScreen } from "@/components/loading-screen"
import { useRouter } from "next/navigation"
import { useEffect } from "react"

export default function LoginPage() {
  const { user, loading } = useAuth()
  const router = useRouter()

  useEffect(() => {
    if (!loading && user) {
      // Redirect to role-specific dashboard
      switch (user.role) {
        case "admin":
          router.replace("/admin")
          break
        case "department_head":
          router.replace("/department-head")
          break
        case "staff":
          router.replace("/staff")
          break
        case "faculty":
          router.replace("/faculty")
          break
        default:
          router.replace("/login")
      }
    }
  }, [user, loading, router])

  if (loading) {
    return <LoadingScreen />
  }

  if (!user) {
    return <LoginForm />
  }

  return <LoadingScreen />
}
