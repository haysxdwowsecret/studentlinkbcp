import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Download } from "lucide-react"

export function ReportsAndAnalytics() {
  return (
    <div className="space-y-6">
      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
        {/* Placeholder for a key metric */}
        <Card>
          <CardHeader>
            <CardTitle className="text-[#1E2A78]">Total Concerns Submitted</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-4xl font-bold">125</p>
            <p className="text-xs text-muted-foreground">+15% from last month</p>
          </CardContent>
        </Card>

        {/* Placeholder for another key metric */}
        <Card>
          <CardHeader>
            <CardTitle className="text-[#1E2A78]">Average Resolution Time</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-4xl font-bold">2.5 Days</p>
            <p className="text-xs text-muted-foreground">-0.5 days from last month</p>
          </CardContent>
        </Card>

        {/* Placeholder for a third key metric */}
        <Card>
          <CardHeader>
            <CardTitle className="text-[#1E2A78]">Satisfaction Rate</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-4xl font-bold">92%</p>
            <p className="text-xs text-muted-foreground">+3% from last month</p>
          </CardContent>
        </Card>
      </div>

      {/* Placeholder for a larger chart */}
      <Card>
        <CardHeader>
          <CardTitle className="text-[#1E2A78]">Concerns by Department</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="h-[300px] bg-gray-100 rounded-md flex items-center justify-center">
            <p className="text-gray-500">Chart will be displayed here.</p>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-[#1E2A78]">Generate Reports</CardTitle>
        </CardHeader>
        <CardContent>
          <p>Download comprehensive reports in various formats.</p>
          <div className="flex space-x-2 mt-4">
            <Button variant="outline">
              <Download className="mr-2 h-4 w-4" />
              Download CSV
            </Button>
            <Button variant="outline">
              <Download className="mr-2 h-4 w-4" />
              Download PDF
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
