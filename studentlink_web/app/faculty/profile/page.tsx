"use client"

import { RoleBasedNav } from "@/components/navigation/role-based-nav"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Switch } from "@/components/ui/switch"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { User, Bell, Key, Save, GraduationCap } from "lucide-react"

export default function FacultyProfilePage() {
  return (
    <div className="flex h-screen bg-gray-50">
      <RoleBasedNav />

      <div className="flex-1 overflow-y-auto">
        <header className="bg-white shadow-sm border-b border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-bold text-[#1E2A78]">Profile & Settings</h1>
              <p className="text-gray-600">Manage your account information and preferences</p>
            </div>
            <Button className="bg-[#1E2A78] hover:bg-[#2480EA]">
              <Save className="h-4 w-4 mr-2" />
              Save Changes
            </Button>
          </div>
        </header>

        <div className="p-6">
          <Tabs defaultValue="profile" className="space-y-6">
            <TabsList className="grid w-full grid-cols-4">
              <TabsTrigger value="profile">Profile</TabsTrigger>
              <TabsTrigger value="academic">Academic</TabsTrigger>
              <TabsTrigger value="notifications">Notifications</TabsTrigger>
              <TabsTrigger value="security">Security</TabsTrigger>
            </TabsList>

            <TabsContent value="profile">
              <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <Card className="lg:col-span-2">
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <User className="h-5 w-5" />
                      Personal Information
                    </CardTitle>
                    <CardDescription>Update your personal details and contact information</CardDescription>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                      <div className="space-y-2">
                        <Label htmlFor="first-name">First Name</Label>
                        <Input id="first-name" defaultValue="Jay" />
                      </div>
                      <div className="space-y-2">
                        <Label htmlFor="last-name">Last Name</Label>
                        <Input id="last-name" defaultValue="Literal" />
                      </div>
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="title">Title</Label>
                      <Select defaultValue="professor">
                        <SelectTrigger>
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="professor">Professor</SelectItem>
                          <SelectItem value="associate">Associate Professor</SelectItem>
                          <SelectItem value="assistant">Assistant Professor</SelectItem>
                          <SelectItem value="instructor">Instructor</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="email">Email Address</Label>
                      <Input id="email" type="email" defaultValue="john.garcia@bestlink.edu.ph" />
                    </div>
                    <div className="grid grid-cols-2 gap-4">
                      <div className="space-y-2">
                        <Label htmlFor="phone">Phone Number</Label>
                        <Input id="phone" defaultValue="+63 912 345 6789" />
                      </div>
                      <div className="space-y-2">
                        <Label htmlFor="department">Department</Label>
                        <Select defaultValue="bs_it">
                          <SelectTrigger>
                            <SelectValue />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="bs_it">BS Information Technology</SelectItem>
                            <SelectItem value="bs_hm">BS Hospitality Management</SelectItem>
                            <SelectItem value="bs_ba">BS Business Administration</SelectItem>
                            <SelectItem value="bs_crim">BS Criminology</SelectItem>
                            <SelectItem value="beed">Bachelor of Elementary Education</SelectItem>
                            <SelectItem value="bsed">Bachelor of Secondary Education</SelectItem>
                          </SelectContent>
                        </Select>
                      </div>
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="office">Office Location</Label>
                      <Input id="office" defaultValue="Faculty Office 301, IT Building" />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="office-hours">Office Hours</Label>
                      <Input id="office-hours" defaultValue="MWF 2:00-4:00 PM, TTh 10:00-12:00 PM" />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="bio">Bio</Label>
                      <Textarea
                        id="bio"
                        placeholder="Brief description about yourself..."
                        defaultValue="Professor of Computer Science with expertise in database systems and web development. Teaching at Bestlink College for over 8 years."
                        rows={3}
                      />
                    </div>
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle>Profile Picture</CardTitle>
                    <CardDescription>Update your profile photo</CardDescription>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="flex flex-col items-center">
                      <div className="w-24 h-24 bg-[#1E2A78] rounded-full flex items-center justify-center mb-4">
                        <User className="h-12 w-12 text-white" />
                      </div>
                      <Button variant="outline" className="w-full bg-transparent">
                        Upload Photo
                      </Button>
                      <Button variant="ghost" className="w-full text-red-600">
                        Remove Photo
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              </div>
            </TabsContent>

            <TabsContent value="academic">
              <div className="space-y-6">
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <GraduationCap className="h-5 w-5" />
                      Academic Information
                    </CardTitle>
                    <CardDescription>Your academic credentials and specializations</CardDescription>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="space-y-2">
                      <Label htmlFor="specialization">Specialization</Label>
                      <Input
                        id="specialization"
                        defaultValue="Database Systems, Web Development, Software Engineering"
                      />
                    </div>
                    <div className="grid grid-cols-2 gap-4">
                      <div className="space-y-2">
                        <Label htmlFor="education">Highest Education</Label>
                        <Select defaultValue="masters">
                          <SelectTrigger>
                            <SelectValue />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="bachelors">Bachelor's Degree</SelectItem>
                            <SelectItem value="masters">Master's Degree</SelectItem>
                            <SelectItem value="doctorate">Doctorate</SelectItem>
                          </SelectContent>
                        </Select>
                      </div>
                      <div className="space-y-2">
                        <Label htmlFor="years-experience">Years of Experience</Label>
                        <Input id="years-experience" type="number" defaultValue="8" />
                      </div>
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="research-interests">Research Interests</Label>
                      <Textarea
                        id="research-interests"
                        placeholder="Your research areas and interests..."
                        defaultValue="Machine Learning applications in education, Database optimization, Web application security"
                        rows={3}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="publications">Recent Publications</Label>
                      <Textarea id="publications" placeholder="List your recent publications..." rows={3} />
                    </div>
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle>Current Courses</CardTitle>
                    <CardDescription>Courses you are currently teaching</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-3">
                      <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                        <div>
                          <p className="font-medium">CS101 - Introduction to Programming</p>
                          <p className="text-sm text-gray-500">MWF 9:00-10:30 AM • 35 students</p>
                        </div>
                        <Button variant="outline" size="sm">
                          Manage
                        </Button>
                      </div>
                      <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                        <div>
                          <p className="font-medium">CS103 - Database Systems</p>
                          <p className="text-sm text-gray-500">TTh 2:00-3:30 PM • 28 students</p>
                        </div>
                        <Button variant="outline" size="sm">
                          Manage
                        </Button>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </div>
            </TabsContent>

            <TabsContent value="notifications">
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Bell className="h-5 w-5" />
                    Notification Preferences
                  </CardTitle>
                  <CardDescription>Choose how you want to receive notifications</CardDescription>
                </CardHeader>
                <CardContent className="space-y-6">
                  <div className="space-y-4">
                    <div className="flex items-center justify-between">
                      <div>
                        <Label htmlFor="email-notifications">Email Notifications</Label>
                        <p className="text-sm text-gray-500">Receive notifications via email</p>
                      </div>
                      <Switch id="email-notifications" defaultChecked />
                    </div>
                    <div className="flex items-center justify-between">
                      <div>
                        <Label htmlFor="push-notifications">Push Notifications</Label>
                        <p className="text-sm text-gray-500">Receive push notifications in browser</p>
                      </div>
                      <Switch id="push-notifications" defaultChecked />
                    </div>
                  </div>

                  <div className="space-y-4">
                    <h4 className="font-medium text-[#1E2A78]">Notification Types</h4>
                    <div className="space-y-3">
                      <div className="flex items-center justify-between">
                        <Label htmlFor="student-concerns">Student Concerns</Label>
                        <Switch id="student-concerns" defaultChecked />
                      </div>
                      <div className="flex items-center justify-between">
                        <Label htmlFor="announcements">Announcements</Label>
                        <Switch id="announcements" defaultChecked />
                      </div>
                      <div className="flex items-center justify-between">
                        <Label htmlFor="course-updates">Course Updates</Label>
                        <Switch id="course-updates" defaultChecked />
                      </div>
                      <div className="flex items-center justify-between">
                        <Label htmlFor="appointment-requests">Appointment Requests</Label>
                        <Switch id="appointment-requests" defaultChecked />
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            <TabsContent value="security">
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Key className="h-5 w-5" />
                    Change Password
                  </CardTitle>
                  <CardDescription>Update your account password</CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="space-y-2">
                    <Label htmlFor="current-password">Current Password</Label>
                    <Input id="current-password" type="password" />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="new-password">New Password</Label>
                    <Input id="new-password" type="password" />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="confirm-password">Confirm New Password</Label>
                    <Input id="confirm-password" type="password" />
                  </div>
                  <Button className="bg-[#1E2A78] hover:bg-[#2480EA]">Update Password</Button>
                </CardContent>
              </Card>
            </TabsContent>
          </Tabs>
        </div>
      </div>
    </div>
  )
}
