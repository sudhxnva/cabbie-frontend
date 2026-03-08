import Foundation

final class ElevenLabsService: ObservableObject {
    enum ConversationState: Equatable {
        case idle
        case listening
        case speaking
        case stopped
    }

    struct AgentEvent: Identifiable, Equatable {
        let id = UUID()
        let timestamp: Date
        let description: String
    }

    @Published private(set) var messages: [ChatMessage] = [
        ChatMessage(sender: .agent, text: "Hi, where do you need to go?", timestamp: .now)
    ]
    @Published private(set) var conversationState: ConversationState = .idle
    @Published private(set) var agentEvents: [AgentEvent] = []

    func startConversation() {
        conversationState = .listening
        appendEvent("Conversation started")
    }

    func stopConversation() {
        conversationState = .stopped
        appendEvent("Conversation stopped")
    }

    func sendText(_ message: String) {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        messages.append(ChatMessage(sender: .user, text: trimmed, timestamp: .now))
        appendEvent("User text sent: \(trimmed)")

        handleToolCall(name: "search_cabs", payload: "{ \"query\": \"\(trimmed)\" }")

        let agentReply = "Got it. Comparing ride options now."
        messages.append(ChatMessage(sender: .agent, text: agentReply, timestamp: .now))
        appendEvent("Agent reply received")
        conversationState = .speaking
    }

    private func handleToolCall(name: String, payload: String) {
        // Stubbed until backend tool execution is integrated.
        appendEvent("Tool call requested: \(name) payload=\(payload)")
    }

    private func appendEvent(_ description: String) {
        agentEvents.append(AgentEvent(timestamp: .now, description: description))
    }
}
