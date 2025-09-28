"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { ScrollArea } from "@/components/ui/scroll-area"
import { 
  MessageSquare, 
  Search, 
  Clock, 
  CheckCircle, 
  AlertCircle,
  User,
  MoreVertical
} from "lucide-react"
import { apiClient, type ChatRoom } from "@/lib/api-client"
import { formatDistanceToNow } from "date-fns"

interface ChatRoomListProps {
  onSelectChatRoom: (chatRoom: ChatRoom) => void
  selectedChatRoomId?: number
}

export function ChatRoomList({ onSelectChatRoom, selectedChatRoomId }: ChatRoomListProps) {
  const [chatRooms, setChatRooms] = useState<ChatRoom[]>([])
  const [loading, setLoading] = useState(true)
  const [searchQuery, setSearchQuery] = useState("")

  useEffect(() => {
    loadChatRooms()
  }, [])

  const loadChatRooms = async () => {
    try {
      setLoading(true)
      const rooms = await apiClient.getActiveChatRooms()
      setChatRooms(rooms)
    } catch (error) {
      console.error('Failed to load chat rooms:', error)
    } finally {
      setLoading(false)
    }
  }

  const filteredChatRooms = chatRooms.filter(room => {
    if (!searchQuery) return true
    
    const concern = room.concern
    if (!concern) return false
    
    return (
      concern.subject.toLowerCase().includes(searchQuery.toLowerCase()) ||
      concern.description.toLowerCase().includes(searchQuery.toLowerCase()) ||
      room.room_name.toLowerCase().includes(searchQuery.toLowerCase())
    )
  })

  const getStatusColor = (status: string) => {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'bg-orange-100 text-orange-800'
      case 'in_progress':
        return 'bg-blue-100 text-blue-800'
      case 'resolved':
        return 'bg-green-100 text-green-800'
      case 'closed':
        return 'bg-gray-100 text-gray-800'
      default:
        return 'bg-gray-100 text-gray-800'
    }
  }

  const getStatusIcon = (status: string) => {
    switch (status.toLowerCase()) {
      case 'pending':
        return <Clock className="h-3 w-3" />
      case 'in_progress':
        return <AlertCircle className="h-3 w-3" />
      case 'resolved':
        return <CheckCircle className="h-3 w-3" />
      case 'closed':
        return <CheckCircle className="h-3 w-3" />
      default:
        return <AlertCircle className="h-3 w-3" />
    }
  }

  const formatLastActivity = (lastActivity?: string) => {
    if (!lastActivity) return 'No activity'
    
    try {
      return formatDistanceToNow(new Date(lastActivity), { addSuffix: true })
    } catch {
      return 'Unknown'
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  return (
    <div className="h-full flex flex-col">
      {/* Header */}
      <div className="p-4 border-b">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-gray-900">Active Chats</h2>
          <Button
            variant="outline"
            size="sm"
            onClick={loadChatRooms}
          >
            Refresh
          </Button>
        </div>
        
        {/* Search */}
        <div className="relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
          <Input
            placeholder="Search chats..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pl-10"
          />
        </div>
      </div>

      {/* Chat Rooms List */}
      <ScrollArea className="flex-1">
        <div className="p-2 space-y-2">
          {filteredChatRooms.length === 0 ? (
            <div className="text-center py-8">
              <MessageSquare className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <p className="text-gray-500">No active chats found</p>
              <p className="text-sm text-gray-400 mt-1">
                {searchQuery ? 'Try adjusting your search' : 'Start a conversation by responding to a concern'}
              </p>
            </div>
          ) : (
            filteredChatRooms.map((room) => {
              const concern = room.concern
              if (!concern) return null

              const isSelected = selectedChatRoomId === room.id
              const hasUnread = (room.unread_count || 0) > 0

              return (
                <Card
                  key={room.id}
                  className={`cursor-pointer transition-all hover:shadow-md ${
                    isSelected ? 'ring-2 ring-blue-500 bg-blue-50' : ''
                  }`}
                  onClick={() => onSelectChatRoom(room)}
                >
                  <CardContent className="p-4">
                    <div className="flex items-start justify-between">
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2 mb-2">
                          <h3 className="font-medium text-gray-900 truncate">
                            {concern.subject}
                          </h3>
                          {hasUnread && (
                            <Badge variant="destructive" className="text-xs">
                              {room.unread_count}
                            </Badge>
                          )}
                        </div>
                        
                        <div className="flex items-center gap-2 mb-2">
                          <Badge className={`text-xs ${getStatusColor(concern.status)}`}>
                            {getStatusIcon(concern.status)}
                            <span className="ml-1">{concern.status.toUpperCase()}</span>
                          </Badge>
                          <Badge variant="outline" className="text-xs">
                            {concern.priority.toUpperCase()}
                          </Badge>
                        </div>

                        <p className="text-sm text-gray-600 truncate mb-2">
                          {room.latest_message?.message || 'No messages yet'}
                        </p>

                        <div className="flex items-center justify-between text-xs text-gray-500">
                          <div className="flex items-center gap-1">
                            <User className="h-3 w-3" />
                            <span>{concern.student.name}</span>
                          </div>
                          <span>{formatLastActivity(room.last_activity_at)}</span>
                        </div>
                      </div>
                      
                      <Button variant="ghost" size="sm" className="ml-2">
                        <MoreVertical className="h-4 w-4" />
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              )
            })
          )}
        </div>
      </ScrollArea>
    </div>
  )
}

