import { ErrorHandler, ErrorType, type AppError } from './utils/error-handler'

const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL || "http://127.0.0.1:8000/api"

// Debug: Log the API base URL being used
console.log('🔗 API_BASE_URL:', API_BASE_URL)
console.log('🔗 NEXT_PUBLIC_API_BASE_URL env var:', process.env.NEXT_PUBLIC_API_BASE_URL)

interface ApiResponse<T> {
  success: boolean
  data: T
  message?: string
  pagination?: {
    current_page: number
    last_page: number
    per_page: number
    total: number
  }
}

interface ApiError {
  success: false
  message: string
  error?: string
  errors?: Record<string, string[]>
}

export interface User {
  id: number
  name: string
  email: string
  role: "admin" | "department_head" | "student"
  department: string
  department_id: number
  student_id?: string
  display_id?: string
  avatar?: string
  preferences?: Record<string, any>
  last_login_at?: string
  unread_notifications_count?: number
}

export interface Concern {
  id: number
  reference_number: string
  subject: string
  description: string
  type: "academic" | "administrative" | "technical" | "health" | "safety" | "other"
  priority: "low" | "medium" | "high" | "urgent"
  status: "pending" | "approved" | "rejected" | "in_progress" | "resolved" | "closed" | "cancelled"
  is_anonymous: boolean
  rejection_reason?: string
  approved_at?: string
  rejected_at?: string
  approved_by?: {
    id: number
    name: string
    role: string
  }
  rejected_by?: {
    id: number
    name: string
    role: string
  }
  student: {
    id: number
    name: string
    display_id: string
  }
  department: {
    id: number
    name: string
    code: string
  }
  facility?: {
    id: number
    name: string
  }
  assigned_to?: {
    id: number
    name: string
    role: string
  }
  attachments: string[]
  due_date?: string
  resolved_at?: string
  closed_at?: string
  created_at: string
  updated_at: string
  messages?: ConcernMessage[]
}

export interface ConcernMessage {
  id: number
  message: string
  type: "message" | "status_change" | "assignment" | "system"
  author: {
    id: number
    name: string
    role: string
  }
  attachments: string[]
  is_internal: boolean
  is_ai_generated: boolean
  read_at?: string
  created_at: string
}

export interface ChatRoom {
  id: number
  concern_id: number
  room_name: string
  status: "active" | "closed" | "archived"
  last_activity_at?: string
  participants?: Record<string, any>
  settings?: Record<string, any>
  created_at: string
  updated_at: string
  concern?: Concern
  latest_message?: ChatMessage
  unread_count?: number
}

export interface ChatMessage {
  id: number
  concern_id: number
  chat_room_id?: number
  author_id: number
  message: string
  message_type: "text" | "image" | "file" | "system" | "status_change"
  is_internal: boolean
  is_typing: boolean
  attachments?: string[]
  metadata?: Record<string, any>
  delivered_at?: string
  read_at?: string
  reactions?: Record<string, any>
  reply_to_id?: number
  created_at: string
  updated_at: string
  author?: User
  reply_to?: ChatMessage
}

export interface Announcement {
  id: number
  status: "draft" | "published" | "archived"
  author: {
    id: number
    name: string
    role: string
  }
  internal_title?: string
  category: string
  title: string
  description?: string
  action_button_text?: string
  action_button_url?: string
  announcement_timestamp?: string
  target_departments?: number[]
  published_at?: string
  expires_at?: string
  scheduled_at?: string
  view_count: number
  download_count: number
  share_count: number
  bookmark_count: number
  is_bookmarked: boolean
  created_at: string
  // Image fields (required for all announcements)
  image_path: string
  image_filename: string
  image_mime_type: string
  image_size: number
  image_width: number
  image_height: number
  image_url: string
  image_download_url: string
  thumbnail_url?: string
  compressed_image_url?: string
  // Moderation fields
  moderation_status?: string
  moderated_by?: number
  moderation_notes?: string
}

export interface Department {
  id: number
  name: string
  code: string
  description?: string
  type: "academic" | "administrative"
  is_active: boolean
  contact_info?: Record<string, any>
}

export interface DashboardStats {
  totalUsers: number
  activeConcerns: number
  resolvedConcerns: number
  pendingConcerns: number
  systemHealth: number
  aiInteractions: number
  departmentStats: Array<{
    department: string
    concernCount: number
    resolvedCount: number
  }>
}

class ApiClient {
  private baseURL: string
  private token: string | null = null

  constructor(baseURL: string) {
    this.baseURL = baseURL
    this.loadTokenFromStorage()
  }

