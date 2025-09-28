"use client"

import { useState } from "react"
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Textarea } from "@/components/ui/textarea"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { MessageSquare, Clock, CheckCircle, AlertCircle, User, Calendar, Hash } from "lucide-react"
import { apiClient } from "@/lib/api-client"

interface Concern {
  id: number
  subject: string
  description: string
  status: 'pending' | 'approved' | 'rejected' | 'in_progress' | 'resolved'
  priority: 'low' | 'medium' | 'high' | 'urgent'
  is_anonymous: boolean
  reference_number: string
  created_at: string
  rejection_reason?: string
  approved_at?: string
  rejected_at?: string
  approved_by?: {
    name: string
  }
  rejected_by?: {
    name: string
  }
  student?: {
    name: string
  }
  department?: {
    name: string
  }
}

interface ConcernDetailsDialogProps {
  concern: Concern | null
  isOpen: boolean
  onClose: () => void
  onUpdate: () => void
}

export function ConcernDetailsDialog({ concern, isOpen, onClose, onUpdate }: ConcernDetailsDialogProps) {
  const [response, setResponse] = useState("")
  const [newStatus, setNewStatus] = useState<string>("")
  const [newPriority, setNewPriority] = useState<string>("")
  const [rejectionReason, setRejectionReason] = useState("")
  const [isSubmitting, setIsSubmitting] = useState(false)

  if (!concern) return null

  const handleStatusUpdate = async () => {
    if (!newStatus) return

    setIsSubmitting(true)
    try {
      await apiClient.updateConcernStatus(concern.id, newStatus as any)
      onUpdate()
      onClose()
    } catch (error) {
      console.error('Failed to update status:', error)
    } finally {
      setIsSubmitting(false)
    }
  }

  const handlePriorityUpdate = async () => {
    if (!newPriority) return

    setIsSubmitting(true)
    try {
      await apiClient.updateConcernPriority(concern.id, newPriority as any)
      onUpdate()
      onClose()
    } catch (error) {
      console.error('Failed to update priority:', error)
    } finally {
      setIsSubmitting(false)
    }
  }

  const handleAddResponse = async () => {
    if (!response.trim()) return

    setIsSubmitting(true)
    try {
      await apiClient.addConcernMessage(concern.id, response)
      setResponse("")
      onUpdate()
    } catch (error) {
      console.error('Failed to add response:', error)
    } finally {
      setIsSubmitting(false)
    }
  }

  const handleApprove = async () => {
    setIsSubmitting(true)
    try {
      await apiClient.approveConcern(concern.id)
      onUpdate()
      onClose()
    } catch (error) {
      console.error('Failed to approve concern:', error)
    } finally {
      setIsSubmitting(false)
    }
  }

  const handleReject = async () => {
    if (!rejectionReason.trim()) {
      alert('Please provide a reason for rejection')
      return
    }

    setIsSubmitting(true)
    try {
      await apiClient.rejectConcern(concern.id, rejectionReason)
      setRejectionReason("")
      onUpdate()
      onClose()
    } catch (error) {
      console.error('Failed to reject concern:', error)
    } finally {
      setIsSubmitting(false)
    }
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'approved':
        return <CheckCircle className="h-4 w-4 text-green-600" />
      case 'rejected':
        return <AlertCircle className="h-4 w-4 text-red-600" />
      case 'resolved':
        return <CheckCircle className="h-4 w-4 text-green-600" />
      case 'in_progress':
        return <Clock className="h-4 w-4 text-blue-600" />
      default:
        return <AlertCircle className="h-4 w-4 text-orange-600" />
    }
  }

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'urgent':
        return 'bg-red-100 text-red-800'
      case 'high':
        return 'bg-orange-100 text-orange-800'
      case 'medium':
        return 'bg-yellow-100 text-yellow-800'
      default:
        return 'bg-gray-100 text-gray-800'
    }
  }

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <MessageSquare className="h-5 w-5" />
            Concern Details
          </DialogTitle>
          <DialogDescription>
            Reference: {concern.reference_number}
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-6">
          {/* Concern Information */}
          <Card>
            <CardHeader>
              <CardTitle className="text-lg">{concern.subject}</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="flex items-center gap-2">
                  <User className="h-4 w-4 text-gray-500" />
                  <span className="text-sm text-gray-600">
                    {concern.is_anonymous ? 'Anonymous Student' : (concern.student?.name || 'Unknown')}
                  </span>
                </div>
                <div className="flex items-center gap-2">
                  <Calendar className="h-4 w-4 text-gray-500" />
                  <span className="text-sm text-gray-600">
                    {new Date(concern.created_at).toLocaleDateString()}
                  </span>
                </div>
                <div className="flex items-center gap-2">
                  <Hash className="h-4 w-4 text-gray-500" />
                  <span className="text-sm text-gray-600">
                    {concern.reference_number}
                  </span>
                </div>
                <div className="flex items-center gap-2">
                  {getStatusIcon(concern.status)}
                  <Badge className={getPriorityColor(concern.priority)}>
                    {concern.priority.charAt(0).toUpperCase() + concern.priority.slice(1)}
                  </Badge>
                </div>
              </div>
              
              <div>
                <h4 className="font-medium mb-2">Description:</h4>
                <p className="text-sm text-gray-700 bg-gray-50 p-3 rounded-md">
                  {concern.description}
                </p>
              </div>
            </CardContent>
          </Card>

          {/* Approval/Rejection Section - Only show for pending concerns */}
          {concern.status === 'pending' && (
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Approve or Reject Concern</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="flex gap-4">
                  <Button 
                    onClick={handleApprove}
                    disabled={isSubmitting}
                    className="bg-green-600 hover:bg-green-700 text-white"
                  >
                    {isSubmitting ? 'Approving...' : 'Approve Concern'}
                  </Button>
                  <Button 
                    onClick={handleReject}
                    disabled={isSubmitting}
                    variant="destructive"
                  >
                    {isSubmitting ? 'Rejecting...' : 'Reject Concern'}
                  </Button>
                </div>
                
                {/* Rejection Reason Input */}
                <div>
                  <label className="text-sm font-medium mb-2 block">Rejection Reason (Required for rejection)</label>
                  <Textarea
                    placeholder="Please provide a detailed reason for rejecting this concern..."
                    value={rejectionReason}
                    onChange={(e) => setRejectionReason(e.target.value)}
                    rows={3}
                  />
                </div>
              </CardContent>
            </Card>
          )}

          {/* Show rejection reason if concern is rejected */}
          {concern.status === 'rejected' && concern.rejection_reason && (
            <Card>
              <CardHeader>
                <CardTitle className="text-lg text-red-600">Rejection Details</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="bg-red-50 border border-red-200 rounded-md p-4">
                  <p className="text-sm text-red-800">
                    <strong>Reason:</strong> {concern.rejection_reason}
                  </p>
                  {concern.rejected_at && (
                    <p className="text-xs text-red-600 mt-2">
                      Rejected on: {new Date(concern.rejected_at).toLocaleString()}
                    </p>
                  )}
                  {concern.rejected_by && (
                    <p className="text-xs text-red-600">
                      By: {concern.rejected_by.name}
                    </p>
                  )}
                </div>
              </CardContent>
            </Card>
          )}

          {/* Status and Priority Management */}
          <Card>
            <CardHeader>
              <CardTitle className="text-lg">Manage Concern</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-sm font-medium mb-2 block">Update Status</label>
                  <div className="flex gap-2">
                    <Select value={newStatus} onValueChange={setNewStatus}>
                      <SelectTrigger>
                        <SelectValue placeholder="Select status" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="pending">Pending</SelectItem>
                        <SelectItem value="approved">Approved</SelectItem>
                        <SelectItem value="rejected">Rejected</SelectItem>
                        <SelectItem value="in_progress">In Progress</SelectItem>
                        <SelectItem value="resolved">Resolved</SelectItem>
                      </SelectContent>
                    </Select>
                    <Button 
                      onClick={handleStatusUpdate}
                      disabled={!newStatus || isSubmitting}
                      size="sm"
                    >
                      Update
                    </Button>
                  </div>
                </div>

                <div>
                  <label className="text-sm font-medium mb-2 block">Update Priority</label>
                  <div className="flex gap-2">
                    <Select value={newPriority} onValueChange={setNewPriority}>
                      <SelectTrigger>
                        <SelectValue placeholder="Select priority" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="low">Low</SelectItem>
                        <SelectItem value="medium">Medium</SelectItem>
                        <SelectItem value="high">High</SelectItem>
                        <SelectItem value="urgent">Urgent</SelectItem>
                      </SelectContent>
                    </Select>
                    <Button 
                      onClick={handlePriorityUpdate}
                      disabled={!newPriority || isSubmitting}
                      size="sm"
                    >
                      Update
                    </Button>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Response Section */}
          <Card>
            <CardHeader>
              <CardTitle className="text-lg">Add Response</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <Textarea
                placeholder="Type your response to the student..."
                value={response}
                onChange={(e) => setResponse(e.target.value)}
                rows={4}
              />
              <div className="flex justify-end gap-2">
                <Button variant="outline" onClick={onClose}>
                  Cancel
                </Button>
                <Button 
                  onClick={handleAddResponse}
                  disabled={!response.trim() || isSubmitting}
                  className="bg-[#1E2A78] hover:bg-[#2480EA]"
                >
                  {isSubmitting ? 'Sending...' : 'Send Response'}
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>
      </DialogContent>
    </Dialog>
  )
}

