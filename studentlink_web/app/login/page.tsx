'use client'

import { useEffect } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'

export default function LoginPage() {
  const router = useRouter()
  const searchParams = useSearchParams()

  useEffect(() => {
    // Handle all possible URL variations and redirects
    const currentUrl = window.location.href
    const currentPath = window.location.pathname
    
    // If we're on /login, redirect to main page
    if (currentPath === '/login') {
      // Clear any query parameters that might cause issues
      const cleanUrl = window.location.origin
      window.location.replace(cleanUrl)
      return
    }
    
    // If we're on root but with query parameters, clean them
    if (currentPath === '/' && searchParams.toString()) {
      const cleanUrl = window.location.origin
      window.location.replace(cleanUrl)
      return
    }
    
    // Default redirect to main page
    router.replace('/')
  }, [router, searchParams])

  return (
    <div style={{ 
      display: 'flex', 
      justifyContent: 'center', 
      alignItems: 'center', 
      height: '100vh',
      backgroundColor: '#1e2a78',
      color: 'white',
      fontFamily: 'Arial, sans-serif'
    }}>
      <div style={{ textAlign: 'center' }}>
        <div style={{
          width: '60px',
          height: '60px',
          backgroundColor: 'white',
          borderRadius: '50%',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          margin: '0 auto 20px',
          color: '#1e2a78',
          fontSize: '24px',
          fontWeight: 'bold'
        }}>
          SL
        </div>
        <h2>StudentLink Portal</h2>
        <p>Redirecting to login...</p>
        <div style={{ marginTop: '20px', fontSize: '14px', opacity: 0.8 }}>
          <p>If this page doesn't redirect automatically,</p>
          <p>please go to: <strong>bcpstudentlink.online</strong></p>
        </div>
      </div>
    </div>
  )
}