  private loadTokenFromStorage() {
    if (typeof window !== 'undefined') {
      this.token = localStorage.getItem('auth_token')
    }
  }

  private saveTokenToStorage(token: string) {
    if (typeof window !== 'undefined') {
      localStorage.setItem('auth_token', token)
    }
    this.token = token
  }

  private removeTokenFromStorage() {
    if (typeof window !== 'undefined') {
      localStorage.removeItem('auth_token')
    }
    this.token = null
  }

  setAuthToken(token: string) {
    this.saveTokenToStorage(token)
  }

  getToken(): string | null {
    return this.token
  }

  private async request<T>(endpoint: string, options: RequestInit = {}): Promise<ApiResponse<T>> {
    const url = `${this.baseURL}${endpoint}`
    const headers: HeadersInit = {
      ...options.headers,
    }

    // Only set Content-Type for JSON requests (not FormData)
    if (!(options.body instanceof FormData)) {
      (headers as Record<string, string>)["Content-Type"] = "application/json"
    }

    if (this.token) {
      (headers as any).Authorization = `Bearer ${this.token}`
      console.log('🔐 Using auth token:', this.token.substring(0, 20) + '...')
    } else {
      console.log('⚠️ No auth token found!')
    }

    try {
      console.log('🌐 Making API request to:', url)
      console.log('🌐 Request options:', { method: options.method || 'GET', headers })
      
      const response = await fetch(url, {
        ...options,
        headers,
      })
      
      console.log('🌐 Response status:', response.status)
      console.log('🌐 Response headers:', Object.fromEntries(response.headers.entries()))

      // Handle different response types
      let data: any = null
      const contentType = response.headers.get('content-type')
      
      if (contentType && contentType.includes('application/json')) {
        data = await response.json()
      } else if (response.status === 204) {
        // No Content - successful deletion
        data = { success: true }
      } else {
        // Try to parse as JSON, but don't fail if it's not
        try {
          data = await response.json()
        } catch {
          data = { message: `HTTP ${response.status}` }
        }
      }

      if (!response.ok) {
        // Handle 401 unauthorized - token expired
        if (response.status === 401) {
          this.removeTokenFromStorage()
          // Redirect to login page or refresh token
          if (typeof window !== 'undefined') {
            window.location.href = '/login'
          }
        }
        
        const appError: AppError = {
          message: data?.message || `HTTP error! status: ${response.status}`,
          type: response.status === 401 ? ErrorType.AUTHENTICATION : 
                response.status === 422 ? ErrorType.VALIDATION :
                response.status >= 500 ? ErrorType.SERVER : ErrorType.UNKNOWN,
          statusCode: response.status,
        }
        
        throw appError
      }

      return data as ApiResponse<T>
    } catch (error) {
      console.error(`API request failed for ${endpoint}:`, error)
      
      if (error instanceof Error && 'type' in error) {
        throw error // Already an AppError
      }
      
      throw ErrorHandler.parseError(error)
    }
  }

  // Authentication endpoints
  async login(email: string, password: string): Promise<{ token: string; user: User }> {
    const response = await this.request<{ token: string; user: User }>("/auth/login", {
      method: "POST",
      body: JSON.stringify({ email, password }),
    })

    if (response.success && response.data.token) {
      this.saveTokenToStorage(response.data.token)
    }

    return response.data
  }

  async logout(): Promise<void> {
    try {
      await this.request("/auth/logout", {
        method: "POST",
      })
    } finally {
      this.removeTokenFromStorage()
    }
  }

  async getCurrentUser(): Promise<User> {
    const response = await this.request<User>("/auth/me")
    return response.data
  }

  async refreshToken(): Promise<{ token: string }> {
    const response = await this.request<{ token: string }>("/auth/refresh", {
      method: "POST",
    })

    if (response.success && response.data.token) {
      this.saveTokenToStorage(response.data.token)
    }

    return response.data
  }

  // Concerns endpoints
  async getConcerns(filters?: {
    status?: string
    department_id?: number
    priority?: string
    assigned_to?: number
    type?: string
    page?: number
    per_page?: number
  }): Promise<{ data: Concern[]; pagination: any }> {
    const queryParams = filters ? `?${new URLSearchParams(
      Object.entries(filters).reduce((acc, [key, value]) => {
        if (value !== undefined && value !== null) {
          acc[key] = String(value)
        }
        return acc
      }, {} as Record<string, string>)
    )}` : ""
    
    const response = await this.request<Concern[]>(`/concerns${queryParams}`)
    return {
      data: response.data,
      pagination: response.pagination || {}
    }
  }

