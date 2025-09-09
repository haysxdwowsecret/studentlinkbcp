import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  // No redirects - let the app handle routing naturally
  return NextResponse.next()
}

export const config = {
  matcher: [
    // No matchers - disable middleware completely
  ],
}
