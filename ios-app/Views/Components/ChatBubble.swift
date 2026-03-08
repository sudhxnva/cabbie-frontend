import SwiftUI

struct ChatBubble: View {
    let message: ChatMessage

    private var isUser: Bool { message.sender == .user }
    private var bubbleColor: Color { isUser ? .blue : Color(.systemGray5) }
    private var textColor: Color { isUser ? .white : .primary }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 48) }
            Text(message.text)
                .font(.body)
                .foregroundStyle(textColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(bubbleColor)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            if !isUser { Spacer(minLength: 48) }
        }
        .frame(maxWidth: .infinity)
    }
}