  async getConcern(id: number): Promise<Concern> {
    const response = await this.request<Concern>(`/concerns/${id}`)
    return response.data
  }

  async createConcern(concern: {
    subject: string
    description: string
    department_id: number
    facility_id?: number
    type: string
    priority: string
    is_anonymous?: boolean
    attachments?: string[]
  }): Promise<Concern> {
    const response = await this.request<Concern>("/concerns", {
      method: "POST",
      body: JSON.stringify(concern),
    })
    return response.data
  }

  async updateConcern(id: number, updates: {
    subject?: string
    description?: string
    priority?: string
    due_date?: string
  }): Promise<Concern> {
    const response = await this.request<Concern>(`/concerns/${id}`, {
      method: "PUT",
      body: JSON.stringify(updates),
    })
    return response.data
  }

  async updateConcernStatus(id: number, status: string, note?: string): Promise<void> {
    await this.request(`/concerns/${id}/status`, {
      method: "PATCH",
      body: JSON.stringify({ status, note }),
    })
  }

  async assignConcern(id: number, assigneeId: number): Promise<void> {
    await this.request(`/concerns/${id}/assign`, {
      method: "POST",
      body: JSON.stringify({ assigned_to: assigneeId }),
    })
  }

  async addConcernMessage(id: number, message: string, attachments?: string[]): Promise<ConcernMessage> {
    const response = await this.request<ConcernMessage>(`/concerns/${id}/messages`, {
      method: "POST",
      body: JSON.stringify({ message, attachments }),
    })
    return response.data
  }

  async approveConcern(id: number): Promise<void> {
    await this.request(`/concerns/${id}/approve`, {
      method: "POST",
    })
  }

  async rejectConcern(id: number, rejectionReason: string): Promise<void> {
    await this.request(`/concerns/${id}/reject`, {
      method: "POST",
      body: JSON.stringify({ rejection_reason: rejectionReason }),
    })
  }

  async getConcernHistory(id: number): Promise<any[]> {
    const response = await this.request<any[]>(`/concerns/${id}/history`)
    return response.data
  }

  // Announcements endpoints
  async getAnnouncements(filters?: {
    type?: string
    priority?: string
    status?: string
    page?: number
    per_page?: number
  }): Promise<{ data: Announcement[]; pagination: any }> {
    const queryParams = filters ? `?${new URLSearchParams(
      Object.entries(filters).reduce((acc, [key, value]) => {
        if (value !== undefined && value !== null) {
          acc[key] = String(value)
        }
        return acc
      }, {} as Record<string, string>)
    )}` : ""

    const response = await this.request<Announcement[]>(`/announcements${queryParams}`)
    return {
      data: response.data,
      pagination: response.pagination || {}
    }
  }

  async getAnnouncement(id: number): Promise<Announcement> {
    const response = await this.request<Announcement>(`/announcements/${id}`)
    return response.data
  }

  async getAnnouncementCategories(): Promise<string[]> {
    const response = await this.request<string[]>(`/announcements/categories`)
    return response.data
  }

  async createAnnouncement(announcement: {
    internal_title?: string
    category: string
    title: string
    description?: string
    action_button_text?: string
    action_button_url?: string
    announcement_timestamp?: string
    status?: string
    target_departments?: number[]
    published_at?: string
    expires_at?: string
    scheduled_at?: string
    image?: File
  }): Promise<Announcement> {
    const formData = new FormData()
    
    // Add required fields first
    formData.append('category', announcement.category)
    formData.append('title', announcement.title)
    
    // Add optional fields
    Object.entries(announcement).forEach(([key, value]) => {
      if (key !== 'image' && key !== 'category' && key !== 'title' && value !== undefined && value !== null && value !== '') {
        if (Array.isArray(value)) {
          formData.append(key, JSON.stringify(value))
        } else {
          formData.append(key, String(value))
        }
      }
    })
    
    // Add image file (required)
    if (announcement.image) {
      formData.append('image', announcement.image)
    }
    
    console.log('📤 API Client: Sending announcement data to backend')
    console.log('📤 Original announcement object:', {
      ...announcement,
      image: announcement.image ? `File(${announcement.image.name}, ${announcement.image.size} bytes)` : null
    })
    console.log('📤 FormData contents:')
    for (let [key, value] of formData.entries()) {
      if (value instanceof File) {
        console.log(`  ${key}: File(${value.name}, ${value.size} bytes, ${value.type})`)
      } else {
        console.log(`  ${key}: "${value}"`)
      }
    }
    
    try {
      const response = await this.request<Announcement>("/announcements", {
        method: "POST",
        body: formData,
      })
      
      console.log('✅ API Client: Announcement created successfully:', response.data)
      return response.data
    } catch (error) {
      console.error('❌ API Client: Failed to create announcement:', error)
      
      // Enhanced error handling
      if (error?.statusCode === 422) {
        console.error('❌ Validation errors:', error)
        throw new Error(`Validation failed: ${error.message}`)
      } else if (error?.statusCode === 401) {
        console.error('❌ Authentication error:', error)
        throw new Error('Authentication failed. Please login again.')
      } else if (error?.statusCode === 500) {
        console.error('❌ Server error:', error)
        throw new Error('Server error occurred. Please try again later.')
      }
      
      throw error
    }
  }

