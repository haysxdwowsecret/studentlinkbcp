import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Label } from "@/components/ui/label"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Switch } from "@/components/ui/switch"
import { Checkbox } from "@/components/ui/checkbox"
import { Calendar } from "@/components/ui/calendar"
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"
import { CalendarIcon, Clock, Users, Target, Save, Send, Eye, Image as ImageIcon, Upload, X } from "lucide-react"
import { useState, useEffect } from "react"
import { format } from "date-fns"
import { apiClient } from "@/lib/api-client"

interface CreateAnnouncementDialogProps {
  isOpen: boolean
  onClose: () => void
  onCreate: (announcement: any) => void
  editingAnnouncement?: any
}

export function CreateAnnouncementDialog({ 
  isOpen, 
  onClose, 
  onCreate, 
  editingAnnouncement 
}: CreateAnnouncementDialogProps) {
  const [title, setTitle] = useState("")
  const [content, setContent] = useState("")
  const [excerpt, setExcerpt] = useState("")
  const [category, setCategory] = useState("")
  const [announcementTitle, setAnnouncementTitle] = useState("")
  const [description, setDescription] = useState("")
  const [actionButtonText, setActionButtonText] = useState("")
  const [actionButtonUrl, setActionButtonUrl] = useState("")
  const [announcementTimestamp, setAnnouncementTimestamp] = useState<Date>()
  const [status, setStatus] = useState("draft")
  const [isScheduled, setIsScheduled] = useState(false)
  const [publishDate, setPublishDate] = useState<Date>()
  const [publishTime, setPublishTime] = useState("")
  const [expiresAt, setExpiresAt] = useState<Date>()
  const [expireTime, setExpireTime] = useState("")
  const [targetDepartments, setTargetDepartments] = useState<number[]>([])
  const [targetRoles, setTargetRoles] = useState<string[]>([])
  const [featuredImage, setFeaturedImage] = useState("")
  const [departments, setDepartments] = useState<any[]>([])
  const [categories, setCategories] = useState<string[]>([
    'Academic Modules',
    'Class Schedules & Exams',
    'Enrollment & Clearance',
    'Scholarships & Financial Aid',
    'Student Activities & Events',
    'Emergency Notices',
    'Administrative Updates',
    'OJT & Career Services',
    'Campus Ministry',
    'Faculty Announcements',
    'System Maintenance',
    'Student Services'
  ])
  const [loading, setLoading] = useState(false)
  const [announcementType, setAnnouncementType] = useState<"text" | "image">("image")
  const [selectedImage, setSelectedImage] = useState<File | null>(null)
  const [imagePreview, setImagePreview] = useState<string | null>(null)

  // Load departments and categories when dialog opens
  useEffect(() => {
    const loadData = async () => {
      try {
        console.log('Loading categories...')
        const [depts, cats] = await Promise.all([
          apiClient.getDepartments(),
          apiClient.getAnnouncementCategories()
        ])
        console.log('Categories loaded:', cats)
        setDepartments(depts)
        setCategories(cats)
      } catch (error) {
        console.error('Failed to load data:', error)
        // Fallback to hardcoded categories if API fails
        const fallbackCategories = [
          'Academic Modules',
          'Class Schedules & Exams',
          'Enrollment & Clearance',
          'Scholarships & Financial Aid',
          'Student Activities & Events',
          'Emergency Notices',
          'Administrative Updates',
          'OJT & Career Services',
          'Campus Ministry',
          'Faculty Announcements',
          'System Maintenance',
          'Student Services'
        ]
        console.log('Using fallback categories:', fallbackCategories)
        setCategories(fallbackCategories)
      }
    }

    if (isOpen) {
      loadData()
    }
  }, [isOpen])

  // Load editing announcement data
  useEffect(() => {
    if (editingAnnouncement) {
      setTitle(editingAnnouncement.internal_title || "")
      setContent(editingAnnouncement.content || "")
      setExcerpt(editingAnnouncement.excerpt || "")
      setCategory(editingAnnouncement.category || "")
      setAnnouncementTitle(editingAnnouncement.title || "")
      setDescription(editingAnnouncement.description || "")
      setActionButtonText(editingAnnouncement.action_button_text || "")
      setActionButtonUrl(editingAnnouncement.action_button_url || "")
      setAnnouncementTimestamp(editingAnnouncement.announcement_timestamp ? new Date(editingAnnouncement.announcement_timestamp) : undefined)
      setStatus(editingAnnouncement.status || "draft")
      setTargetDepartments(editingAnnouncement.target_departments || [])
      setTargetRoles(editingAnnouncement.target_roles || [])
      setFeaturedImage(editingAnnouncement.featured_image || "")
      setAnnouncementType(editingAnnouncement.announcement_type || "image")
      
      // Set image preview if editing an image announcement
      if (editingAnnouncement.announcement_type === "image" && editingAnnouncement.image_url) {
        setImagePreview(editingAnnouncement.image_url)
      }
      
      if (editingAnnouncement.published_at) {
        setIsScheduled(true)
        setPublishDate(new Date(editingAnnouncement.published_at))
        setPublishTime(format(new Date(editingAnnouncement.published_at), "HH:mm"))
      }
      
      if (editingAnnouncement.expires_at) {
        setExpiresAt(new Date(editingAnnouncement.expires_at))
        setExpireTime(format(new Date(editingAnnouncement.expires_at), "HH:mm"))
      }
    } else {
      // Reset form for new announcement
      setTitle("")
      setContent("")
      setExcerpt("")
      setCategory("")
      setAnnouncementTitle("")
      setDescription("")
      setActionButtonText("")
      setActionButtonUrl("")
      setAnnouncementTimestamp(undefined)
      setStatus("draft")
      setIsScheduled(false)
      setPublishDate(undefined)
      setPublishTime("")
      setExpiresAt(undefined)
      setExpireTime("")
      setTargetDepartments([])
      setTargetRoles([])
      setFeaturedImage("")
      setAnnouncementType("image")
      setSelectedImage(null)
      setImagePreview(null)
    }
  }, [editingAnnouncement, isOpen])

  const handleDepartmentToggle = (departmentId: number) => {
    setTargetDepartments(prev => 
      prev.includes(departmentId) 
        ? prev.filter(id => id !== departmentId)
        : [...prev, departmentId]
    )
  }

  const handleRoleToggle = (role: string) => {
    setTargetRoles(prev => 
      prev.includes(role) 
        ? prev.filter(r => r !== role)
        : [...prev, role]
    )
  }

  const handleImageSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (file) {
      setSelectedImage(file)
      const reader = new FileReader()
      reader.onload = (e) => {
        setImagePreview(e.target?.result as string)
      }
      reader.readAsDataURL(file)
    }
  }

  const handleRemoveImage = () => {
    setSelectedImage(null)
    setImagePreview(null)
  }

  const handleSubmit = async (publishNow = false) => {
    // Validate required fields
    if (!category) {
      alert("Please select a category.")
      return
    }

    if (!announcementTitle) {
      alert("Please fill out the announcement title.")
      return
    }

    if (!selectedImage && !editingAnnouncement) {
      alert("Please select an image for the announcement.")
      return
    }

    setLoading(true)
    try {
      // Determine the final status
      const finalStatus = publishNow ? "published" : (status || "draft")
      
      const announcementData = {
        internal_title: title || undefined,
        category,
        title: announcementTitle,
        description: description || undefined,
        action_button_text: actionButtonText || undefined,
        action_button_url: actionButtonUrl || undefined,
        announcement_timestamp: announcementTimestamp?.toISOString(),
        status: finalStatus,
        target_departments: targetDepartments.length > 0 ? targetDepartments : undefined,
        target_roles: targetRoles.length > 0 ? targetRoles : undefined,
        featured_image: featuredImage || undefined,
        published_at: isScheduled && publishDate 
          ? new Date(`${format(publishDate, "yyyy-MM-dd")}T${publishTime || "00:00"}`).toISOString()
          : publishNow 
            ? new Date().toISOString()
            : undefined,
        expires_at: expiresAt 
          ? new Date(`${format(expiresAt, "yyyy-MM-dd")}T${expireTime || "23:59"}`).toISOString()
          : undefined,
        image: selectedImage,
        remove_image: editingAnnouncement && !selectedImage && !imagePreview,
      }

      console.log('🚀 Creating announcement with data:', {
        ...announcementData,
        image: selectedImage ? `File(${selectedImage.name}, ${selectedImage.size} bytes)` : null
      })
      console.log('📸 Selected image details:', {
        name: selectedImage?.name,
        size: selectedImage?.size,
        type: selectedImage?.type,
        lastModified: selectedImage?.lastModified
      })
      console.log('🔐 Auth token present:', !!localStorage.getItem('auth_token'))
      
      await onCreate(announcementData)
      onClose()
    } catch (error) {
      console.error('❌ Failed to create announcement:', error)
      
      // Better error handling
      let errorMessage = 'Failed to create announcement. Please try again.'
      
      if (error?.message) {
        errorMessage = error.message
      } else if (typeof error === 'string') {
        errorMessage = error
      }
      
      alert(errorMessage)
    } finally {
      setLoading(false)
    }
  }

  const handleSaveDraft = () => handleSubmit(false)
  const handlePublishNow = () => handleSubmit(true)

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>
            {editingAnnouncement ? "Edit Announcement" : "Create New Announcement"}
          </DialogTitle>
          <p className="text-sm text-gray-600 mt-2">
            Create announcements with categories, action buttons, and rich content that will appear in the mobile app.
          </p>
        </DialogHeader>
        
        <div className="space-y-6">
          {/* Basic Information */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold">Basic Information</h3>
            
            <div className="space-y-2">
              <Label htmlFor="category">Category *</Label>
              <Select value={category} onValueChange={setCategory}>
                <SelectTrigger>
                  <SelectValue placeholder="Select a category" />
                </SelectTrigger>
                <SelectContent>
                  {categories.length > 0 ? categories.map((cat) => (
                    <SelectItem key={cat} value={cat}>{cat}</SelectItem>
                  )) : (
                    <SelectItem value="loading" disabled>Loading categories...</SelectItem>
                  )}
                </SelectContent>
              </Select>
              {/* Debug info - remove in production */}
              {process.env.NODE_ENV === 'development' && (
                <p className="text-xs text-gray-500">Categories loaded: {categories.length}</p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="announcementTitle">Announcement Title *</Label>
              <Input
                id="announcementTitle"
                placeholder="e.g., Module Grant Steps"
                value={announcementTitle}
                onChange={(e) => setAnnouncementTitle(e.target.value)}
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="description">Description (Optional)</Label>
              <Textarea
                id="description"
                placeholder="Brief description of the announcement"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                rows={3}
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="internalTitle">Internal Title (Optional)</Label>
              <Input
                id="internalTitle"
                placeholder="Internal reference title for admin management"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
              />
              <p className="text-xs text-gray-500">
                This title is only visible to admins and departments for management purposes. It will not appear in the mobile app.
              </p>
            </div>

            {/* Action Button Section */}
            <div className="space-y-4">
              <h4 className="text-md font-medium">Action Button (Optional)</h4>
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="actionButtonText">Button Text</Label>
                  <Input
                    id="actionButtonText"
                    placeholder="e.g., Open Module"
                    value={actionButtonText}
                    onChange={(e) => setActionButtonText(e.target.value)}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="actionButtonUrl">Button URL</Label>
                  <Input
                    id="actionButtonUrl"
                    placeholder="e.g., https://sms.bcp.com"
                    value={actionButtonUrl}
                    onChange={(e) => setActionButtonUrl(e.target.value)}
                  />
                </div>
              </div>
            </div>

            {/* Image Upload Section */}
            <div className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="image">Upload Image *</Label>
                <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center">
                  {imagePreview ? (
                    <div className="space-y-4">
                      <img 
                        src={imagePreview} 
                        alt="Preview" 
                        className="max-h-80 mx-auto rounded-lg object-contain bg-gray-50"
                        style={{ aspectRatio: 'auto' }}
                      />
                      <div className="flex gap-2 justify-center">
                        <Button
                          type="button"
                          variant="outline"
                          onClick={() => document.getElementById('image-input')?.click()}
                        >
                          <Upload className="h-4 w-4 mr-2" />
                          Change Image
                        </Button>
                        <Button
                          type="button"
                          variant="outline"
                          onClick={handleRemoveImage}
                        >
                          <X className="h-4 w-4 mr-2" />
                          Remove
                        </Button>
                      </div>
                    </div>
                  ) : (
                    <div className="space-y-4">
                      <ImageIcon className="h-12 w-12 mx-auto text-gray-400" />
                      <div>
                        <Button
                          type="button"
                          variant="outline"
                          onClick={() => document.getElementById('image-input')?.click()}
                        >
                          <Upload className="h-4 w-4 mr-2" />
                          Select Image
                        </Button>
                      </div>
                      <p className="text-sm text-gray-500">
                        PNG, JPG, GIF, WebP up to 10MB
                      </p>
                    </div>
                  )}
                  <input
                    id="image-input"
                    type="file"
                    accept="image/*"
                    onChange={handleImageSelect}
                    className="hidden"
                  />
                </div>
              </div>
            </div>

            {/* Announcement Timestamp */}
            <div className="space-y-2">
              <Label>Announcement Timestamp (Optional)</Label>
              <div className="grid grid-cols-2 gap-4">
                <Popover>
                  <PopoverTrigger asChild>
                    <Button variant="outline" className="w-full justify-start text-left font-normal">
                      <CalendarIcon className="mr-2 h-4 w-4" />
                      {announcementTimestamp ? format(announcementTimestamp, "PPP") : "Select timestamp"}
                    </Button>
                  </PopoverTrigger>
                  <PopoverContent className="w-auto p-0">
                    <Calendar
                      mode="single"
                      selected={announcementTimestamp}
                      onSelect={setAnnouncementTimestamp}
                      initialFocus
                    />
                  </PopoverContent>
                </Popover>
                <div className="flex items-center space-x-2">
                  <Clock className="h-4 w-4" />
                  <Input
                    type="time"
                    value={announcementTimestamp ? format(announcementTimestamp, "HH:mm") : ""}
                    onChange={(e) => {
                      if (announcementTimestamp) {
                        const [hours, minutes] = e.target.value.split(':')
                        const newDate = new Date(announcementTimestamp)
                        newDate.setHours(parseInt(hours), parseInt(minutes))
                        setAnnouncementTimestamp(newDate)
                      }
                    }}
                    className="flex-1"
                  />
                </div>
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="status">Status</Label>
              <Select value={status} onValueChange={setStatus}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="draft">Draft</SelectItem>
                  <SelectItem value="published">Published</SelectItem>
                  <SelectItem value="archived">Archived</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          {/* Scheduling */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold">Scheduling</h3>
            
            <div className="flex items-center space-x-2">
              <Switch
                id="schedule"
                checked={isScheduled}
                onCheckedChange={setIsScheduled}
              />
              <Label htmlFor="schedule">Schedule for later publication</Label>
            </div>

            {isScheduled && (
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label>Publish Date</Label>
                  <Popover>
                    <PopoverTrigger asChild>
                      <Button variant="outline" className="w-full justify-start text-left font-normal">
                        <CalendarIcon className="mr-2 h-4 w-4" />
                        {publishDate ? format(publishDate, "PPP") : "Select date"}
                      </Button>
                    </PopoverTrigger>
                    <PopoverContent className="w-auto p-0">
                      <Calendar
                        mode="single"
                        selected={publishDate}
                        onSelect={setPublishDate}
                        initialFocus
                      />
                    </PopoverContent>
                  </Popover>
                </div>

                <div className="space-y-2">
                  <Label>Publish Time</Label>
                  <div className="flex items-center space-x-2">
                    <Clock className="h-4 w-4" />
                    <Input
                      type="time"
                      value={publishTime}
                      onChange={(e) => setPublishTime(e.target.value)}
                      className="flex-1"
                    />
                  </div>
                </div>
              </div>
            )}

            <div className="space-y-2">
              <Label>Expiration Date (Optional)</Label>
              <div className="grid grid-cols-2 gap-4">
                <Popover>
                  <PopoverTrigger asChild>
                    <Button variant="outline" className="w-full justify-start text-left font-normal">
                      <CalendarIcon className="mr-2 h-4 w-4" />
                      {expiresAt ? format(expiresAt, "PPP") : "Select expiration date"}
                    </Button>
                  </PopoverTrigger>
                  <PopoverContent className="w-auto p-0">
                    <Calendar
                      mode="single"
                      selected={expiresAt}
                      onSelect={setExpiresAt}
                      initialFocus
                    />
                  </PopoverContent>
                </Popover>

                <div className="flex items-center space-x-2">
                  <Clock className="h-4 w-4" />
                  <Input
                    type="time"
                    value={expireTime}
                    onChange={(e) => setExpireTime(e.target.value)}
                    className="flex-1"
                  />
                </div>
              </div>
            </div>
          </div>

          {/* Targeting */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold">Targeting</h3>
            
            <div className="space-y-4">
              <div>
                <Label className="flex items-center mb-2">
                  <Target className="h-4 w-4 mr-2" />
                  Target Departments
                </Label>
                <div className="grid grid-cols-2 gap-2 max-h-32 overflow-y-auto border rounded p-2">
                  {departments.map((dept) => (
                    <div key={dept.id} className="flex items-center space-x-2">
                      <Checkbox
                        id={`dept-${dept.id}`}
                        checked={targetDepartments.includes(dept.id)}
                        onCheckedChange={() => handleDepartmentToggle(dept.id)}
                      />
                      <Label htmlFor={`dept-${dept.id}`} className="text-sm">
                        {dept.name}
                      </Label>
                    </div>
                  ))}
                </div>
                {targetDepartments.length === 0 && (
                  <p className="text-sm text-muted-foreground mt-1">
                    No departments selected - announcement will be visible to all
                  </p>
                )}
              </div>

              <div>
                <Label className="flex items-center mb-2">
                  <Users className="h-4 w-4 mr-2" />
                  Target Roles
                </Label>
                <div className="grid grid-cols-2 gap-2 max-h-32 overflow-y-auto border rounded p-2">
                  {['student', 'faculty', 'staff', 'department_head', 'admin'].map((role) => (
                    <div key={role} className="flex items-center space-x-2">
                      <Checkbox
                        id={`role-${role}`}
                        checked={targetRoles.includes(role)}
                        onCheckedChange={() => handleRoleToggle(role)}
                      />
                      <Label htmlFor={`role-${role}`} className="text-sm capitalize">
                        {role.replace('_', ' ')}
                      </Label>
                    </div>
                  ))}
                </div>
                {targetRoles.length === 0 && (
                  <p className="text-sm text-muted-foreground mt-1">
                    No roles selected - announcement will be visible to all roles
                  </p>
                )}
              </div>
            </div>
          </div>

          {/* Featured Image */}
          <div className="space-y-2">
            <Label htmlFor="featuredImage">Featured Image URL (Optional)</Label>
            <Input
              id="featuredImage"
              placeholder="https://example.com/image.jpg"
              value={featuredImage}
              onChange={(e) => setFeaturedImage(e.target.value)}
            />
          </div>
        </div>

        <DialogFooter className="flex justify-between">
          <div className="flex space-x-2">
            <Button variant="outline" onClick={onClose} disabled={loading}>
              Cancel
            </Button>
            <Button 
              variant="outline" 
              onClick={handleSaveDraft} 
              disabled={loading}
            >
              <Save className="h-4 w-4 mr-2" />
              Save Draft
            </Button>
          </div>
          <Button 
            onClick={handlePublishNow} 
            disabled={loading}
            className="bg-[#1E2A78] hover:bg-[#2480EA]"
          >
            <Send className="h-4 w-4 mr-2" />
            {loading ? "Publishing..." : "Publish Now"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
