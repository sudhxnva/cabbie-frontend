import SwiftUI

struct ChatView: View {
    @StateObject var viewModel: ChatViewModel

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            messageList
            Divider()
            inputBar
        }
        .background(Color(.systemBackground))
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Cabbie")
                    .font(.headline)
                Text("Voice-enabled ride comparison")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VoiceOrbView(state: viewModel.voiceState)
                .onTapGesture {
                    viewModel.cycleVoiceState()
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var messageList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(viewModel.messages) { message in
                    ChatBubble(message: message)
                }
            }
            .padding(16)
        }
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Type your request...", text: $viewModel.inputText)
                .textFieldStyle(.roundedBorder)

            Button("Send") {
                viewModel.sendMessage()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(12)
    }
}
