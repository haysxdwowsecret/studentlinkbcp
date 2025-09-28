"use client"

import { useState, useEffect, useRef } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { ScrollArea } from "@/components/ui/scroll-area"
import { Badge } from "@/components/ui/badge"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { 
  Send, 
  MoreVertical, 
  Phone, 
  Video, 
  Paperclip,
  Smile,
  Check,
  CheckCheck,
  Plus,
  CheckCircle,
  AlertCircle,
  Lock,
  LockOpen,
  Info
} from "lucide-react"
import { apiClient, type ChatRoom, type ChatMessage } from "@/lib/api-client"
import { pusherService } from "@/lib/services/pusher-service"
import { formatDistanceToNow } from "date-fns"

interface ChatInterfaceProps {
  chatRoom: ChatRoom
  currentUserId: number
  onClose?: () => void
}

export function ChatInterface({ chatRoom, currentUserId, onClose }: ChatInterfaceProps) {
  const [messages, setMessages] = useState<ChatMessage[]>([])
  const [newMessage, setNewMessage] = useState("")
  const [loading, setLoading] = useState(true)
  const [sending, setSending] = useState(false)
  const [typingUsers, setTypingUsers] = useState<Set<string>>(new Set())
  const messagesEndRef = useRef<HTMLDivElement>(null)
  const typingTimeoutRef = useRef<NodeJS.Timeout>()

  useEffect(() => {
    loadMessages()
    setupWebSocket()
    
    return () => {
      // Cleanup WebSocket subscriptions
      if (chatRoom.id) {
        pusherService.unsubscribeFromChannel(`private-chat.room.${chatRoom.id}`)
      }
    }
  }, [chatRoom.id])

  useEffect(() => {
    scrollToBottom()
  }, [messages])

  const loadMessages = async () => {
    try {
      setLoading(true)
      const chatMessages = await apiClient.getChatMessages(chatRoom.id)
      setMessages(chatMessages)
      
      // Mark messages as read
      await apiClient.markChatAsRead(chatRoom.id)
    } catch (error) {
      console.error('Failed to load messages:', error)
    } finally {
      setLoading(false)
    }
  }

  const setupWebSocket = () => {
    // Subscribe to new messages
    pusherService.subscribeToChatRoom(chatRoom.id, (data: any) => {
      if (data.type === 'new_message') {
        const newMessage = data.message
        setMessages(prev => [...prev, newMessage])
        
        // Mark as read if it's not from current user
        if (newMessage.author_id !== currentUserId) {
          apiClient.markChatAsRead(chatRoom.id)
        }
      }
    })

    // Subscribe to typing status
    pusherService.subscribeToTypingStatus(chatRoom.id, (data: any) => {
      if (data.type === 'typing_status') {
        const userId = data.user.id
        const isTyping = data.is_typing
        
        setTypingUsers(prev => {
          const newSet = new Set(prev)
          if (isTyping) {
            newSet.add(userId)
          } else {
            newSet.delete(userId)
          }
          return newSet
        })
      }
    })
  }

  const sendMessage = async () => {
    if (!newMessage.trim() || sending) return

    const messageText = newMessage.trim()
    setNewMessage("")
    setSending(true)

    try {
      const sentMessage = await apiClient.sendChatMessage(chatRoom.id, messageText)
      setMessages(prev => [...prev, sentMessage])
    } catch (error) {
      console.error('Failed to send message:', error)
      // Restore message on error
      setNewMessage(messageText)
    } finally {
      setSending(false)
    }
  }

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      sendMessage()
    }
  }

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }

  const formatTime = (dateString: string) => {
    try {
      return new Date(dateString).toLocaleTimeString([], { 
        hour: '2-digit', 
        minute: '2-digit' 
      })
    } catch {
      return ''
    }
  }

  const getMessageStatus = (message: ChatMessage) => {
    if (message.author_id !== currentUserId) return null
    
    if (message.read_at) {
      return <CheckCheck className="h-3 w-3 text-blue-500" />
    } else if (message.delivered_at) {
      return <CheckCheck className="h-3 w-3 text-gray-400" />
    } else {
      return <Check className="h-3 w-3 text-gray-400" />
    }
  }

  const shouldShowAvatar = (message: ChatMessage, index: number) => {
    if (index === 0) return true
    
    const previousMessage = messages[index - 1]
    if (!previousMessage) return true
    
    const timeDiff = new Date(message.created_at).getTime() - new Date(previousMessage.created_at).getTime()
    const fiveMinutes = 5 * 60 * 1000
    
    return previousMessage.author_id !== message.author_id || timeDiff > fiveMinutes
  }

  const shouldShowTimestamp = (message: ChatMessage, index: number) => {
    if (index === messages.length - 1) return true
    
    const nextMessage = messages[index + 1]
    if (!nextMessage) return true
    
    const timeDiff = new Date(nextMessage.created_at).getTime() - new Date(message.created_at).getTime()
    const fiveMinutes = 5 * 60 * 1000
    
    return nextMessage.author_id !== message.author_id || timeDiff > fiveMinutes
  }

  const renderSystemMessage = (message: ChatMessage) => {
    let icon, bgColor, borderColor, textColor
    
    switch (message.type) {
      case 'resolution_confirmation':
        icon = <CheckCircle className="h-4 w-4" />
        bgColor = 'bg-green-50'
        borderColor = 'border-green-200'
        textColor = 'text-green-800'
        break
      case 'resolution_dispute':
        icon = <AlertCircle className="h-4 w-4" />
        bgColor = 'bg-orange-50'
        borderColor = 'border-orange-200'
        textColor = 'text-orange-800'
        break
      case 'chat_closure':
        icon = <Lock className="h-4 w-4" />
        bgColor = 'bg-gray-50'
        borderColor = 'border-gray-200'
        textColor = 'text-gray-800'
        break
      case 'chat_reopened':
        icon = <LockOpen className="h-4 w-4" />
        bgColor = 'bg-blue-50'
        borderColor = 'border-blue-200'
        textColor = 'text-blue-800'
        break
      default:
        icon = <Info className="h-4 w-4" />
        bgColor = 'bg-blue-50'
        borderColor = 'border-blue-200'
        textColor = 'text-blue-800'
    }
    
    return (
      <div className={`px-4 py-3 rounded-2xl border ${bgColor} ${borderColor} ${textColor} shadow-sm max-w-md`}>
        <div className="flex items-center gap-3">
          {icon}
          <p className="text-sm font-medium leading-relaxed">{message.message}</p>
        </div>
      </div>
    )
  }

  const concern = chatRoom.concern
  if (!concern) return null

  return (
    <div className="h-full flex flex-col">
      {/* Chat Header */}
      <CardHeader className="border-b bg-white">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Avatar>
              <AvatarFallback>
                {concern.student.name.charAt(0).toUpperCase()}
              </AvatarFallback>
            </Avatar>
            <div>
              <CardTitle className="text-lg">{concern.subject}</CardTitle>
              <div className="flex items-center gap-2 mt-1">
                <span className="text-sm text-gray-600">{concern.student.name}</span>
                <Badge 
                  variant="outline" 
                  className={`text-xs ${
                    concern.status === 'staff_resolved' ? 'border-blue-500 text-blue-600 bg-blue-50' :
                    concern.status === 'student_confirmed' ? 'border-green-500 text-green-600 bg-green-50' :
                    concern.status === 'disputed' ? 'border-red-500 text-red-600 bg-red-50' :
                    'border-gray-500 text-gray-600 bg-gray-50'
                  }`}
                >
                  {concern.status.replace('_', ' ').toUpperCase()}
                </Badge>
              </div>
            </div>
          </div>
          
          <div className="flex items-center gap-2">
            <Button variant="ghost" size="sm">
              <Phone className="h-4 w-4" />
            </Button>
            <Button variant="ghost" size="sm">
              <Video className="h-4 w-4" />
            </Button>
            <Button variant="ghost" size="sm">
              <MoreVertical className="h-4 w-4" />
            </Button>
          </div>
        </div>
      </CardHeader>

      {/* Status Banner */}
      {concern.status === 'staff_resolved' && (
        <div className="bg-blue-50 border-b border-blue-200 px-4 py-3">
          <div className="flex items-center gap-2">
            <CheckCircle className="h-4 w-4 text-blue-600" />
            <span className="text-sm font-medium text-blue-800">
              Staff has marked this concern as resolved. Please confirm if your issue has been addressed.
            </span>
          </div>
        </div>
      )}

      {/* Resolution Confirmation Widget */}
      {concern.status === 'staff_resolved' && (
        <div className="bg-white border-b border-gray-200 p-4">
          <div className="bg-blue-50 border border-blue-200 rounded-xl p-4">
            <div className="flex items-start gap-3">
              <CheckCircle className="h-5 w-5 text-blue-600 mt-0.5 flex-shrink-0" />
              <div className="flex-1">
                <h3 className="font-semibold text-blue-900 mb-2">Resolution Confirmation</h3>
                <p className="text-sm text-blue-800 mb-4">
                  Staff has marked this concern as resolved. Please confirm if your issue has been addressed.
                </p>
                <div className="flex gap-2">
                  <Button 
                    size="sm" 
                    className="bg-green-600 hover:bg-green-700 text-white"
                    onClick={() => {
                      // Handle confirm resolution
                      console.log('Confirm resolution')
                    }}
                  >
                    <CheckCircle className="h-4 w-4 mr-1" />
                    Confirm Resolved
                  </Button>
                  <Button 
                    size="sm" 
                    variant="outline"
                    className="border-red-300 text-red-600 hover:bg-red-50"
                    onClick={() => {
                      // Handle dispute resolution
                      console.log('Dispute resolution')
                    }}
                  >
                    <AlertCircle className="h-4 w-4 mr-1" />
                    Dispute
                  </Button>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Messages Area */}
      <CardContent className="flex-1 p-0 overflow-hidden">
        <ScrollArea className="h-full">
          <div className="p-4 space-y-4">
            {loading ? (
              <div className="flex items-center justify-center h-32">
                <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600"></div>
              </div>
            ) : messages.length === 0 ? (
              <div className="text-center py-8">
                <p className="text-gray-500">No messages yet</p>
                <p className="text-sm text-gray-400 mt-1">Start the conversation</p>
              </div>
            ) : (
              messages.map((message, index) => {
                const isMe = message.author_id === currentUserId
                const author = message.author
                const showAvatar = shouldShowAvatar(message, index)
                const showTimestamp = shouldShowTimestamp(message, index)

                // Handle system messages
                if (message.type === 'system' || message.type === 'resolution_confirmation' || 
                    message.type === 'resolution_dispute' || message.type === 'chat_closure' || 
                    message.type === 'chat_reopened') {
                  return (
                    <div key={message.id} className="flex justify-center">
                      {renderSystemMessage(message)}
                    </div>
                  )
                }

                return (
                  <div
                    key={message.id}
                    className={`flex ${isMe ? 'justify-end' : 'justify-start'} mb-1`}
                  >
                    <div className={`flex gap-2 max-w-[75%] ${isMe ? 'flex-row-reverse' : 'flex-row'}`}>
                      {!isMe && showAvatar && (
                        <Avatar className="h-8 w-8 flex-shrink-0">
                          <AvatarFallback className="text-xs bg-blue-100 text-blue-600">
                            {author?.name?.charAt(0).toUpperCase() || '?'}
                          </AvatarFallback>
                        </Avatar>
                      )}
                      
                      {isMe && showAvatar && (
                        <Avatar className="h-8 w-8 flex-shrink-0">
                          <AvatarFallback className="text-xs bg-blue-600 text-white">
                            {author?.name?.charAt(0).toUpperCase() || 'U'}
                          </AvatarFallback>
                        </Avatar>
                      )}
                      
                      <div className={`flex flex-col ${isMe ? 'items-end' : 'items-start'}`}>
                        <div
                          className={`px-4 py-3 rounded-2xl shadow-sm max-w-full ${
                            isMe
                              ? 'bg-blue-500 text-white rounded-br-md'
                              : 'bg-gray-100 text-gray-900 rounded-bl-md'
                          }`}
                          style={{
                            boxShadow: isMe 
                              ? '0 2px 8px rgba(59, 130, 246, 0.3)' 
                              : '0 2px 8px rgba(0, 0, 0, 0.1)'
                          }}
                        >
                          <p className="text-sm leading-relaxed break-words">{message.message}</p>
                        </div>
                        
                        {showTimestamp && (
                          <div className={`flex items-center gap-1 mt-1 text-xs text-gray-500 ${isMe ? 'flex-row-reverse' : 'flex-row'}`}>
                            <span>{formatTime(message.created_at)}</span>
                            {isMe && getMessageStatus(message)}
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                )
              })
            )}
            
            {/* Typing Indicator */}
            {typingUsers.size > 0 && (
              <div className="flex justify-start">
                <div className="flex gap-2">
                  <Avatar className="h-6 w-6">
                    <AvatarFallback className="text-xs">?</AvatarFallback>
                  </Avatar>
                  <div className="bg-gray-100 px-3 py-2 rounded-lg">
                    <div className="flex gap-1">
                      <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></div>
                      <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0.1s' }}></div>
                      <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></div>
                    </div>
                  </div>
                </div>
              </div>
            )}
            
            <div ref={messagesEndRef} />
          </div>
        </ScrollArea>
      </CardContent>

      {/* Message Input */}
      <div className="border-t bg-white p-4 shadow-lg">
        <div className="flex items-end gap-3">
          {/* Add Button */}
          <Button 
            variant="ghost" 
            size="sm"
            className="h-10 w-10 rounded-full bg-gray-100 hover:bg-gray-200 flex-shrink-0"
          >
            <Plus className="h-5 w-5 text-gray-600" />
          </Button>
          
          {/* Message Input */}
          <div className="flex-1 relative">
            <div className="bg-gray-50 rounded-2xl border border-gray-200 focus-within:border-blue-300 focus-within:ring-2 focus-within:ring-blue-100 transition-all">
              <textarea
                value={newMessage}
                onChange={(e) => setNewMessage(e.target.value)}
                onKeyDown={handleKeyPress}
                placeholder="Message..."
                className="w-full px-4 py-3 bg-transparent border-0 rounded-2xl resize-none focus:outline-none text-sm leading-relaxed"
                rows={1}
                style={{
                  minHeight: '44px',
                  maxHeight: '120px',
                  height: 'auto'
                }}
                disabled={sending}
                onInput={(e) => {
                  const target = e.target as HTMLTextAreaElement
                  target.style.height = 'auto'
                  target.style.height = Math.min(target.scrollHeight, 120) + 'px'
                }}
              />
            </div>
          </div>
          
          {/* Send Button */}
          <Button 
            onClick={sendMessage} 
            disabled={!newMessage.trim() || sending}
            size="sm"
            className={`h-10 w-10 rounded-full flex-shrink-0 transition-all ${
              newMessage.trim() && !sending
                ? 'bg-blue-500 hover:bg-blue-600 shadow-lg shadow-blue-500/30'
                : 'bg-gray-300 cursor-not-allowed'
            }`}
          >
            {sending ? (
              <div className="animate-spin rounded-full h-4 w-4 border-2 border-white border-t-transparent" />
            ) : (
              <Send className="h-4 w-4 text-white" />
            )}
          </Button>
        </div>
      </div>
    </div>
  )
}