  // Image-only announcement creation
  async createImageAnnouncement(announcement: {
    title: string
    type: string
    priority: string
    status?: string
    target_departments?: number[]
    published_at?: string
    expires_at?: string
    image: File
    remove_image?: boolean
  }): Promise<Announcement> {
    const formData = new FormData()
    
    // Add all text fields
    Object.entries(announcement).forEach(([key, value]) => {
      if (key !== 'image' && value !== undefined && value !== null) {
        if (Array.isArray(value)) {
          formData.append(key, JSON.stringify(value))
        } else {
          formData.append(key, String(value))
        }
      }
    })
    
    // Add image file
    if (announcement.image) {
      formData.append('image', announcement.image)
    }
    
    const response = await this.request<Announcement>("/announcements/image-only", {
      method: "POST",
      body: formData,
    })
    return response.data
  }

  // Bulk upload for image announcements
  async bulkUploadImageAnnouncements(announcements: Array<{
    title: string
    type: string
    priority: string
    target_departments?: number[]
    scheduled_at?: string
    image: File
  }>): Promise<{ data: Announcement[]; message: string }> {
    const formData = new FormData()
    formData.append('announcements', JSON.stringify(announcements.map(a => ({
      title: a.title,
      type: a.type,
      priority: a.priority,
      target_departments: a.target_departments,
      scheduled_at: a.scheduled_at
    }))))
    
    // Add all images
    announcements.forEach((ann, index) => {
      formData.append(`images[${index}]`, ann.image)
    })
    
    const response = await this.request<{ data: Announcement[]; message: string }>("/announcements/bulk-upload", {
      method: "POST",
      body: formData,
    })
    return response.data
  }

  // Analytics tracking
  async trackAnnouncementView(id: number): Promise<void> {
    await this.request(`/announcements/${id}/track/view`, {
      method: "POST",
    })
  }

  async trackAnnouncementShare(id: number): Promise<void> {
    await this.request(`/announcements/${id}/track/share`, {
      method: "POST",
    })
  }

  async getAnnouncementAnalytics(id: number): Promise<any> {
    const response = await this.request<any>(`/announcements/${id}/analytics`)
    return response.data
  }

  // Moderation
  async moderateAnnouncement(id: number, action: 'approve' | 'reject', notes?: string): Promise<void> {
    await this.request(`/announcements/${id}/moderate`, {
      method: "POST",
      body: JSON.stringify({ action, notes }),
    })
  }

  async updateAnnouncement(id: number, announcement: Partial<Announcement> & { image?: File; remove_image?: boolean }): Promise<Announcement> {
    const formData = new FormData()
    
    console.log('🔄 API Client: updateAnnouncement called with:', {
      id,
      announcement,
      hasImage: !!announcement.image,
      imageName: announcement.image?.name
    })
    
    // Add all text fields
    Object.entries(announcement).forEach(([key, value]) => {
      if (key !== 'image' && value !== undefined && value !== null) {
        if (Array.isArray(value)) {
          formData.append(key, JSON.stringify(value))
        } else {
          formData.append(key, String(value))
        }
      }
    })
    
    // Add image file if present
    if (announcement.image) {
      console.log('📎 API Client: Adding image to FormData:', announcement.image.name)
      formData.append('image', announcement.image)
    } else {
      console.log('📎 API Client: No image provided for update')
    }
    
    const response = await this.request<Announcement>(`/announcements/${id}`, {
      method: "PUT",
      body: formData,
    })
    return response.data
  }

  async deleteAnnouncement(id: number): Promise<void> {
    await this.request(`/announcements/${id}`, {
      method: "DELETE",
    })
  }

  async downloadAnnouncementImage(id: number): Promise<Blob> {
    const response = await fetch(`${this.baseURL}/announcements/${id}/image/download`, {
      headers: {
        'Authorization': `Bearer ${this.getToken()}`,
      },
    })
    
    if (!response.ok) {
      throw new Error('Failed to download image')
    }
    
    return response.blob()
  }

