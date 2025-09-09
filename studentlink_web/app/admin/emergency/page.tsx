import { ProtectedRoute } from "@/components/protected-route"
import { RoleBasedNav } from "@/components/navigation/role-based-nav"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Badge } from "@/components/ui/badge"
import { Textarea } from "@/components/ui/textarea"
import { Switch } from "@/components/ui/switch"
import { AlertTriangle, Phone, MapPin, Clock, Plus, Edit, Trash2 } from "lucide-react"

export default function AdminEmergencyPage() {
  const emergencyServices = [
    {
      id: 1,
      name: "Campus Clinic",
      phone: "+63 2 8123-4567",
      location: "Ground Floor, Main Building",
      hours: "24/7",
      status: "active",
      description: "Medical emergencies and health services",
    },
    {
      id: 2,
      name: "Campus Security",
      phone: "+63 2 8123-4568",
      location: "Security Office, Gate 1",
      hours: "24/7",
      status: "active",
      description: "Security incidents and campus safety",
    },
    {
      id: 3,
      name: "Guidance Office",
      phone: "+63 2 8123-4569",
      location: "2nd Floor, Admin Building",
      hours: "8:00 AM - 5:00 PM",
      status: "active",
      description: "Student counseling and guidance services",
    },
    {
      id: 4,
      name: "Maintenance",
      phone: "+63 2 8123-4570",
      location: "Basement, Main Building",
      hours: "7:00 AM - 6:00 PM",
      status: "inactive",
      description: "Facility maintenance and repairs",
    },
  ]

  return (
    <ProtectedRoute allowedRoles={["admin"]}>
      <div className="flex min-h-screen bg-gray-50">
        <RoleBasedNav />
        <main className="flex-1 p-6">
          <div className="max-w-6xl mx-auto">
            <div className="mb-8">
              <h1 className="text-3xl font-bold text-[#1E2A78] mb-2">Emergency Help Management</h1>
              <p className="text-gray-600">Configure emergency services and contact information</p>
            </div>

            {/* Emergency Alert Settings */}
            <Card className="mb-6">
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <AlertTriangle className="h-5 w-5 text-[#E22824]" />
                  Emergency Alert Settings
                </CardTitle>
                <CardDescription>Configure system-wide emergency notifications</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="flex items-center justify-between">
                  <div>
                    <Label htmlFor="emergency-mode">Emergency Mode</Label>
                    <p className="text-sm text-gray-500">Enable campus-wide emergency alerts</p>
                  </div>
                  <Switch id="emergency-mode" />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="emergency-message">Emergency Message</Label>
                  <Textarea
                    id="emergency-message"
                    placeholder="Enter emergency message to broadcast to all users..."
                    rows={3}
                  />
                </div>
                <div className="flex gap-4">
                  <Button className="bg-[#E22824] hover:bg-red-700 text-white">
                    <AlertTriangle className="h-4 w-4 mr-2" />
                    Broadcast Emergency Alert
                  </Button>
                  <Button variant="outline">Clear Alert</Button>
                </div>
              </CardContent>
            </Card>

            {/* Emergency Services Management */}
            <Card>
              <CardHeader>
                <div className="flex items-center justify-between">
                  <div>
                    <CardTitle>Emergency Services</CardTitle>
                    <CardDescription>Manage emergency contact information and services</CardDescription>
                  </div>
                  <Button className="bg-[#2480EA] hover:bg-[#1E2A78]">
                    <Plus className="h-4 w-4 mr-2" />
                    Add Service
                  </Button>
                </div>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {emergencyServices.map((service) => (
                    <Card key={service.id} className="border-l-4 border-l-[#2480EA]">
                      <CardContent className="p-4">
                        <div className="flex items-start justify-between">
                          <div className="flex-1">
                            <div className="flex items-center gap-3 mb-2">
                              <h3 className="font-semibold text-lg text-[#1E2A78]">{service.name}</h3>
                              <Badge
                                variant={service.status === "active" ? "default" : "secondary"}
                                className={service.status === "active" ? "bg-green-100 text-green-800" : ""}
                              >
                                {service.status}
                              </Badge>
                            </div>
                            <p className="text-gray-600 mb-3">{service.description}</p>
                            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
                              <div className="flex items-center gap-2">
                                <Phone className="h-4 w-4 text-[#2480EA]" />
                                <span className="font-medium">{service.phone}</span>
                              </div>
                              <div className="flex items-center gap-2">
                                <MapPin className="h-4 w-4 text-[#2480EA]" />
                                <span>{service.location}</span>
                              </div>
                              <div className="flex items-center gap-2">
                                <Clock className="h-4 w-4 text-[#2480EA]" />
                                <span>{service.hours}</span>
                              </div>
                            </div>
                          </div>
                          <div className="flex gap-2 ml-4">
                            <Button size="sm" variant="outline">
                              <Edit className="h-4 w-4" />
                            </Button>
                            <Button
                              size="sm"
                              variant="outline"
                              className="text-red-600 hover:text-red-700 bg-transparent"
                            >
                              <Trash2 className="h-4 w-4" />
                            </Button>
                          </div>
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              </CardContent>
            </Card>

            {/* Add New Service Form */}
            <Card className="mt-6">
              <CardHeader>
                <CardTitle>Add New Emergency Service</CardTitle>
                <CardDescription>Configure a new emergency contact service</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="service-name">Service Name</Label>
                    <Input id="service-name" placeholder="e.g., Campus Fire Department" />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="service-phone">Phone Number</Label>
                    <Input id="service-phone" placeholder="+63 2 8123-4567" />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="service-location">Location</Label>
                    <Input id="service-location" placeholder="Building and room number" />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="service-hours">Operating Hours</Label>
                    <Input id="service-hours" placeholder="e.g., 24/7 or 8:00 AM - 5:00 PM" />
                  </div>
                </div>
                <div className="space-y-2 mt-4">
                  <Label htmlFor="service-description">Description</Label>
                  <Textarea id="service-description" placeholder="Brief description of the service..." rows={3} />
                </div>
                <div className="flex items-center space-x-2 mt-4">
                  <Switch id="service-active" defaultChecked />
                  <Label htmlFor="service-active">Active Service</Label>
                </div>
                <Button className="bg-[#2480EA] hover:bg-[#1E2A78] mt-4">Add Emergency Service</Button>
              </CardContent>
            </Card>
          </div>
        </main>
      </div>
    </ProtectedRoute>
  )
}
