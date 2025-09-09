import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  const { pathname, searchParams } = request.nextUrl
  
  // Handle /login route - redirect to main page
  if (pathname === '/login') {
    const cleanUrl = new URL('/', request.url)
    return NextResponse.redirect(cleanUrl)
  }
  
  // Handle root path with query parameters - clean them
  if (pathname === '/' && searchParams.toString()) {
    const cleanUrl = new URL('/', request.url)
    return NextResponse.redirect(cleanUrl)
  }
  
  // Handle any other problematic paths
  if (pathname.includes('login') && pathname !== '/login') {
    const cleanUrl = new URL('/', request.url)
    return NextResponse.redirect(cleanUrl)
  }
  
  return NextResponse.next()
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - api (API routes)
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     */
    '/((?!api|_next/static|_next/image|favicon.ico).*)',
  ],
}
