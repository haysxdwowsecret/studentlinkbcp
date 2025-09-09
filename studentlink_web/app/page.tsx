"use client"

import { LoadingScreen } from "@/components/loading-screen"
import { useEffect } from "react"
import { useRouter } from "next/navigation"

export default function HomePage() {
  const router = useRouter()

  useEffect(() => {
    // Redirect root to /login
    router.replace("/login")
  }, [router])

  return <LoadingScreen />
}
