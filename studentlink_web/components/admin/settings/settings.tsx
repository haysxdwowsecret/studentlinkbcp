import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Switch } from "@/components/ui/switch"

export function Settings() {
  return (
    <div className="space-y-8">
      <Card>
        <CardHeader>
          <CardTitle className="text-[#1E2A78]">General Settings</CardTitle>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="space-y-2">
            <Label htmlFor="portal-name">Portal Name</Label>
            <Input id="portal-name" defaultValue="Student Support Portal" />
          </div>
          <div className="flex items-center justify-between">
            <Label htmlFor="maintenance-mode">Maintenance Mode</Label>
            <Switch id="maintenance-mode" />
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-[#1E2A78]">Notification Settings</CardTitle>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="flex items-center justify-between">
            <Label htmlFor="email-notifs">Enable Email Notifications</Label>
            <Switch id="email-notifs" defaultChecked />
          </div>
          <div className="space-y-2">
            <Label htmlFor="admin-email">Admin Email for Notifications</Label>
            <Input id="admin-email" type="email" defaultValue="admin@support.portal" />
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-[#1E2A78]">Concern Submission Settings</CardTitle>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="flex items-center justify-between">
            <Label htmlFor="allow-attachments">Allow File Attachments</Label>
            <Switch id="allow-attachments" defaultChecked />
          </div>
          <div className="space-y-2">
            <Label htmlFor="max-file-size">Max File Size (MB)</Label>
            <Input id="max-file-size" type="number" defaultValue={10} />
          </div>
        </CardContent>
      </Card>

      <div className="flex justify-end">
        <Button className="bg-[#1E2A78] hover:bg-[#2480EA]">Save All Settings</Button>
      </div>
    </div>
  )
}
