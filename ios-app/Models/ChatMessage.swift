import Foundation

struct ChatMessage: Identifiable, Equatable {
    enum Sender {
        case user
        case agent
    }

    let id = UUID()
    let sender: Sender
    let text: String
    let timestamp: Date
}
