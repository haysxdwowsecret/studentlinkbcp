const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL || "https://bcpstudentlink.online/api"

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
  role: "admin" | "department_head" | "staff" | "faculty" | "student"
  department: string
  department_id: number
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
  status: "pending" | "in_progress" | "resolved" | "closed" | "cancelled"
  is_anonymous: boolean
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

export interface Announcement {
  id: number
  title: string
  content: string
  excerpt?: string
  type: "general" | "academic" | "administrative" | "event" | "emergency"
  priority: "low" | "medium" | "high" | "urgent"
  status: "draft" | "published" | "archived"
  author: {
    id: number
    name: string
    role: string
  }
  target_departments?: number[]
  target_roles?: string[]
  published_at?: string
  expires_at?: string
  featured_image?: string
  view_count: number
  bookmark_count: number
  is_bookmarked: boolean
  created_at: string
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

  private async request<T>(endpoint: string, options: RequestInit = {}): Promise<ApiResponse<T>> {
    const url = `${this.baseURL}${endpoint}`
    const headers: HeadersInit = {
      "Content-Type": "application/json",
      ...options.headers,
    }

    if (this.token) {
      headers.Authorization = `Bearer ${this.token}`
    }

    try {
      const response = await fetch(url, {
        ...options,
        headers,
      })

      const data = await response.json()

      if (!response.ok) {
        // Handle 401 unauthorized - token expired
        if (response.status === 401) {
          this.removeTokenFromStorage()
          // Redirect to login page or refresh token
          if (typeof window !== 'undefined') {
            window.location.href = '/login'
          }
        }
        
        throw new Error(data.message || `HTTP error! status: ${response.status}`)
      }

      return data as ApiResponse<T>
    } catch (error) {
      console.error(`API request failed for ${endpoint}:`, error)
      throw error
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

  async createAnnouncement(announcement: {
    title: string
    content: string
    excerpt?: string
    type: string
    priority: string
    target_departments?: number[]
    target_roles?: string[]
    published_at?: string
    expires_at?: string
    featured_image?: string
  }): Promise<Announcement> {
    const response = await this.request<Announcement>("/announcements", {
      method: "POST",
      body: JSON.stringify(announcement),
    })
    return response.data
  }

  async updateAnnouncement(id: number, announcement: Partial<Announcement>): Promise<Announcement> {
    const response = await this.request<Announcement>(`/announcements/${id}`, {
      method: "PUT",
      body: JSON.stringify(announcement),
    })
    return response.data
  }

  async deleteAnnouncement(id: number): Promise<void> {
    await this.request(`/announcements/${id}`, {
      method: "DELETE",
    })
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

  // Departments endpoints
  async getDepartments(): Promise<Department[]> {
    const response = await this.request<Department[]>("/departments")
    return response.data
  }

  async getDepartment(id: number): Promise<Department> {
    const response = await this.request<Department>(`/departments/${id}`)
    return response.data
  }

  async getDepartmentStats(id: number): Promise<any> {
    const response = await this.request<any>(`/departments/${id}/stats`)
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

  async storeFcmToken(token: string, deviceType: string, deviceId?: string): Promise<void> {
    await this.request("/notifications/fcm-token", {
      method: "POST",
      body: JSON.stringify({
        token,
        device_type: deviceType,
        device_id: deviceId
      }),
    })
  }

  // Analytics endpoints
  async getDashboardStats(): Promise<DashboardStats> {
    const response = await this.request<DashboardStats>("/analytics/dashboard")
    return response.data
  }

  async getConcernStats(filters?: any): Promise<any> {
    const queryParams = filters ? `?${new URLSearchParams(filters)}` : ""
    const response = await this.request<any>(`/analytics/concerns${queryParams}`)
    return response.data
  }

  async getDepartmentStats(): Promise<any[]> {
    const response = await this.request<any[]>("/analytics/departments")
    return response.data
  }

  async getUserStats(): Promise<any> {
    const response = await this.request<any>("/analytics/users")
    return response.data
  }

  async exportReport(type: string, filters?: any): Promise<Blob> {
    const queryParams = filters ? `?${new URLSearchParams(filters)}` : ""
    const response = await fetch(`${this.baseURL}/analytics/reports/export${queryParams}`, {
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
      throw new Error(data.message || 'Upload failed')
    }

    return data.data
  }
}

export const apiClient = new ApiClient(API_BASE_URL)