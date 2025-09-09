"use client"

import { createContext, useContext, useState, useEffect, type ReactNode } from "react"
import { apiClient, User } from "../lib/api-client"

interface AuthContextType {
  user: User | null
  loading: boolean
  login: (email: string, password: string) => Promise<void>
  logout: () => void
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

// All authentication now handled by backend API

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Simple auth check without localStorage caching
    const checkAuth = async () => {
      try {
        const currentUser = await apiClient.getCurrentUser()
        setUser(currentUser)
      } catch (error) {
        console.log("No valid session found:", error)
        setUser(null)
      } finally {
        setLoading(false)
      }
    }

    checkAuth()
  }, [])

  const login = async (email: string, password: string) => {
    try {
      // Authenticate with backend API
      const response = await apiClient.login(email, password)
      setUser(response.user)
      localStorage.setItem("studentlink_user", JSON.stringify(response.user))
      return
    } catch (error) {
      console.error("Authentication failed:", error)
      throw new Error("Invalid credentials. Please check your email and password.")
    }
  }

  const logout = async () => {
    try {
      // Try to logout from backend
      await apiClient.logout()
    } catch (error) {
      console.log("Backend logout failed:", error)
    } finally {
      // Always clear local state
      setUser(null)
      localStorage.removeItem("studentlink_user")
    }
  }

  return (
    <AuthContext.Provider value={{ user, loading, login, logout }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider")
  }
  return context
}