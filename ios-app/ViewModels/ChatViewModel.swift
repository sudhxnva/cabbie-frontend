import Foundation
import Combine

final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = [
        ChatMessage(sender: .user, text: "I need a cab to the airport.", timestamp: .now),
        ChatMessage(sender: .agent, text: "Searching Uber and Lyft...", timestamp: .now)
    ]
    @Published var inputText = ""
    @Published var voiceState: VoiceOrbView.OrbState = .idle

    func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        messages.append(ChatMessage(sender: .user, text: trimmed, timestamp: .now))
        inputText = ""

        // Stubbed agent response for now.
        messages.append(ChatMessage(sender: .agent, text: "Got it. Looking up rides.", timestamp: .now))
    }

    func cycleVoiceState() {
        switch voiceState {
        case .idle:
            voiceState = .listening
        case .listening:
            voiceState = .speaking
        case .speaking:
            voiceState = .idle
        }
    }
}