  async bookmarkAnnouncement(id: number): Promise<void> {
    await this.request(`/announcements/${id}/bookmark`, {
      method: "POST",
    })
  }

  async removeAnnouncementBookmark(id: number): Promise<void> {
    await this.request(`/announcements/${id}/bookmark`, {
      method: "DELETE",
    })
  }

  // Users endpoints
  async getUsers(filters?: {
    role?: string
    department_id?: number
    is_active?: boolean
    page?: number
    per_page?: number
  }): Promise<{ data: User[]; pagination: any }> {
    const queryParams = filters ? `?${new URLSearchParams(
      Object.entries(filters).reduce((acc, [key, value]) => {
        if (value !== undefined && value !== null) {
          acc[key] = String(value)
        }
        return acc
      }, {} as Record<string, string>)
    )}` : ""

    const response = await this.request<User[]>(`/users${queryParams}`)
    return {
      data: response.data,
      pagination: response.pagination || {}
    }
  }

  async getUser(id: number): Promise<User> {
    const response = await this.request<User>(`/users/${id}`)
    return response.data
  }

  async createUser(user: {
    name: string
    email: string
    password: string
    role: string
    department_id: number
    phone?: string
  }): Promise<User> {
    const response = await this.request<User>("/users", {
      method: "POST",
      body: JSON.stringify(user),
    })
    return response.data
  }

  async updateUser(id: number, updates: Partial<User>): Promise<User> {
    const response = await this.request<User>(`/users/${id}`, {
      method: "PUT",
      body: JSON.stringify(updates),
    })
    return response.data
  }

  async deleteUser(id: number): Promise<void> {
    await this.request(`/users/${id}`, {
      method: "DELETE",
    })
  }

  // Concern Feedback endpoints
  async submitConcernFeedback(concernId: number, feedback: {
    rating: number
    response_time_rating?: number
    resolution_quality_rating?: number
    service_courtesy_rating?: number
    communication_rating?: number
    feedback_text?: string
    suggestions?: string
    would_recommend?: boolean
    is_anonymous?: boolean
  }): Promise<any> {
    const response = await this.request(`/concerns/${concernId}/feedback`, {
      method: "POST",
      body: JSON.stringify(feedback),
    })
    return response.data
  }

  async getConcernFeedback(concernId: number): Promise<any> {
    const response = await this.request(`/concerns/${concernId}/feedback`)
    return response.data
  }

  async updateConcernFeedback(concernId: number, feedbackId: number, updates: any): Promise<any> {
    const response = await this.request(`/concerns/${concernId}/feedback/${feedbackId}`, {
      method: "PUT",
      body: JSON.stringify(updates),
    })
    return response.data
  }

  async getFeedbackStats(filters?: {
    date_from?: string
    date_to?: string
  }): Promise<any> {
    const queryParams = filters ? `?${new URLSearchParams(
      Object.entries(filters).reduce((acc, [key, value]) => {
        if (value !== undefined && value !== null) {
          acc[key] = String(value)
        }
        return acc
      }, {} as Record<string, string>)
    )}` : ""
    
    const response = await this.request(`/analytics/feedback/stats${queryParams}`)
    return response.data
  }

  async getRecentFeedback(limit?: number): Promise<any[]> {
    const queryParams = limit ? `?limit=${limit}` : ""
    const response = await this.request(`/analytics/feedback/recent${queryParams}`)
    return response.data as any[]
  }

  // Departments endpoints
  async getDepartments(): Promise<Department[]> {
    const response = await this.request<Department[]>("/departments")
    return response.data
  }

  async getDepartment(id: number): Promise<Department> {
    const response = await this.request<Department>(`/departments/${id}`)
    return response.data
  }

  async createDepartment(department: Partial<Department>): Promise<Department> {
    const response = await this.request<Department>("/departments", {
      method: "POST",
      body: JSON.stringify(department),
    })
    return response.data
  }

  async updateDepartment(id: number, department: Partial<Department>): Promise<Department> {
    const response = await this.request<Department>(`/departments/${id}`, {
      method: "PUT",
      body: JSON.stringify(department),
    })
    return response.data
  }

  async deleteDepartment(id: number): Promise<void> {
    await this.request(`/departments/${id}`, {
      method: "DELETE",
    })
  }

  async getDepartmentStats(id: number): Promise<{
    total_concerns: number
    pending_concerns: number
    resolved_concerns: number
    total_users: number
  }> {
    const response = await this.request(`/departments/${id}/stats`)
    return response.data as {
      total_concerns: number
      pending_concerns: number
      resolved_concerns: number
      total_users: number
    }
  }

