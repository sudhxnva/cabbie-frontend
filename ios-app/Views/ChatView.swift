import SwiftUI

struct ChatView: View {
    @StateObject var viewModel: ChatViewModel
    @State private var showCallErrorToast = false

    var body: some View {
        VStack(spacing: 14) {
            header
            callArea
            if isChatVisible {
                messageList
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                Spacer(minLength: 0)
                inputBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                Spacer(minLength: 0)
            }
        }
        .padding(.top, 8)
        .background(Color(.systemBackground))
        .animation(.easeInOut(duration: 0.3), value: isChatVisible)
        .sheet(item: $viewModel.bookingConfirmation) { confirmation in
            NavigationStack {
                BookingConfirmationView(viewModel: BookingViewModel(confirmation: confirmation))
            }
        }
        .overlay(alignment: .top) {
            if showCallErrorToast, let message = viewModel.callErrorMessage {
                Text(message)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.red.opacity(0.9))
                    )
                    .padding(.top, 18)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showCallErrorToast)
        .onChange(of: viewModel.callErrorMessage) { _, newValue in
            guard newValue != nil else {
                showCallErrorToast = false
                return
            }
            showCallErrorToast = true
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(2.5))
                showCallErrorToast = false
                viewModel.clearCallError()
            }
        }
    }

    private var header: some View {
        HStack {
            Spacer()
            Text("Cabbie")
                .font(.title3.weight(.semibold))
            Spacer()
        }
        .padding(.horizontal, 20)
        .foregroundStyle(.primary)
    }

    private var isChatVisible: Bool {
        !viewModel.isCallActive && !viewModel.isConnecting
    }

    private var callArea: some View {
        VStack(spacing: 14) {
            ZStack(alignment: .bottom) {
                VoiceOrbView(state: viewModel.voiceState)
                    .frame(width: 280, height: 280)

                Button {
                    viewModel.cycleVoiceState()
                } label: {
                    Group {
                        if viewModel.isConnecting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: viewModel.isCallActive ? "phone.down.fill" : "phone.fill")
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(width: 62, height: 62)
                    .background(viewModel.isCallActive ? Color.red : Color.black)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.9), lineWidth: 4)
                    )
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isConnecting)
                .offset(y: 20)
            }
            .padding(.bottom, 12)

            if viewModel.isCallActive {
                Button {
                    viewModel.toggleMute()
                } label: {
                    Image(systemName: viewModel.isMuted ? "mic.slash.fill" : "mic.fill")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(viewModel.isMuted ? .blue : .white)
                        .frame(width: 58, height: 58)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            } else if viewModel.isConnecting {
                Text("Connecting...")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                Text("Tap the phone button to start voice")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
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
        .frame(maxHeight: 220)
    }

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Send a message to start a chat", text: $viewModel.inputText)
                .textFieldStyle(.plain)
                .padding(.leading, 8)

            Button {
                viewModel.sendMessage()
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.headline)
                    .frame(width: 44, height: 44)
                    .foregroundStyle(.white)
                    .background(Color.black)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(8)
        .background(
            Capsule()
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }
}
