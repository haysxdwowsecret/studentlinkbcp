"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { 
  MessageSquare, 
  Users, 
  Clock, 
  CheckCircle,
  AlertCircle,
  X
} from "lucide-react"
import { ChatRoomList } from "./chat-room-list"
import { ChatInterface } from "./chat-interface"
import { type ChatRoom } from "@/lib/api-client"
import { useAuth } from "@/components/auth-provider"

export function ChatDashboard() {
  const { user } = useAuth()
  const [selectedChatRoom, setSelectedChatRoom] = useState<ChatRoom | null>(null)
  const [view, setView] = useState<'list' | 'chat'>('list')

  const handleSelectChatRoom = (chatRoom: ChatRoom) => {
    setSelectedChatRoom(chatRoom)
    setView('chat')
  }

  const handleBackToList = () => {
    setSelectedChatRoom(null)
    setView('list')
  }

  const handleCloseChat = () => {
    setSelectedChatRoom(null)
    setView('list')
  }

  if (!user) {
    return (
      <div className="flex items-center justify-center h-64">
        <p className="text-gray-500">Please log in to access chat</p>
      </div>
    )
  }

  return (
    <div className="h-full flex flex-col">
      {/* Header */}
      <CardHeader className="border-b bg-white">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <MessageSquare className="h-6 w-6 text-blue-600" />
            <div>
              <CardTitle className="text-xl">Real-time Chat</CardTitle>
              <p className="text-sm text-gray-600 mt-1">
                Communicate with students in real-time
              </p>
            </div>
          </div>
          
          {view === 'chat' && selectedChatRoom && (
            <div className="flex items-center gap-2">
              <Badge variant="outline" className="text-xs">
                {selectedChatRoom.concern?.status.toUpperCase()}
              </Badge>
              <Button
                variant="ghost"
                size="sm"
                onClick={handleBackToList}
              >
                <X className="h-4 w-4" />
              </Button>
            </div>
          )}
        </div>
      </CardHeader>

      {/* Content */}
      <CardContent className="flex-1 p-0 overflow-hidden">
        {view === 'list' ? (
          <ChatRoomList 
            onSelectChatRoom={handleSelectChatRoom}
            selectedChatRoomId={selectedChatRoom?.id}
          />
        ) : selectedChatRoom ? (
          <ChatInterface
            chatRoom={selectedChatRoom}
            currentUserId={user.id}
            onClose={handleCloseChat}
          />
        ) : (
          <div className="flex items-center justify-center h-64">
            <p className="text-gray-500">No chat room selected</p>
          </div>
        )}
      </CardContent>
    </div>
  )
}