  async getDepartmentConcerns(id: number): Promise<any[]> {
    const response = await this.request(`/departments/${id}/concerns`)
    return response.data as any[]
  }

  async getDepartmentUsers(id: number): Promise<User[]> {
    const response = await this.request(`/departments/${id}/users`)
    return response.data as User[]
  }

  async getAllDepartmentStats(): Promise<any[]> {
    const response = await this.request<any[]>("/analytics/departments")
    return response.data
  }

  // Emergency Help endpoints
  async getEmergencyContacts(): Promise<any[]> {
    const response = await this.request<any[]>("/emergency/contacts")
    return response.data
  }

  async getEmergencyProtocols(): Promise<any[]> {
    const response = await this.request<any[]>("/emergency/protocols")
    return response.data
  }

  async updateEmergencyContact(id: number, contact: any): Promise<any> {
    const response = await this.request<any>(`/emergency/contacts/${id}`, {
      method: "PUT",
      body: JSON.stringify(contact),
    })
    return response.data
  }

  // AI Features endpoints
  async sendAiMessage(message: string, sessionId?: string, context?: string): Promise<{ message: string; session_id: string }> {
    const response = await this.request<{ message: string; session_id: string }>("/ai/chat", {
      method: "POST",
      body: JSON.stringify({
        message,
        session_id: sessionId,
        context: context || "general"
      }),
    })
    return response.data
  }

  async getAiSuggestions(context: string, type: string, existingText?: string): Promise<string[]> {
    const response = await this.request<{ suggestions: string[] }>("/ai/suggestions", {
      method: "POST",
      body: JSON.stringify({
        context,
        type,
        existing_text: existingText
      }),
    })
    return response.data.suggestions
  }

  // Notifications endpoints
  async getNotifications(params?: {
    unread_only?: boolean
    type?: string
    priority?: string
    page?: number
    per_page?: number
  }): Promise<{ data: any[]; pagination: any }> {
    const queryParams = params ? `?${new URLSearchParams(
      Object.entries(params).reduce((acc, [key, value]) => {
        if (value !== undefined && value !== null) {
          acc[key] = String(value)
        }
        return acc
      }, {} as Record<string, string>)
    )}` : ""

    const response = await this.request<any[]>(`/notifications${queryParams}`)
    return {
      data: response.data,
      pagination: response.pagination || {}
    }
  }

  async markNotificationsAsRead(notificationIds: number[]): Promise<void> {
    await this.request("/notifications/mark-read", {
      method: "POST",
      body: JSON.stringify({ notification_ids: notificationIds }),
    })
  }

  async markAllNotificationsAsRead(): Promise<void> {
    await this.request("/notifications/mark-all-read", {
      method: "POST",
    })
  }


  // Analytics endpoints
  async getDashboardStats(): Promise<DashboardStats> {
    const response = await this.request<DashboardStats>("/analytics/dashboard")
    return response.data as DashboardStats
  }

  async getConcernStats(filters?: any): Promise<any> {
    const queryParams = filters ? `?${new URLSearchParams(filters)}` : ""
    const response = await this.request<any>(`/analytics/concerns${queryParams}`)
    return response.data as any
  }


  async getUserStats(): Promise<any> {
    const response = await this.request<any>("/analytics/users")
    return response.data as any
  }

  async exportReport(format: string, type: string, filters?: any): Promise<Blob> {
    const params = new URLSearchParams({
      format,
      type,
      ...filters
    })
    
    const response = await fetch(`${this.baseURL}/analytics/reports/export?${params}`, {
      headers: {
        Authorization: `Bearer ${this.token}`,
      },
    })

    if (!response.ok) {
      throw new Error(`Export failed: ${response.statusText}`)
    }

    return response.blob()
  }


  // System endpoints
  async getSystemSettings(): Promise<any> {
    const response = await this.request<any>("/system/settings")
    return response.data
  }

  async updateSystemSettings(settings: any): Promise<any> {
    const response = await this.request<any>("/system/settings", {
      method: "PUT",
      body: JSON.stringify(settings),
    })
    return response.data
  }

  async getAuditLogs(params?: {
    user_id?: number
    action?: string
    model_type?: string
    page?: number
    per_page?: number
  }): Promise<{ data: any[]; pagination: any }> {
    const queryParams = params ? `?${new URLSearchParams(
      Object.entries(params).reduce((acc, [key, value]) => {
        if (value !== undefined && value !== null) {
          acc[key] = String(value)
        }
        return acc
      }, {} as Record<string, string>)
    )}` : ""

    const response = await this.request<any[]>(`/system/audit-logs${queryParams}`)
    return {
      data: response.data,
      pagination: response.pagination || {}
    }
  }

