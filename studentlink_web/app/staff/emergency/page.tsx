"use client"

import { RoleBasedNav } from "@/components/navigation/role-based-nav"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Phone, MapPin, Clock, AlertTriangle, Heart, Shield, Users } from "lucide-react"

export default function StaffEmergencyPage() {
  const emergencyServices = [
    {
      id: 1,
      name: "Campus Clinic",
      description: "Medical emergencies and health concerns",
      phone: "+63 2 8123-4567",
      location: "Ground Floor, Main Building",
      hours: "24/7",
      status: "available",
      icon: Heart,
      color: "bg-red-500",
    },
    {
      id: 2,
      name: "Campus Security",
      description: "Security incidents and safety concerns",
      phone: "+63 2 8123-4568",
      location: "Security Office, Gate 1",
      hours: "24/7",
      status: "available",
      icon: Shield,
      color: "bg-blue-500",
    },
    {
      id: 3,
      name: "Guidance Office",
      description: "Student counseling and psychological support",
      phone: "+63 2 8123-4569",
      location: "2nd Floor, Student Services Building",
      hours: "8:00 AM - 5:00 PM",
      status: "available",
      icon: Users,
      color: "bg-green-500",
    },
  ]

  const recentEmergencies = [
    {
      id: 1,
      type: "Medical",
      description: "Student fainted in classroom",
      location: "Room 301, IT Building",
      time: "2 hours ago",
      status: "resolved",
      responder: "Campus Clinic",
    },
    {
      id: 2,
      type: "Security",
      description: "Suspicious person reported",
      location: "Parking Area B",
      time: "4 hours ago",
      status: "resolved",
      responder: "Campus Security",
    },
  ]

  const getStatusColor = (status: string) => {
    switch (status) {
      case "available":
        return "bg-green-100 text-green-800"
      case "busy":
        return "bg-yellow-100 text-yellow-800"
      case "unavailable":
        return "bg-red-100 text-red-800"
      default:
        return "bg-gray-100 text-gray-800"
    }
  }

  return (
    <div className="flex h-screen bg-gray-50">
      <RoleBasedNav />

      <div className="flex-1 overflow-y-auto">
        <header className="bg-white shadow-sm border-b border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-bold text-[#1E2A78]">Emergency Help</h1>
              <p className="text-gray-600">Quick access to campus emergency services</p>
            </div>
            <div className="flex items-center space-x-2">
              <AlertTriangle className="h-5 w-5 text-red-500" />
              <span className="text-sm font-medium text-red-600">Emergency Hotline: 911</span>
            </div>
          </div>
        </header>

        <div className="p-6 space-y-6">
          {/* Emergency Services */}
          <div>
            <h2 className="text-xl font-semibold text-[#1E2A78] mb-4">Campus Emergency Services</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {emergencyServices.map((service) => {
                const IconComponent = service.icon
                return (
                  <Card key={service.id} className="hover:shadow-lg transition-shadow">
                    <CardHeader className="pb-3">
                      <div className="flex items-center space-x-3">
                        <div className={`p-3 rounded-lg ${service.color}`}>
                          <IconComponent className="h-6 w-6 text-white" />
                        </div>
                        <div className="flex-1">
                          <CardTitle className="text-lg text-[#1E2A78]">{service.name}</CardTitle>
                          <Badge className={getStatusColor(service.status)}>{service.status.toUpperCase()}</Badge>
                        </div>
                      </div>
                    </CardHeader>
                    <CardContent className="space-y-4">
                      <CardDescription>{service.description}</CardDescription>

                      <div className="space-y-2 text-sm">
                        <div className="flex items-center text-gray-600">
                          <Phone className="h-4 w-4 mr-2" />
                          {service.phone}
                        </div>
                        <div className="flex items-center text-gray-600">
                          <MapPin className="h-4 w-4 mr-2" />
                          {service.location}
                        </div>
                        <div className="flex items-center text-gray-600">
                          <Clock className="h-4 w-4 mr-2" />
                          {service.hours}
                        </div>
                      </div>

                      <div className="flex space-x-2">
                        <Button
                          className="flex-1 bg-[#1E2A78] hover:bg-[#2480EA]"
                          onClick={() => window.open(`tel:${service.phone}`)}
                        >
                          <Phone className="h-4 w-4 mr-2" />
                          Call Now
                        </Button>
                        <Button variant="outline" className="flex-1 bg-transparent">
                          <MapPin className="h-4 w-4 mr-2" />
                          Locate
                        </Button>
                      </div>
                    </CardContent>
                  </Card>
                )
              })}
            </div>
          </div>

          {/* Recent Emergency Reports */}
          <div>
            <h2 className="text-xl font-semibold text-[#1E2A78] mb-4">Recent Emergency Reports</h2>
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Emergency Activity Log</CardTitle>
                <CardDescription>Recent emergency incidents and responses</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {recentEmergencies.map((emergency) => (
                    <div key={emergency.id} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                      <div className="flex items-center space-x-4">
                        <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                        <div>
                          <p className="font-medium text-[#1E2A78]">
                            {emergency.type}: {emergency.description}
                          </p>
                          <p className="text-sm text-gray-600">
                            {emergency.location} • {emergency.time}
                          </p>
                        </div>
                      </div>
                      <div className="text-right">
                        <Badge className="bg-green-100 text-green-800">{emergency.status.toUpperCase()}</Badge>
                        <p className="text-sm text-gray-500 mt-1">by {emergency.responder}</p>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Emergency Procedures */}
          <div>
            <h2 className="text-xl font-semibold text-[#1E2A78] mb-4">Emergency Procedures</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <Card>
                <CardHeader>
                  <CardTitle className="text-lg text-red-600">Medical Emergency</CardTitle>
                </CardHeader>
                <CardContent>
                  <ol className="list-decimal list-inside space-y-2 text-sm text-gray-700">
                    <li>Ensure scene safety</li>
                    <li>Call Campus Clinic immediately</li>
                    <li>Do not move injured person unless necessary</li>
                    <li>Provide basic first aid if trained</li>
                    <li>Stay with person until help arrives</li>
                  </ol>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle className="text-lg text-blue-600">Security Incident</CardTitle>
                </CardHeader>
                <CardContent>
                  <ol className="list-decimal list-inside space-y-2 text-sm text-gray-700">
                    <li>Ensure personal safety first</li>
                    <li>Contact Campus Security</li>
                    <li>Do not confront suspicious individuals</li>
                    <li>Provide detailed location information</li>
                    <li>Follow security personnel instructions</li>
                  </ol>
                </CardContent>
              </Card>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
