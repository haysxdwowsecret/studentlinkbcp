import { ProtectedRoute } from "@/components/protected-route"
import { RoleBasedNav } from "@/components/navigation/role-based-nav"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Switch } from "@/components/ui/switch"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { User, Bell, Shield, Camera } from "lucide-react"

export default function DepartmentHeadProfilePage() {
  return (
    <ProtectedRoute allowedRoles={["department_head"]}>
      <div className="flex min-h-screen bg-gray-50">
        <RoleBasedNav />
        <main className="flex-1 p-6">
          <div className="max-w-4xl mx-auto">
            <div className="mb-8">
              <h1 className="text-3xl font-bold text-[#1E2A78] mb-2">Profile & Settings</h1>
              <p className="text-gray-600">Manage your profile information and preferences</p>
            </div>

            <Tabs defaultValue="profile" className="space-y-6">
              <TabsList className="grid w-full grid-cols-3">
                <TabsTrigger value="profile">Profile</TabsTrigger>
                <TabsTrigger value="notifications">Notifications</TabsTrigger>
                <TabsTrigger value="security">Security</TabsTrigger>
              </TabsList>

              <TabsContent value="profile">
                <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                  {/* Profile Picture */}
                  <Card>
                    <CardHeader>
                      <CardTitle>Profile Picture</CardTitle>
                    </CardHeader>
                    <CardContent className="flex flex-col items-center space-y-4">
                      <Avatar className="w-32 h-32">
                        <AvatarImage src="/placeholder.svg?height=128&width=128" />
                        <AvatarFallback className="text-2xl">DJ</AvatarFallback>
                      </Avatar>
                      <Button variant="outline" className="w-full bg-transparent">
                        <Camera className="h-4 w-4 mr-2" />
                        Change Photo
                      </Button>
                    </CardContent>
                  </Card>

                  {/* Profile Information */}
                  <div className="lg:col-span-2">
                    <Card>
                      <CardHeader>
                        <CardTitle className="flex items-center gap-2">
                          <User className="h-5 w-5" />
                          Personal Information
                        </CardTitle>
                        <CardDescription>Update your personal details</CardDescription>
                      </CardHeader>
                      <CardContent className="space-y-6">
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
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
                          <Label htmlFor="email">Email Address</Label>
                          <Input id="email" type="email" defaultValue="john.johnson@bestlink.edu.ph" />
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                          <div className="space-y-2">
                            <Label htmlFor="phone">Phone Number</Label>
                            <Input id="phone" defaultValue="+63 2 8123-4567" />
                          </div>
                          <div className="space-y-2">
                            <Label htmlFor="department">Department</Label>
                            <Select defaultValue="it">
                              <SelectTrigger>
                                <SelectValue />
                              </SelectTrigger>
                              <SelectContent>
                                <SelectItem value="it">BS Information Technology</SelectItem>
                                <SelectItem value="ba">BS Business Administration</SelectItem>
                                <SelectItem value="hm">BS Hospitality Management</SelectItem>
                                <SelectItem value="oa">BS Office Administration</SelectItem>
                                <SelectItem value="crim">BS Criminology</SelectItem>
                                <SelectItem value="elem">Bachelor of Elementary Education</SelectItem>
                                <SelectItem value="sec">Bachelor of Secondary Education</SelectItem>
                                <SelectItem value="ce">BS Computer Engineering</SelectItem>
                                <SelectItem value="tm">BS Tourism Management</SelectItem>
                                <SelectItem value="entrep">BS Entrepreneurship</SelectItem>
                                <SelectItem value="ais">BS Accounting Information System</SelectItem>
                                <SelectItem value="psych">BS Psychology</SelectItem>
                              </SelectContent>
                            </Select>
                          </div>
                        </div>

                        <div className="space-y-2">
                          <Label htmlFor="office-location">Office Location</Label>
                          <Input id="office-location" defaultValue="Room 301, IT Building" />
                        </div>

                        <div className="space-y-2">
                          <Label htmlFor="bio">Bio</Label>
                          <Textarea
                            id="bio"
                            placeholder="Brief description about yourself..."
                            rows={4}
                            defaultValue="Department Head of Information Technology with over 10 years of experience in computer science education and student development."
                          />
                        </div>

                        <Button className="bg-[#2480EA] hover:bg-[#1E2A78]">Update Profile</Button>
                      </CardContent>
                    </Card>
                  </div>
                </div>
              </TabsContent>

              <TabsContent value="notifications">
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <Bell className="h-5 w-5" />
                      Notification Preferences
                    </CardTitle>
                    <CardDescription>Configure how you receive notifications</CardDescription>
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
                          <p className="text-sm text-gray-500">Receive push notifications on your devices</p>
                        </div>
                        <Switch id="push-notifications" defaultChecked />
                      </div>

                      <div className="flex items-center justify-between">
                        <div>
                          <Label htmlFor="sms-notifications">SMS Notifications</Label>
                          <p className="text-sm text-gray-500">Receive SMS for urgent concerns</p>
                        </div>
                        <Switch id="sms-notifications" />
                      </div>
                    </div>

                    <hr />

                    <div className="space-y-4">
                      <h4 className="font-medium text-[#1E2A78]">Notification Types</h4>

                      <div className="flex items-center justify-between">
                        <div>
                          <Label htmlFor="new-concerns">New Concerns</Label>
                          <p className="text-sm text-gray-500">When new concerns are submitted to your department</p>
                        </div>
                        <Switch id="new-concerns" defaultChecked />
                      </div>

                      <div className="flex items-center justify-between">
                        <div>
                          <Label htmlFor="concern-updates">Concern Updates</Label>
                          <p className="text-sm text-gray-500">When concerns are updated or replied to</p>
                        </div>
                        <Switch id="concern-updates" defaultChecked />
                      </div>

                      <div className="flex items-center justify-between">
                        <div>
                          <Label htmlFor="staff-activities">Staff Activities</Label>
                          <p className="text-sm text-gray-500">When staff members take actions on concerns</p>
                        </div>
                        <Switch id="staff-activities" defaultChecked />
                      </div>

                      <div className="flex items-center justify-between">
                        <div>
                          <Label htmlFor="system-alerts">System Alerts</Label>
                          <p className="text-sm text-gray-500">Important system notifications and updates</p>
                        </div>
                        <Switch id="system-alerts" defaultChecked />
                      </div>
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="notification-frequency">Notification Frequency</Label>
                      <Select defaultValue="immediate">
                        <SelectTrigger>
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="immediate">Immediate</SelectItem>
                          <SelectItem value="hourly">Hourly Digest</SelectItem>
                          <SelectItem value="daily">Daily Digest</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>

                    <Button className="bg-[#2480EA] hover:bg-[#1E2A78]">Save Notification Settings</Button>
                  </CardContent>
                </Card>
              </TabsContent>

              <TabsContent value="security">
                <div className="space-y-6">
                  <Card>
                    <CardHeader>
                      <CardTitle className="flex items-center gap-2">
                        <Shield className="h-5 w-5" />
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
                      <Button className="bg-[#2480EA] hover:bg-[#1E2A78]">Update Password</Button>
                    </CardContent>
                  </Card>

                  <Card>
                    <CardHeader>
                      <CardTitle>Security Settings</CardTitle>
                      <CardDescription>Additional security options</CardDescription>
                    </CardHeader>
                    <CardContent className="space-y-4">
                      <div className="flex items-center justify-between">
                        <div>
                          <Label htmlFor="two-factor">Two-Factor Authentication</Label>
                          <p className="text-sm text-gray-500">Add an extra layer of security to your account</p>
                        </div>
                        <Switch id="two-factor" />
                      </div>

                      <div className="flex items-center justify-between">
                        <div>
                          <Label htmlFor="login-alerts">Login Alerts</Label>
                          <p className="text-sm text-gray-500">Get notified when someone logs into your account</p>
                        </div>
                        <Switch id="login-alerts" defaultChecked />
                      </div>

                      <Button variant="outline" className="w-full bg-transparent">
                        View Login History
                      </Button>
                    </CardContent>
                  </Card>
                </div>
              </TabsContent>
            </Tabs>
          </div>
        </main>
      </div>
    </ProtectedRoute>
  )
}
