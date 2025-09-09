"use client"

import { useAuth } from "@/components/auth-provider"
import { LoginForm } from "@/components/login-form"
import { useRouter, useSearchParams } from "next/navigation"
import { useEffect } from "react"

export default function HomePage() {
  const { user, loading } = useAuth()
  const router = useRouter()
  const searchParams = useSearchParams()

  useEffect(() => {
    // Clean URL parameters that might cause issues from copied links
    if (searchParams.toString() && typeof window !== 'undefined') {
      const cleanUrl = window.location.origin
      if (window.location.href !== cleanUrl) {
        window.history.replaceState({}, '', cleanUrl)
      }
    }
  }, [searchParams])

  useEffect(() => {
    if (!loading && user) {
      // Redirect to role-specific dashboard
      switch (user.role) {
        case "admin":
          router.push("/admin")
          break
        case "department_head":
          router.push("/department-head")
          break
        case "staff":
          router.push("/staff")
          break
        case "faculty":
          router.push("/faculty")
          break
        default:
          router.push("/login")
      }
    }
  }, [user, loading, router])

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-[#1E2A78]"></div>
      </div>
    )
  }

  if (!user) {
    return <LoginForm />
  }

  return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-[#1E2A78]"></div>
    </div>
  )
}
