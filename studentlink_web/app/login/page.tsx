"use client"

import { useAuth } from "@/components/auth-provider"
import { LoginForm } from "@/components/login-form"
import { useRouter, useSearchParams } from "next/navigation"
import { useEffect } from "react"

export default function LoginPage() {
  const { user, loading } = useAuth()
  const router = useRouter()
  const searchParams = useSearchParams()

  useEffect(() => {
    // Clean URL parameters that might cause issues from copied links
    if (searchParams.toString() && typeof window !== 'undefined') {
      const cleanUrl = window.location.origin + '/login'
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
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-[#1E2A78] to-[#2480EA]">
        <div className="text-center text-white">
          <div className="mx-auto w-16 h-16 bg-white rounded-full flex items-center justify-center mb-4">
            <span className="text-[#1E2A78] font-bold text-xl">SL</span>
          </div>
          <h2 className="text-2xl font-bold mb-2">StudentLink Portal</h2>
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-white mx-auto"></div>
        </div>
      </div>
    )
  }

  if (!user) {
    return <LoginForm />
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-[#1E2A78] to-[#2480EA]">
      <div className="text-center text-white">
        <div className="mx-auto w-16 h-16 bg-white rounded-full flex items-center justify-center mb-4">
          <span className="text-[#1E2A78] font-bold text-xl">SL</span>
        </div>
        <h2 className="text-2xl font-bold mb-2">StudentLink Portal</h2>
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-white mx-auto"></div>
      </div>
    </div>
  )
}
