"use client"

import { useAuth } from "@/components/auth-provider"
import { LoginForm } from "@/components/login-form"
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
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-[#1E2A78] to-[#2480EA]">
        <div className="text-center text-white">
          <div className="mx-auto w-16 h-16 bg-white rounded-full flex items-center justify-center mb-4">
            <span className="text-[#1E2A78] font-bold text-xl">SL</span>
          </div>
          <h2 className="text-2xl font-bold mb-2">StudentLink Portal</h2>
          <p>Loading...</p>
        </div>
      </div>
    )
  }

  if (!user) {
    return <LoginForm />
  }

  return null
}