  // Health check
  async checkHealth(): Promise<{ status: string; timestamp: string }> {
    const response = await this.request<{ status: string; timestamp: string }>("/health")
    return response.data
  }

  // File upload helper
  async uploadFile(file: File, type: string): Promise<{ url: string }> {
    const formData = new FormData()
    formData.append('file', file)
    formData.append('type', type)

    const response = await fetch(`${this.baseURL}/upload`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${this.token}`,
      },
      body: formData,
    })

    const data = await response.json()

    if (!response.ok) {
      const appError: AppError = {
        message: data.message || 'Upload failed',
        type: response.status === 401 ? ErrorType.AUTHENTICATION : 
              response.status === 422 ? ErrorType.VALIDATION :
              response.status >= 500 ? ErrorType.SERVER : ErrorType.UNKNOWN,
        statusCode: response.status,
      }
      throw appError
    }

    return data.data
  }

  // Concern attachment upload
  async uploadConcernAttachment(concernId: number, file: File, description?: string): Promise<any> {
    const formData = new FormData()
    formData.append('file', file)
    if (description) {
      formData.append('description', description)
    }

    const response = await fetch(`${this.baseURL}/concerns/${concernId}/attachments`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${this.token}`,
      },
      body: formData,
    })

    const data = await response.json()

    if (!response.ok) {
      const appError: AppError = {
        message: data.message || 'Attachment upload failed',
        type: response.status === 401 ? ErrorType.AUTHENTICATION : 
              response.status === 403 ? ErrorType.AUTHENTICATION :
              response.status === 422 ? ErrorType.VALIDATION :
              response.status >= 500 ? ErrorType.SERVER : ErrorType.UNKNOWN,
        statusCode: response.status,
      }
      throw appError
    }

    return data.data
  }

  // Delete concern attachment
  async deleteConcernAttachment(concernId: number, attachmentId: string): Promise<void> {
    const response = await this.request(`/concerns/${concernId}/attachments/${attachmentId}`, {
      method: 'DELETE',
    })

    if (!response.success) {
      throw new Error(response.message || 'Failed to delete attachment')
    }
  }

  // AI Chatbot Management endpoints
  async getChatbotSettings(): Promise<any> {
    const response = await this.request<any>("/ai/settings")
    return response.data
  }

  async updateChatbotSettings(settings: any): Promise<any> {
    const response = await this.request<any>("/ai/settings", {
      method: "PUT",
      body: JSON.stringify(settings),
    })
    return response.data
  }

  async trainChatbot(trainingData: string): Promise<void> {
    await this.request("/ai/train", {
      method: "POST",
      body: JSON.stringify({ training_data: trainingData }),
    })
  }

  async getChatbotAnalytics(): Promise<any> {
    const response = await this.request<any>("/ai/analytics")
    return response.data
  }

  async getChatbotConversations(): Promise<any[]> {
    const response = await this.request<any[]>("/ai/conversations")
    return response.data
  }

  // Emergency Management endpoints
  async getEmergencySettings(): Promise<any> {
    const response = await this.request<any>("/emergency/settings")
    return response.data
  }

  async updateEmergencySettings(settings: any): Promise<any> {
    const response = await this.request<any>("/emergency/settings", {
      method: "PUT",
      body: JSON.stringify(settings),
    })
    return response.data
  }

  async broadcastEmergencyAlert(message: string): Promise<void> {
    await this.request("/emergency/broadcast", {
      method: "POST",
      body: JSON.stringify({ message }),
    })
  }

  async getEmergencyStats(): Promise<any> {
    const response = await this.request<any>("/emergency/stats")
    return response.data
  }

  async createEmergencyContact(contact: any): Promise<any> {
    const response = await this.request<any>("/emergency/contacts", {
      method: "POST",
      body: JSON.stringify(contact),
    })
    return response.data
  }

  async deleteEmergencyContact(id: number): Promise<void> {
    await this.request(`/emergency/contacts/${id}`, {
      method: "DELETE",
    })
  }

  // AI Chatbot Management endpoints
  async getDialogflowConfig(): Promise<any> {
    const response = await this.request<any>("/ai/dialogflow/config")
    return response.data
  }

  async updateDialogflowConfig(config: any): Promise<any> {
    const response = await this.request<any>("/ai/dialogflow/config", {
      method: "PUT",
      body: JSON.stringify(config),
    })
    return response.data
  }

  async getHuggingFaceConfig(): Promise<any> {
    const response = await this.request<any>("/ai/huggingface/config")
    return response.data
  }

  async updateHuggingFaceConfig(config: any): Promise<any> {
    const response = await this.request<any>("/ai/huggingface/config", {
      method: "PUT",
      body: JSON.stringify(config),
    })
    return response.data
  }

  async getFAQItems(): Promise<any[]> {
    const response = await this.request<any[]>("/ai/faq")
    return response.data
  }

  async updateFAQItems(faqItems: any[]): Promise<void> {
    await this.request("/ai/faq", {
      method: "PUT",
      body: JSON.stringify({ faq_items: faqItems }),
    })
  }

  async getChatSessions(): Promise<any[]> {
    const response = await this.request<any[]>("/ai/chat/sessions")
    return response.data
  }

  async testChatbot(message: string): Promise<{ message: string }> {
    const response = await this.request<{ message: string }>("/ai/test", {
      method: "POST",
      body: JSON.stringify({ message }),
    })
    return response.data
  }

  // Notification methods
  async getNotificationStats(): Promise<{
    total_sent: number
    total_delivered: number
    total_failed: number
    active_tokens: number
    users_with_tokens: number
  }> {
    const response = await this.request('/admin/notifications/stats')
    return response.data as {
      total_sent: number
      total_delivered: number
      total_failed: number
      active_tokens: number
      users_with_tokens: number
    }
  }

  async sendNotification(notification: {
    title: string
    body: string
    type: string
    target: string
    department_id?: string
    role?: string
    priority: string
    scheduled: boolean
    scheduled_at?: string
  }): Promise<{ success: boolean; message: string }> {
    const response = await this.request('/admin/notifications/send', {
      method: 'POST',
      body: JSON.stringify(notification)
    })
    return response.data as { success: boolean; message: string }
  }

  async testNotification(notification: {
    title: string
    body: string
  }): Promise<{ success: boolean; message: string }> {
    const response = await this.request('/notifications/test', {
      method: 'POST',
      body: JSON.stringify(notification)
    })
    return response.data as { success: boolean; message: string }
  }

  async getRecentNotifications(limit: number = 10): Promise<any[]> {
    const response = await this.request(`/admin/notifications/recent?limit=${limit}`)
    return response.data as any[]
  }

  async getFcmTokens(): Promise<{
    success: boolean
    data: any[]
    total_tokens: number
  }> {
    const response = await this.request('/notifications/fcm-tokens')
    return response.data as {
      success: boolean
      data: any[]
      total_tokens: number
    }
  }

  async storeFcmToken(token: string, deviceType: string, deviceId?: string): Promise<{ success: boolean; message: string }> {
    const response = await this.request('/notifications/fcm-token', {
      method: 'POST',
      body: JSON.stringify({ token, device_type: deviceType, device_id: deviceId })
    })
    return response.data as { success: boolean; message: string }
  }

  async removeFcmToken(token: string): Promise<{ success: boolean; message: string }> {
    const response = await this.request('/notifications/fcm-token', {
      method: 'DELETE',
      body: JSON.stringify({ token })
    })
    return response.data as { success: boolean; message: string }
  }

  // Chat-related methods
  async getActiveChatRooms(): Promise<ChatRoom[]> {
    const response = await this.request<ChatRoom[]>('/chat/rooms')
    return response.data as ChatRoom[]
  }

  async getOrCreateChatRoom(concernId: number): Promise<ChatRoom> {
    const response = await this.request<ChatRoom>(`/chat/rooms/${concernId}/get-or-create`)
    return response.data as ChatRoom
  }

  async sendChatMessage(chatRoomId: number, message: string, options?: {
    messageType?: string
    replyToId?: number
    attachments?: string[]
  }): Promise<ChatMessage> {
    const response = await this.request<ChatMessage>(`/chat/rooms/${chatRoomId}/messages`, {
      method: 'POST',
      body: JSON.stringify({
        message,
        message_type: options?.messageType || 'text',
        reply_to_id: options?.replyToId,
        attachments: options?.attachments || []
      })
    })
    return response.data as ChatMessage
  }

  async getChatMessages(chatRoomId: number): Promise<ChatMessage[]> {
    const response = await this.request<ChatMessage[]>(`/chat/rooms/${chatRoomId}/messages`)
    return response.data as ChatMessage[]
  }

  async markChatAsRead(chatRoomId: number): Promise<void> {
    await this.request(`/chat/rooms/${chatRoomId}/mark-read`, {
      method: 'POST'
    })
  }

  async closeChatRoom(chatRoomId: number): Promise<void> {
    await this.request(`/chat/rooms/${chatRoomId}/close`, {
      method: 'POST'
    })
  }
}

export const apiClient = new ApiClient(API_BASE_URL)