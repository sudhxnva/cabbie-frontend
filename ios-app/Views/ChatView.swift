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
        .sheet(item: $viewModel.bookingConfirmation) { confirmation in
            NavigationStack {
                BookingConfirmationView(viewModel: BookingViewModel(confirmation: confirmation))
            }
        }
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

                if !viewModel.rideOptions.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Ride Options")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        ForEach(viewModel.rideOptions) { option in
                            CabOptionCard(option: option) { selectedOption in
                                viewModel.bookRide(selectedOption)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
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
