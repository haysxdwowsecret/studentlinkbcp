import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Textarea } from "@/components/ui/textarea"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"

export function ChatbotManagement() {
  return (
    <Tabs defaultValue="training">
      <TabsList className="mb-4">
        <TabsTrigger value="training">Chatbot Training</TabsTrigger>
        <TabsTrigger value="history">Conversation History</TabsTrigger>
        <TabsTrigger value="analytics">Performance Analytics</TabsTrigger>
      </TabsList>

      <TabsContent value="training">
        <Card>
          <CardHeader>
            <CardTitle className="text-[#1E2A78]">Train the Chatbot</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <p>Provide new information or conversation examples for the chatbot. The bot will learn from this and improve its responses.</p>
              <Textarea
                placeholder="Enter training data here... e.g., Q: What are the library hours? A: The library is open from 8 AM to 5 PM, Monday to Friday."
                rows={8}
              />
              <Button className="bg-[#1E2A78] hover:bg-[#2480EA]">Start Training</Button>
            </div>
          </CardContent>
        </Card>
      </TabsContent>

      <TabsContent value="history">
        <Card>
          <CardHeader>
            <CardTitle className="text-[#1E2A78]">Conversation Logs</CardTitle>
          </CardHeader>
          <CardContent>
            <p>Review conversations the chatbot has had with students. This can help identify areas for improvement.</p>
            {/* Placeholder for conversation logs */}
            <div className="bg-gray-100 p-4 rounded-md mt-4">
              <p className="text-sm text-gray-500">No conversation history available yet.</p>
            </div>
          </CardContent>
        </Card>
      </TabsContent>

      <TabsContent value="analytics">
        <Card>
          <CardHeader>
            <CardTitle className="text-[#1E2A78]">Chatbot Analytics</CardTitle>
          </CardHeader>
          <CardContent>
            <p>View key metrics on the chatbot's performance.</p>
            {/* Placeholder for analytics */}
            <div className="bg-gray-100 p-4 rounded-md mt-4">
              <p className="text-sm text-gray-500">Analytics data is not yet available.</p>
            </div>
          </CardContent>
        </Card>
      </TabsContent>
    </Tabs>
  )
}
